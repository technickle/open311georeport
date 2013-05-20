module.exports = (app) ->
  class app.Socrata
    constructor: (res, req)->
      @res = res
      @req = req
      sri = req.query.service_request_id
      @srIds = if sri then sri.split(",") else []
      @basePath = "/resource/erm2-nwe9.json?"

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

    _noIdsGiven: ->
      @srIds.length is 0 and @type is "index"

    buildShowReqOpts: (req)->
      uid = req.params.uid
      requestPath = "#{@basePath}?$where=unique_key=%27#{uid}%27"
      @_reqOpts(requestPath)

    buildIndexReqOpts: (req)->
      whereClause = "$where="
      # Loop through and append to the $where clause
      @srIds.forEach (srId) ->
        whereClause += "unique_key=%27#{srId}%27%20OR%20"
      # Remove the last %20OR%20
      lastOr = whereClause.slice(0, -8)
      requestPath = "#{@basePath}?#{lastOr}"
      @_reqOpts(requestPath)

    _reqOpts: (requestPath)->
      {
        hostname: "data.cityofnewyork.us"
        port: 80
        path: requestPath
        method: "GET"
      }
