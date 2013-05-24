open311georeport
================
A nodejs adapter to access [NYC 311 SRs from Socrata](http://data.cityofnewyork.us/d/erm2-nwe9), using the [Open311 GeoReport v2 API](http://wiki.open311.org/GeoReport_v2).

Getting started
-------------------------
1. Clone this repository

2. Install the [latest version of nodejs](http://nodejs.org/)

3. Install the dependencies

        npm install

4. Launch the API server. (You may need to sudo if your login doesn't have permission to set up a network listener.)

        node server.js
        sudo node server.js

5. Make queries to the server (by default it listens on port 3000)

        curl -v localhost:3000/discovery.xml
        curl -v localhost:3000/requests/25454885.json
        curl -v localhost:3000/requests/25452652.xml
        curl -v localhost:3000/requests.json?service_request_id=25452652,25454885


Contributing
-------------------------

1. See the [open311 georeport v2 documentation](http://wiki.open311.org/GeoReport_v2#GET_Service_Requests).

2. Add your code into the lib folder

3. Send a pull request.


Known issues / To-dos
-------------------------
* Does not handle placename locations correctly yet
