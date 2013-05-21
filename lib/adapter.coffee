module.exports = (app) ->
  class app.Adapter
    constructor: (responseBody)->
      try
        @response = JSON.parse(responseBody)
      catch e
        @response = responseBody



    # Transform Socrata data into Open311 data
    # @returns array
    convertToOpen311: ->
      results = []
      @response.forEach (obj) ->
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