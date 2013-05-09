# module.exports = (app) ->
#   # Your code
#
#
# Or if you want this to be a class
#
# module.exports = (app) ->
#   class app.MyCustomClass
#
#     constructor: (args) ->
#       # Your code
#
# Usage: new app.MyCustomClass(args)
class App.Open311Adapter
  initialize: ->

# configure easyxml to output <?xml ... ?> as the first line
# helper function to output xml or json
# really should fix this so it doesn't process queries first
output = (obj,rootElement,res,format)->
  # if obj has no elements then return a 404 error!
  if obj.length is 0
    res.send 404, "not found"
  else
    switch format
      when "json"
        res.type = "application/json"
        res.send obj
      when "xml" #TODO: fix XML output in SR array <0>,<1> etc*********
        res.setHeader "Content-Type", "text/xml; charset=utf-8"
        res.send xmlout.render(obj, rootElement)
      else
        res.send 404, ".xml or .json expected"

#helper function to parse an array of socrata dataset records into an Open311-compatible output
convertToOpen311 = (srArray) ->
  results = []
  srArray.forEach (obj) ->
    address = undefined
    switch obj.address_type
      when "ADDRESS"
        address = obj.incident_address + " " + obj.city + " NY"
      when "INTERSECTION"
        address = obj.intersection_street_1 + " @ " + obj.intersection_street_2 + ", " + obj.borough + " NY"
      when "PLACENAME"
        address = null #TODO
      else
        address = null
    results.push
      service_request_id: obj.unique_key
      status: obj.status.toLowerCase()
      status_notes: null
      service_name: obj.complaint_type + ": " + obj.descriptor
      service_code: null
      description: obj.complaint_type + ": " + obj.descriptor
      agency_responsible: obj.agency_name
      service_notice: null
      requested_datetime: obj.created_date #ISO 8601
      updated_datetime: obj.resolution_action_updated_date or null
      expected_datetime: obj.due_date or null
      address: address
      address_id: null
      zipcode: obj.incident_zip or null
      lat: obj.latitude or null
      long: obj.longitude or null #quoted because long is a JS type
      media_url: null
  results

express = require("express")
http = require("http")
xmlout = require("easyxml")
app = express()
xmlout.config.manifest = true
discovery =
  changeset: "2013-05-01 12:00:00"
  contact: "E-mail dev-support@platform.nyc.gov or visit developer.cityofnewyork.us for more information."
  key_service: "You can request a key at developer.cityofnewyork.us."
  endpoints: [
    specification: "http://wiki.open311.org/GeoReport_v2"
    url: "https://api.cityofnewyork.us/open311/v1"
    changeset: "2013-05-01 12:00:00"
    type: "production"
    formats: ["text/xml", "application/json"]
  ]


#GET /discovery.[format]
# http://wiki.open311.org/Service_Discovery
app.get "/discovery.:format", (req, res) ->
  output discovery, "discovery", res, req.params.format


#GET /requests/[id].[format]
# http://wiki.open311.org/GeoReport_v2#GET_Service_Request
app.get "/requests/:uid.:format", (req, res) ->
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


#GET /requests.[format]?
#  http://wiki.open311.org/GeoReport_v2#GET_Service_Requests
#   service_request_id: comma-delimited
#   service_code: [default to all]
#   start_date: earliest, must not be more than 90 days from end_date
#   end_date: latest, must not be more than 90 days from start_date
#   status: comma-delimited ['open','closed']
app.get "/requests.:format?", (req, res) ->
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


#http response errors:
#  403 missing API key
#   400 invalid request
#   404 resource doesn't exist
# app.listen process.env.PORT or 5000