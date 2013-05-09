module.exports = (app) ->
  app.get '/', app.ApplicationController.index
  app.get '/requests.:format?', app.RequestsController.index
  app.get '/requests/:uid.:format', app.RequestsController.show
  


  # Error handling (No previous route found. Assuming it’s a 404)
  app.get '/*', (req, res) ->
    NotFound res

  NotFound = (res) ->
    res.render '404', status: 404, view: 'four-o-four'