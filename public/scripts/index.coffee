## DEBUG

log = (message...) ->
    console.log message

## CONSTANTS

MIN_LOTTERY_NUMBER = 1
MAX_LOTTERY_NUMBER = 800

LOTTERY_SLIDER = '#lottery'
LOTTERY_NUMBER_DISPLAY = '#lottery_number'
NEW_TAB_BUTTON = '#new_tab'
RESULT_TABS = '#result_tabs'
RESULT_TABLES = '#result_tables'
ROOM_TABLE = '.room_table'
RESULTS_DIV = '.results'
OCCUPANCY_FIELD = '.occupancy'
BUILDING_MODE_FIELD = '.building-mode'
BUILDINGS_FIELD = '.select-buildings'

# PARAMETERIZED CONSTANTS

TAB = (tabNumber) -> "#tab#{ tabNumber }"
    # NOTE: this scheme is also used in loadNewTab and getActivatedTab


## GLOBALS
# The number of tables/tabs currently open
tabCount = 0
# Number of the next tab to be created (numbers are not reused)
nextTabNumber = 0
# The number of the currently activated tab
activeTab = -1;
# The number of the previous activated tab
lastActiveTab = -1;
# An array of all campus areas
# Campus areas are objects with a name and an array of buildings
campusAreas = []
# All rooms whose information we have, referenced by id
allRooms = {}
# List of rooms currently displayed
activeRooms = []
# List of rooms that we need to look up
roomsToLookUp = []


## FUNCTIONS

# Downloads and saves campus areas and buildings from the server
downloadBuildings = ->
    $.getJSON 'campus_areas', (result) ->
        campusAreas = result

# Adds an option group to the building select box (given)
# with its value being the campus area
# and its options - the buildings
addCampusAreaToSelect = (select, campusArea, buildings) ->
    str = "<optgroup label=\"#{ campusArea }\">"
    str += "<option value=\"#{ building }\">#{ building }</option>" \
        for building in buildings
    str += "</optgroup>"
    
    select.append str

# Populates the building select field for the given tab
populateBuildingSelect = (tabNumber) ->
    buildingSelect = $(TAB tabNumber).find(BUILDINGS_FIELD)

    addCampusAreaToSelect buildingSelect, campusArea.name, \
        campusArea.buildings.sort() for campusArea in campusAreas
    
    # Tell the Chosen plugin that the select has been updated
    buildingSelect.trigger "liszt:updated"

# Returns an array with integer values for occupancy selected by the user
getChosenOccupancy = (tabNumber) ->
    value = $(TAB tabNumber).find(OCCUPANCY_FIELD).val() ? []
    parseInt occupancy for occupancy in value

# Returns true if the chosen buildings should be included, false if they should be excluded.
includeChosenBuildings = (tabNumber) ->
    building_mode = $(TAB tabNumber).find(BUILDING_MODE_FIELD).val()
    if building_mode == 'include'
        true
    else if building_mode == 'exclude'
        false
    else
        throw 'Illegal value in building mode field'

# Returns an array with the currently selected buildings
getChosenBuildings = (tabNumber) ->
    $(TAB tabNumber).find(BUILDINGS_FIELD).val() ? []

# Returns the number currently selected on the lottery number slider
getLotteryNumber = ->
    $(LOTTERY_SLIDER).slider('value')

# Computes the value at x of the logistic function with regression coefficients b0, b1
# That is 1/(1+e^-(b0 + b1*x)).
logit = (b0, b1, x) ->
    1 / (1 + Math.exp(-1 * (b0 + b1 * x)))

# Returns probability that given room is obtained under currently selected lottery number
# 'room' is a room object
# The probability returned is a value between 0 and 1.
getRoomProbability = (room, lotteryNumber) ->
    logit room.b0, room.b1, lotteryNumber

# Update probability of room with given ID based on given lottery number
updateRoomProbability = (roomID, lotteryNumber) ->
    if allRooms[roomID]?
        probability = getRoomProbability allRooms[roomID], lotteryNumber
        percentage = "#{ Math.round probability * 100 }%"
        $(".room#{ roomID }probability").text percentage

# Goes through all active rooms and updates their probabilities
# to match the currently selected lottery number
updateProbabilities = ->
    if activeTab != -1 and activeRooms[activeTab]?
        lotteryNumber = getLotteryNumber()
        for roomID in activeRooms[activeTab] # only update rooms in active tab
            updateRoomProbability roomID, lotteryNumber

# Returns a string with the HTML for a row in the table with the given room information
roomHTML = (room) ->
    "<tr class=\"room#{ room.id }\">
        <td>&#9734;</td>
        <td>#{ room.occupancy }</td>
        <td>#{ room.building}</td>
        <td>#{ room.room }</td>
        <td></td>
        <td class=\"room#{ room.id }probability\"></td>
        <td></td>
    </tr>"

# Adds room with given room id to the table
addRoom = (tabNumber, roomID) ->
    if roomID of allRooms
        html = roomHTML allRooms[roomID]
    else
        roomsToLookUp.push roomID
        html = "<tr class=\"room#{ roomID }\"><td colspan=\"7\"></td></tr>"
    $(TAB tabNumber).find(RESULTS_DIV).append html

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
                    $(".room#{ room.id }").replaceWith roomHTML room
                roomsToLookUp = []

                next()
    else
        next()

# Updates the result table to show the given rooms
# Calls next after it's done.
activateRooms = (tabNumber, rooms, next = ->) ->
    activeRooms[tabNumber] = rooms

    # add activated rooms to table
    $(TAB tabNumber).find(RESULTS_DIV).html ''
    addRoom tabNumber, room for room in activeRooms[tabNumber]
    lookUpRooms ->
        updateProbabilities()
        $(ROOM_TABLE).trigger 'update'
        next()

# Callback that gets called when the filter options are changed
filterChanged = (event) ->
    if activeTab != -1
        $.getJSON 'get_rooms',
            {
                occupancy: getChosenOccupancy(activeTab).join ','
                buildings: getChosenBuildings(activeTab).join ','
            },
            (resultRooms) ->
                activateRooms activeTab, resultRooms

# Returns the number of the newest tab that exists on the tab
# (i.e., ignoring deleted tabs)
# Returns -1 if there is no newest tab.
getNewestTab = ->
    i = nextTabNumber - 1
    while i >= 0 and $(TAB i).length == 0
        i--
    return i

# Deletes the table and tab with the given number
closeTab = (tabToDelete) ->
    # Remove the tab and its content
    $("#tab#{ tabToDelete }control").remove()
    $(TAB tabToDelete).remove()

    activeRooms[tabToDelete] = []

    tabCount--

    # If we're out of tables, create a new one.
    if tabCount == 0
        loadNewTab()
    # If current tab is being deleted, switch to last active tab,
    # or the newest one, if the last active one is no longer known.
    else if tabToDelete == activeTab
        nextTab = if lastActiveTab == -1 then getNewestTab() else lastActiveTab
        $("#tab#{ nextTab }control").children('a').trigger 'click'
        lastActiveTab = -1

# Creates a new tab and loads a new table into it
loadNewTab = () ->
    tabNumber = nextTabNumber

    nextTabNumber++
    tabCount++

    # Create a div to hold the table
    $(RESULT_TABLES).append "<div id=\"tab#{ tabNumber }\"></div>"

    # Load empty table into tab
    $(TAB tabNumber).load 'table.html', ->
        populateBuildingSelect tabNumber

        # Activate Chosen plugin for the new table
        $(".chzn-select").chosen()
 
        # activate TableSorter plugin
        $(TAB tabNumber).find(ROOM_TABLE).tablesorter
            debug: false
            textExtraction: 'simple'

        # Activate change listeners
        $(OCCUPANCY_FIELD).change filterChanged
        $(BUILDING_MODE_FIELD).change filterChanged
        $(BUILDINGS_FIELD).change filterChanged

    # Create a new tab for this table
    new_tab = $("<li id=\"tab#{ tabNumber }control\">
                <a href=\"#tab#{ tabNumber }\">
                Search #{ tabNumber + 1 }
                <span class=\"close_tab\" title=\"Close tab\">&#10006;</span>
                </a></li>")
    $(NEW_TAB_BUTTON).parent().before new_tab

    new_tab.find('.close_tab').click (-> closeTab tabNumber)

    # Show the table by triggering a click on (and thus activating) its tab
    new_tab.children('a').trigger 'click'

# Given a change event from a tab, returns the number of the tab activated
# Returns -1 if activated tab couldn't be detected
getActivatedTab = (event) ->
    targetString = $(event.target).attr 'href'
    re = new RegExp '#tab(\\d)'
    matches = re.exec targetString
    parseInt matches[1] ? -1

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

    $(NEW_TAB_BUTTON).click loadNewTab

    # When switching tabs, remember the currently active one
    $(RESULT_TABS).change (event) ->
        lastActiveTab = activeTab
        activeTab = getActivatedTab event
        # Also, make sure the probabilities are updated
        updateProbabilities()
    
    # Retrieve all buildings, which will then be used to populate select box
    downloadBuildings()

    # Create the first tab for the user
    loadNewTab()

