_ = require("underscore")
moment = require("moment")
module.exports = (app) ->
  class app.ResponseParser
    constructor: (attributes)->
      [@out, @format] = [attributes["out"], attributes["format"]]
      @streamingParser()

    streamingParser: ->
      jsonsp = require("jsonsp")
      @parser  = new jsonsp.Parser (obj)=>
        # FIXME: Rather than emitting the objects progressively this callback buffers the chunks into a single response. There could be a few reasons for this. Most likely cause is the parser regards the response as a single object. The fact that the request objects are wrapped in an array at the root supports that notion.
        @emitJSON(obj)
      @out.type("application/json")

    parse: (chunk) ->
      @parser.parse(chunk.toString('utf8'))

    emitJSON: (obj)->
      adapter   = new app.Adapter(obj)
      resp      = adapter.convertToOpen311()
      @out.send resp
      # app.helpers.output resp, "service_requests", @out, @format


  class app.Socrata
    constructor: (res, req)->
      @res = res
      @req = req
      @basePath = "/resource/erm2-nwe9.json"

    fetchData: (requestOptions)->
      format  = @req.params.format
      out     = @res

      request = require("request")
      request(requestOptions, (error, response, body)=>
          adapter   = new app.Adapter(body)
          resp      = adapter.convertToOpen311()
          app.helpers.output resp, "service_requests", out, format
        )

    callWith: (requestOptions)->
      if @_noIdsGiven and requestOptions is null
        # Return early
        @res.send 404
        return
      else
        # Proceed to fetch the data.
        @fetchData requestOptions

    buildRequest: (ids=[], opts={})->
      @_noIdsGiven      = ids.length is 0

      single_quoted_ids = _.map ids, (id)-> "'#{id}'"
      unique_keyed_ids  = _.map single_quoted_ids, (id)->"unique_key=#{id}"
      joined_keys       = unique_keyed_ids.join(' OR ')

      params            = if @_noIdsGiven
                            @_parseOpts(opts)
                          else joined_keys

      encoded_params    = encodeURI(params)

      if params
        query           = "$where=" + encoded_params
        path            = "#{@basePath}?#{query}"
        @_request(path)
      else
        null


    #### Private #####

    _parseOpts: (opts)->
      return "" unless opts
      sql_opts  =  _.map opts, (value, key)=>
                      switch key
                        when "service_code", "status"
                          "#{key} IS #{value}"
                        when "start_date", "end_date"
                          @_parseDates(key, value, opts)
      sql_opts  = _.uniq(sql_opts)
      joined_opts   = sql_opts.join(" AND ")

    _parseDates: (key, value, opts)->
      start_date = opts['start_date']
      end_date   = opts['end_date']
      if !end_date
        end_date   = moment(start_date)
          .add("days", 90)
          .format("YYYY-MM-DDT00:00:00")+"Z"
      else if !start_date
        start_date = moment(end_date)
          .subtract("days", 90)
          .format("YYYY-MM-DDT00:00:00")+"Z"
      else
        # TODO: make sure the dates are 90 days apart from each other
      "created_date >= '#{start_date}' AND created_date <= '#{end_date}'"

    _request: (path)->
      hostname = "data.cityofnewyork.us"
      {
        port: 80
        uri: "http://#{hostname}#{path}"
        method: "GET"
      }

