module.exports = (app) ->
  class app.RequestsController

    # GET /requests.[format]?
    #
    # http://wiki.open311.org/GeoReport_v2#GET_Service_Request
    @index = (req, res) ->
      if req.query.service_request_id
        srIds = req.query.service_request_id.split(",")
        whereClause = "$where="

        # loop through and append to the $where clause
        srIds.forEach (srId) ->
          whereClause += "unique_key=%27" + srId + "%27%20OR%20"

        requestOptions =
          hostname: "data.cityofnewyork.us"
          port: 80

          # remove the last %20OR%20 and add it to the request path
          path: "/resource/erm2-nwe9.json?" + whereClause.slice(0, -8)
          method: "GET"


        # TODO: abstract out, DRY up the code
        # TODO: evaluate he other parameters and check for validity
        # TODO: construct SODA query
        request = http.request(requestOptions, (response) ->
          responseBody = ""
          response.on "data", (chunk) ->
            responseBody += chunk

          response.on "end", ->
            output convertToOpen311(JSON.parse(responseBody)), "service_requests", res, req.params.format

        )
        request.end()
      else
        res.send 404


    # GET /requests/[id].[format]
    #
    # Parse the request parameters and send them along to Socrata.
    #
    # see: http://wiki.open311.org/GeoReport_v2#GET_Service_Requests
    #
    # Arguments:
    #   service_request_id - comma-delimited
    #   service_code       - [default to all]
    #   start_date         - earliest, must not be more than 90 days from end_date
    #   end_date           - latest, must not be more than 90 days from start_date
    #   status             - comma-delimited ['open','closed']
    @show = (req, res) ->
      # res.render 'index', view: 'index'
      request = http.request(
        hostname: "data.cityofnewyork.us"
        port: 80
        path: "/resource/erm2-nwe9.json?$where=unique_key=%27" + req.params.uid + "%27"
        method: "GET"
      , (response) ->
        responseBody = ""
        response.on "data", (chunk) ->
          responseBody += chunk

        response.on "end", ->
          output convertToOpen311(JSON.parse(responseBody)), "service_requests", res, req.params.format

      )
      request.end()

