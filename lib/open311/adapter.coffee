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
xmlout = require("easyxml")
xmlout.config.manifest = true

#http response errors:
#  403 missing API key
#   400 invalid request
#   404 resource doesn't exist
# app.listen process.env.PORT or 5000

module.exports = (app) ->
  class app.Open311Adapter
    initialize: ->

    # Configure easyxml to output <?xml ... ?> as the first line
    # helper function to output xml or json
    # really should fix this so it doesn't process queries first
    output: (obj,rootElement,res,format)->
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

    # Helper function to parse an array of socrata dataset records into an Open311-compatible output
    convertToOpen311: (srArray) ->
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



