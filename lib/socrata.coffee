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

    respondWith: (requestOptions)->
      if @_noIdsGiven()
        # Return early
        @res.send 404
        return
      else
        # Proceed to fetch the data.
        @fetchData requestOptions

    _noIdsGiven: -> @srIds.length is 0

    buildRequestOpts: (ids=[])->
      @srIds = ids
      single_quoted_ids = _.map ids, (id)-> "%27#{id}%27"
      unique_keyed_ids  = _.map single_quoted_ids, (id)->"unique_key=#{id}"
      joined_keys        = unique_keyed_ids.join('%20OR%20')
      params            = joined_keys
      query             = "$where=" + params
      path              = "#{@basePath}?#{query}"
      @_reqOpts(path)


    _reqOpts: (path)->
      {
        hostname: "data.cityofnewyork.us"
        port: 80
        path: path
        method: "GET"
      }

    buildIndexReqOpts: (ids, req)->
      @srIds = ids
      whereClause = "$where="
      # Loop through and append to the $where clause
      ids.forEach (srId) ->
        whereClause += "unique_key=%27#{srId}%27%20OR%20"
      # Remove the last %20OR%20
      lastOr = whereClause.slice(0, -8)
      path = "#{@basePath}?#{lastOr}"
      @_reqOpts(path)
