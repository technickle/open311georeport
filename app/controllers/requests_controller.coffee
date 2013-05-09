module.exports = (app) ->
  class app.RequestsController
    # GET /requests.[format]?
    #
    # http://wiki.open311.org/GeoReport_v2#GET_Service_Request
    @index = (req, res) ->
      socrata = new app.Socrata(res, req)
      requestOptions = socrata.buildIndexReqOpts(req)
      socrata.respondWith(requestOptions)

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
      socrata = new app.Socrata(res, req)
      requestOptions = socrata.buildShowReqOpts(req)
      socrata.respondWith(requestOptions)
