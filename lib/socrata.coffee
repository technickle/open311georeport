_ = require("underscore")
module.exports = (app) ->
  class app.Socrata
    constructor: (res, req)->
      @res = res
      @req = req
      @basePath = "/resource/erm2-nwe9.json"

    fetchData: (requestOptions)->
      [res, req] = [@res, @req]

      # TODO: evaluate the other parameters and check for validity
      # TODO: construct SODA query
      http = require 'http'
      request = http.request(requestOptions, (response) ->
        responseBody = ""
        response.on "data", (chunk) ->
          responseBody += chunk
        response.on "end", ->
          adapter = new app.Adapter(responseBody)
          adapter.respond(res, req)
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

    buildRequest: (ids=[])->
      @srIds = ids
      single_quoted_ids = _.map ids, (id)-> "%27#{id}%27"
      unique_keyed_ids  = _.map single_quoted_ids, (id)->"unique_key=#{id}"
      joined_keys        = unique_keyed_ids.join('%20OR%20')
      params            = joined_keys
      query             = "$where=" + params
      path              = "#{@basePath}?#{query}"
      @_request(path)
      
    #### Private #####

    _noIdsGiven: -> @srIds.length is 0

    _request: (path)->
      {
        hostname: "data.cityofnewyork.us"
        port: 80
        path: path
        method: "GET"
      }

