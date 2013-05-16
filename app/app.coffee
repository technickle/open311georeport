# Modules
express = require 'express'
http = require 'http'
partials = require 'express-partials'
app = express()
# swagger = require('swagger-jack')

# Boot setup
require("#{__dirname}/../config/boot")(app)

# Configuration
app.configure ->
  port = process.env.PORT || 3000
  if process.argv.indexOf('-p') >= 0
    port = process.argv[process.argv.indexOf('-p') + 1]

  app.set 'port', port
  app.set 'views', "#{__dirname}/views"
  app.set 'view engine', 'ejs'
  app.use express.static("#{__dirname}/../public")
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use partials()
  app.use require('connect-assets')(src: "#{__dirname}/assets")
  app.use app.router
  # gen = swagger.generator(app, { apiVersion: '1.0', basePath: 'http://localhost:3000/'}, [{
  #           api:
  #             resourcePath: '/requests'
  #             apis: [
  #               path: '/'
  #               operations: [
  #                 {
  #                   httpMethod: 'GET'
  #                   nickname: 'show'
  #                 }
  #                 {
  #                   httpMethod: 'GET'
  #                   nickname: 'index'
  #                 }
  #               ]
  #             ]
  #           controller:
  #             show: app.RequestsController.show
  #             index: app.RequestsController.index
  #         }])
  # app.use(gen)
  # app.use(swagger.validator(app))
  # app.use(swagger.errorHandler())

app.configure 'development', ->
  app.use express.errorHandler()

# Routes
require("#{__dirname}/routes")(app)

# Server
http.createServer(app).listen app.get('port'), ->
  console.log "Express server listening on port #{app.get 'port'} in #{app.settings.env} mode"
