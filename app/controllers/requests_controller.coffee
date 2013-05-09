module.exports = (app) ->
  class app.RequestsController
    # GET /requests.[format]?
    #
    # http://wiki.open311.org/GeoReport_v2#GET_Service_Request
    @index = (req, res) ->
      socrata = new app.Socrata(res, req)
      socrata.respond()
      
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

      request = http.request(
        hostname: "data.cityofnewyork.us"
        port: 80
        path: "/resource/erm2-nwe9.json?$where=unique_key=%27" + req.params.uid + "%27"
        method: "GET"
      , (response) ->
        responseBody = ""
        response.on "data", (chunk) -> responseBody += chunk
        response.on "end", ->
          adapter = new app.Adapter(responseBody)
          adapter.respond(res, req)
      )
      request.end()

