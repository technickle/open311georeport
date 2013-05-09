exports.output = output = (obj, rootElement, res, format)->
  xmlout = require("easyxml")
  xmlout.config.manifest = true
  # if obj has no elements then return a 404 error!
  if obj.length is 0
    res.send 404, "not found"
  else
    switch format
      when "json"
        res.type = "application/json"
        res.send obj
      when "xml"
        # TODO: fix XML output in SR array <0>,<1> etc*********
        res.setHeader "Content-Type", "text/xml; charset=utf-8"
        res.send xmlout.render(obj, rootElement)
      else
        res.send 404, ".xml or .json expected"