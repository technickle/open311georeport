_ = require("underscore")
moment = require("moment")
module.exports = (app) ->
  class app.Socrata
    constructor: (res, req)->
      @res = res
      @req = req
      @basePath = "/resource/erm2-nwe9.json"

    fetchData: (requestOptions)->
      # TODO: evaluate the other parameters and check for validity
      # TODO: construct SODA query
      http    = require 'http'
      format  = @req.params.format
      out     = @res
      request = http.request(requestOptions, (response) ->
        # TODO: handle HTTP response errors
        #   403 missing API key
        #   400 invalid request
        #   404 resource doesn't exist

        responseBody = ""
        response.on "data", (chunk) ->
          responseBody += chunk
        response.on "end", ->
          adapter   = new app.Adapter(responseBody)
          resp      = adapter.convertToOpen311()
          adapter.respond(resp, format, out)
      )
      request.end()

    callWith: (requestOptions)->
      if @_noIdsGiven
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
      parsed_opts       = @_parseOpts(opts)
      console.log parsed_opts
      params            = joined_keys #+ parsed_opts
      encoded_params    = encodeURI(params)
      query             = "$where=" + encoded_params
      path              = "#{@basePath}?#{query}"
      @_request(path)

    #### Private #####

    _parseOpts: (opts)->
      return "" unless opts
      sql_opts  =  _.map opts, (value, key)->
                      switch key
                        when "service_code", "status"
                          "#{key} IS #{value}"
                        when "start_date", "end_date"
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
                          "created_date BETWEEN #{start_date} AND #{end_date}"
      sql_opts  = _.uniq(sql_opts)

      joined_opts   = sql_opts.join(" AND ")
      " AND " + joined_opts

    _request: (path)->
      {
        hostname: "data.cityofnewyork.us"
        port: 80
        path: path
        method: "GET"
      }

