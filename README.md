open311georeport
================
A nodejs adapter to access [NYC 311 SRs from Socrata](http://data.cityofnewyork.us/d/erm2-nwe9), using the [Open311 GeoReport v2 API](http://wiki.open311.org/GeoReport_v2).

Getting started
-------------------------
1. (fork)[https://github.com/technickle/open311georeport/fork] / clone this repository
2. install the [latest version of nodejs](http://nodejs.org/)
3. install [expressjs](http://expressjs.com/)

        npm install express

4. install [easyxml](https://github.com/QuickenLoans/node-easyxml)

        npm install easyxml

5. launch the API server. You may need to sudo if your login doesn't have permission to set up a network listener.

		node open311.js
		sudo node open311.js

6. make queries to the server (by default it listens on port 5000)

        curl -v localhost:5000/discovery.xml
		curl -v localhost:5000/requests/25454885.json
		curl -v localhost:5000/requests/25452652.xml
		curl -v localhost:5000/requests.json?service_request_id=25452652,25454885

7. See the [open311 georeport v2 documentation](http://wiki.open311.org/GeoReport_v2#GET_Service_Requests).
8. push your changes back to github, and issue a pull request for this repository

Known issues / To-dos
-------------------------
1. does not handle placename locations correctly yet
2. the Open311 entity models are inconsistent between XML and JSON, especially when it comes to arrays. So the present output works well for JSON but the XML output is not 100% compliant. There isn't really a way to fix this with the default implementation of easyXML.
3. ideally the code should be refactored to work more asynchronously, e.g. start the output while continuing to process input from Socrata. The Open311 spec allows for the processing of up to 1000 records per request, which will EASILY be achieved given NYC's volume of 40,000 SR updates per day.