module.exports = (app) ->
  class app.Socrata
    initialize: (res, req)->
      [@res, @req] = [res, req]

      @srIds = if req.query.service_request_id
          req.query.service_request_id.split(",")
        else
          null

    fetchData: (requestOptions)->
      [res, req] = [@res, @req]

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

    respond: (type)->
      requestOptions = switch type
        when "index"
          @_indexReqOpts()
        when "show"
          @_showReqOpts()

      # Return eraly if no ids are specified for the index request
      if @srIds is null and type is "index"
        @res.send 404
        return

      # For all others, proceed to fetch the data.
      @fetchData(requestOptions)

    _showReqOpts: ->
      {
        hostname: "data.cityofnewyork.us"
        port: 80
        path: "/resource/erm2-nwe9.json?$where=unique_key=%27" + @req.params.uid + "%27"
        method: "GET"
      }

    _indexReqOpts: ->
      whereClause = "$where="

      # Loop through and append to the $where clause
      @srIds.forEach (srId) ->
        whereClause += "unique_key=%27" + srId + "%27%20OR%20"
      # Remove the last %20OR%20
      lastOr = whereClause.slice(0, -8)
      requestOptions =
        hostname: "data.cityofnewyork.us"
        port: 80
        path: "/resource/erm2-nwe9.json?" + lastOr
        method: "GET"