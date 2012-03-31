http = require 'http'
util = require 'util'
jsdom = require 'jsdom'

TABLES = ['.columnOne', '.columnTwo', '.columnThree']
EXTRA_BUILDINGS = ["Buxton", "315 Thayer", "Littlefield Hall", "Hegeman"]

buildings = require('../buildings').names
buildings = buildings.concat EXTRA_BUILDINGS

rooms = []

# Called to record the status of a room
# building: name of building
# room: room number (string)
# status: true if available, false if not
recordRoomStatus = (building, room, status) ->
    room = {
        building: currentBuilding
        room: entry
        available: available
    }

    rooms.push room

# Is this a known building?
knownBuilding = (candidate) ->
    -1 != BUILDINGS.indexOf candidate

# Get the HTML for the given tab number and call cb with it
loadTab = (tabNumber, cb = ->) ->
    options =
        host: 'www.brown.edu',
        port: 80,
        path: '/Student_Services/Residential_Council/lottery/broadcast/lottery_tab.php?tab=' + tabNumber,
        method: 'GET'
    
    page = null

    req = http.request options, (res) ->
        res.setEncoding 'utf8'
        res.on 'data', (chunk) ->
            page += chunk
        res.on 'end', -> cb page
    req.on 'error', (err) -> util.debug err
    req.end()

# Extract rooms, availability from table
# window: DOM window
# table: ID of table to parse
# cb: called after completion
processTable = (window, table, cb = ->) ->
        # Extract the text
        txt = window.$(table).text()

        # Get rid of whitespace, separate rooms with commas
        re = /[\r\n\t]+/g
        txt = txt.replace re, ','

        # Tokenize
        data = txt.split ','

        # Extract rooms, identify buildings
        currentBuilding = null
        roomExp = /^\w?\d+\w?$/
        for entry in data
            # Is this a room?
            if roomExp.test entry
                # Find its availability by checking its class
                status = window.$("td:contains('#{ currentBuilding }')")
                    .parent().nextAll()
                    .children("td:contains('#{ entry }')")
                    .attr 'class'

                if status == 'liveRoomBox'
                    available = true
                else if status == 'deadRoomBox'
                    available = false
                else
                    util.debug "Unknown class '#{ status }' for #{ currentBuilding } #{ entry }"

                recordRoomStatus currentBuilding, entry, available
                
            # Is it a known building?
            else if knownBuilding entry
                currentBuilding = entry

        cb()

# Extracts rooms, availability from given HTML page
processTab = (html, cb = ->) ->
    # Build a DOM window from the HTML
    jsdom.env html, ['http://code.jquery.com/jquery-1.7.2.min.js'], (err, window) ->
        processColumn window, table for table in TABLES
        cb()


# Load data
# TODO: should happen repeatedly
loadTab tab, processTab for tab in [1..6]
