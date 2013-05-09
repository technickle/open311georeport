module.exports = (app) ->
  class app.Socrata
    initialize: (res, req)->
      @res = res
      @req = req
      @srIds = if req.query.service_request_id
          req.query.service_request_id.split(",")
        else
          null

    fetchData: (res, req)->
      requestOptions = @_buildReqOpts()

      # TODO: evaluate the other parameters and check for validity
      # TODO: construct SODA query
      request = http.request(requestOptions, (response) ->
        responseBody = ""
        response.on "data", (chunk) ->
          responseBody += chunk
        response.on "end", ->
          adapter = new app.Adapter(responseBody)
          adapter.respond(res, req)
      )
      request.end()

    respond: ->
      if @srIds
        @fetchData(@res, @req)
      else
        @res.send 404

    _buildReqOpts: ->
      whereClause = "$where="
      # loop through and append to the $where clause
      @srIds.forEach (srId) ->
        whereClause += "unique_key=%27" + srId + "%27%20OR%20"

      requestOptions =
        hostname: "data.cityofnewyork.us"
        port: 80
        # remove the last %20OR%20 and add it to the request path
        path: "/resource/erm2-nwe9.json?" + whereClause.slice(0, -8)
        method: "GET"