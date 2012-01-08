# DEBUG
log = (message) ->
    console.log message

# constants
OCCUPANCY_FIELD = '#occupancy'
BUILDING_MODE_FIELD = '#building-mode'
BUILDINGS_FIELD = '#select-buildings'
ROOM_TABLE = '#room_table'
RESULTS_DIV = '#results'
LOTTERY_SLIDER = '#lottery'
LOTTERY_NUMBER_DISPLAY = '#lottery_number'

MIN_LOTTERY_NUMBER = 1
MAX_LOTTERY_NUMBER = 800

# All rooms whose information we have, referenced by id
allRooms = {}
# List of rooms currently displayed
activeRooms = []
# List of rooms that we need to look up
roomsToLookUp = []

# Populates the building select field
populateBuildingSelect = ->
    $.getJSON 'campus_areas', (campusAreas) ->
        addCampusAreaToSelect campusArea.name, campusArea.buildings.sort() for campusArea in campusAreas
        
        # Tell the Chosen plugin that the select has been updated
        $(BUILDINGS_FIELD).trigger "liszt:updated"

# Adds an option group to the building select box
# with its value being the campus area
# and its options - the buildings
addCampusAreaToSelect = (campusArea, buildings) ->
    str = "<optgroup label=\"#{ campusArea }\">"
    str += "<option value=\"#{ building }\">#{ building }</option>" for building in buildings
    str += "</optgroup>"
    $(BUILDINGS_FIELD).append str

# DEPRECATED
# Add an option with the given building to the building select box
addBuildingToSelect = (building) ->
    option_string = "<option value=\"#{ building }\">#{ building }</option>"
    $(BUILDINGS_FIELD).append option_string

# Returns an array with integer values for occupancy selected by the user
getChosenOccupancy = ->
    value = $(OCCUPANCY_FIELD).val() ? []
    parseInt occupancy for occupancy in value

# Returns true if the chosen buildings should be included, false if they should be excluded.
includeChosenBuildings = ->
    building_mode = $(BUILDING_MODE_FIELD).val()
    if building_mode == 'include'
        true
    else if building_mode == 'exclude'
        false
    else
        throw 'Illegal value in building mode field'

# Returns an array with the currently selected buildings
getChosenBuildings = ->
    $(BUILDINGS_FIELD).val() ? []

# Returns the number currently selected on the lottery number slider
getLotteryNumber = ->
    $(LOTTERY_SLIDER).slider('value')

# Computes the value at x of the logistic function with regression coefficients b0, b1
# That is 1/(1+e^-(b0 + b1*x)).
logit = (b0, b1, x) ->
    1 / (1 + Math.exp(-1 * (b0 + b1 * x)))

# Returns the probability that the given room is obtained under the currently selected lottery number
# 'room' is a room object
# The probability returned is a value between 0 and 1.
getRoomProbability = (room, lotteryNumber) ->
    logit room.b0, room.b1, lotteryNumber

updateRoomProbability = (roomID, lotteryNumber) ->
    probability = getRoomProbability allRooms[roomID], lotteryNumber
    percentage = "#{ Math.round probability * 100 }%"
    $("#room#{ roomID }probability").text percentage
        

# Goes through all active rooms and updates their probabilities
# to match the currently selected lottery number
updateProbabilities = ->
    lotteryNumber = getLotteryNumber()
    for roomID in activeRooms
        updateRoomProbability roomID, lotteryNumber

# Returns a string with the HTML for a row in the table with the given room information
roomHTML = (room) ->
    "<tr id=\"room#{ room.id }\">
        <td>&#9734;</td>
        <td>#{ room.occupancy }</td>
        <td>#{ room.building}</td>
        <td>#{ room.room }</td>
        <td></td>
        <td id=\"room#{ room.id }probability\"></td>
        <td></td>
    </tr>"

# Adds room with given room id to the table
addRoom = (roomID) ->
    if roomID of allRooms
        html = roomHTML allRooms[roomID]
    else
        roomsToLookUp.push roomID
        html = "<tr id=\"room#{ roomID }\"><td colspan=\"7\"></td></tr>"
    $(RESULTS_DIV).append html

# Looks up any rooms in the roomsToLookUp list
# and replaces their row in the results table with a fully populated one
# Calls next after it's done.
lookUpRooms = (next = ->)->
    if roomsToLookUp.length > 0
        $.getJSON 'room_info', 
            {ids: roomsToLookUp.join ','},
            (resultRooms) ->
                for room in resultRooms
                    allRooms[room.id] = room
                    $("#room#{ room.id }").replaceWith roomHTML room
                roomsToLookUp = []

                next()
    else
        next()

# Updates the result table to show the given rooms
# Calls next after it's done.
activateRooms = (rooms, next = ->) ->
    activeRooms = rooms

    # add activated rooms to table
    $(RESULTS_DIV).html ''
    addRoom room for room in activeRooms
    lookUpRooms ->
        updateProbabilities()
        $(ROOM_TABLE).trigger 'update'
        next()

# Callback that gets called when the filter options are changed
filterChanged = (event) ->
    $.getJSON 'get_rooms',
        {
            occupancy: getChosenOccupancy().join ','
            buildings: getChosenBuildings().join ','
        },
        (resultRooms) ->
            activateRooms resultRooms


$(OCCUPANCY_FIELD).change filterChanged
$(BUILDING_MODE_FIELD).change filterChanged
$(BUILDINGS_FIELD).change filterChanged

$(document).ready ->
    # activate lottery number slider
    $(LOTTERY_SLIDER).slider {
        min: MIN_LOTTERY_NUMBER,
        max: MAX_LOTTERY_NUMBER,
        slide: (event, ui) ->
            $(LOTTERY_NUMBER_DISPLAY).text ui.value
            updateProbabilities()
            $(ROOM_TABLE).trigger 'update'
    }

    # activate Chosen plugin
    $(".chzn-select").chosen()
    
    # activate TableSorter plugin
    $(ROOM_TABLE).tablesorter
        debug: false
        textExtraction: 'simple'
    
    # populate building select with buildings
    populateBuildingSelect()

