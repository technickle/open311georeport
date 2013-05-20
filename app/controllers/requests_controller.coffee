module.exports = (app) ->
  class app.RequestsController
    # GET /requests.[format]?
    @getServiceRequests = (req, res) ->
      socrata = new app.Socrata(res, req)
      requestOptions = socrata.buildIndexReqOpts(req)
      socrata.respondWith(requestOptions)

    # GET /requests/[id].[format]
    @show = (req, res) ->
      socrata = new app.Socrata(res, req)
      requestOptions = socrata.buildShowReqOpts(req)
      socrata.respondWith(requestOptions)
