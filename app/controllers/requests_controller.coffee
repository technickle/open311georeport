module.exports = (app) ->
  class app.RequestsController
    # GET /requests.[format]?
    @getServiceRequests = (req, res) ->
      socrata = new app.Socrata(res, req)
      sri     = req.query.service_request_id
      ids     = if sri then sri.split(",") else []
      options = socrata.buildRequest(ids)
      socrata.callWith(options)

    # GET /requests/[id].[format]
    @show = (req, res) ->
      socrata = new app.Socrata(res, req)
      ids     = [req.params.uid]
      options = socrata.buildRequest(ids)
      socrata.callWith(options)
