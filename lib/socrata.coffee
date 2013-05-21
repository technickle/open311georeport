_ = require("underscore")
$ = require("jquery")
module.exports = (app) ->
  class app.Socrata
    constructor: (res, req)->
      @res = res
      @req = req
      @basePath = "/resource/erm2-nwe9.json"

    fetchData: (requestOptions)->
      # TODO: evaluate the other parameters and check for validity
      # TODO: construct SODA query
      http = require 'http'
      format  = @req.params.format
      out     = @res
      request = http.request(requestOptions, (response) ->
        responseBody = ""
        response.on "data", (chunk) ->
          responseBody += chunk
        response.on "end", ->
          adapter = new app.Adapter(responseBody)
          adapter.respond(response, format, out)
      )
      request.end()

    callWith: (requestOptions)->
      if @_noIdsGiven()
        # Return early
        @res.send 404
        return
      else
        # Proceed to fetch the data.
        @fetchData requestOptions

    buildRequest: (ids=[], opts={})->
      @srIds = ids
      single_quoted_ids = _.map ids, (id)-> "'#{id}'"
      unique_keyed_ids  = _.map single_quoted_ids, (id)->"unique_key=#{id}"
      joined_keys       = unique_keyed_ids.join(' OR ')
      parsed_opts       = @_parseOpts(opts)
      console.log parsed_opts
      params            = joined_keys #+ parsed_opts
      encoded_params    = encodeURI(params)
      query             = "$where=" + encoded_params
      console.log query
      path              = "#{@basePath}?#{query}"
      @_request(path)

    #### Private #####

    _parseOpts: (opts)->
      return "" unless opts
      sql_opts =  _.map opts, (value, key)->
                    switch key
                      when "service_code", "status"
                        "#{key} IS #{value}"
                      when "start_date", "end_date"
                        "#{key} = #{value}"
      joined_opts   = sql_opts.join(" AND ")
      " AND " + joined_opts



    _noIdsGiven: -> @srIds.length is 0

    _request: (path)->
      {
        hostname: "data.cityofnewyork.us"
        port: 80
        path: path
        method: "GET"
      }

