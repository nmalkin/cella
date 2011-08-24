# DEBUG
log = (message) ->
    $("#log").append message

# constants
OCCUPANCY_FIELD = '#occupancy'
BUILDING_MODE_FIELD = '#building-mode'
BUILDINGS_FIELD = '#select-buildings'
RESULTS_DIV = '#results'

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

# Returns a string with the HTML for a row in the table with the given room information
roomHTML = (room) ->
    "<tr id=\"room#{ room.id }\">
        <td>&#9734;</td>
        <td>#{ room.occupancy }</td>
        <td>#{ room.building}</td>
        <td>#{ room.room }</td>
        <td></td>
        <td></td>
    </tr>"

# Adds room with given room id to the table
addRoom = (roomID) ->
    if roomID of allRooms
        html = roomHTML allRooms[roomID]
    else
        roomsToLookUp.push roomID
        html = "<tr id=\"room#{ roomID }\"><td colspan=\"6\"></td></tr>"
    $(RESULTS_DIV).append html

# Looks up any rooms in the roomsToLookUp list
# and replaces their row in the results table with a fully populated one
lookUpRooms = ->
    if roomsToLookUp.length > 0
        $.getJSON 'room_info', 
            {ids: roomsToLookUp.join ','},
            (resultRooms) ->
                for room in resultRooms
                    allRooms[room.id] = room
                    $("#room#{ room.id }").replaceWith roomHTML room
                roomsToLookUp = []

# Updates the result table to show the given rooms
activateRooms = (rooms) ->
    activeRooms = rooms

    # add activated rooms to table
    $(RESULTS_DIV).html ''
    addRoom room for room in activeRooms
    lookUpRooms()

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
    # activate Chosen plugin
    $(".chzn-select").chosen()

    # populate building select with buildings
    populateBuildingSelect()


