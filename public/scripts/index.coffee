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

STAR_TAB = 0
STAR_FILLED = '&#9733;'
STAR_EMPTY = '&#9734;'

# PARAMETERIZED CONSTANTS

TAB = (tabNumber) -> "#tab#{ tabNumber }"
    # NOTE: this scheme is also used in loadNewTab and getActivatedTab


## GLOBALS
# The number of tables/tabs currently open
tabCount = 0
# Number of the next tab to be created (numbers are not reused)
nextTabNumber = 1 # starts at 1 because 0 is reserved for STAR_TAB
# The number of the currently activated tab
activeTab = -1;
# The number of the previous activated tab
lastActiveTab = -1;
# The occupancy selected in each tab
selectedOccupancy = []
# The buildings selected in each tab
selectedBuildings = []
# An array of all campus areas
# Campus areas are objects with a name and an array of buildings
campusAreas = []
# All rooms whose information we have, referenced by id
allRooms = {}
# Array of arrays; each is an array of rooms displayed in respective tab
activeRooms = []
activeRooms[STAR_TAB] = []
# List of rooms that we need to look up
roomsToLookUp = []


## FUNCTIONS

# Saves key->item in persistent storage
savePersistent = (key, item) ->
    sessionStorage.setItem key, JSON.stringify item

getPersistent = (key) ->
    item = sessionStorage.getItem key
    if item?
        JSON.parse item
    else
        null

# Loads buildings from storage (if available) or downloads them from the server
loadBuildings = ->
    campusAreas = getPersistent 'campusAreas'

    # If buildings haven't been saved yet, get them from the server
    if not campusAreas?
        $.getJSON 'campus_areas', (result) ->
            campusAreas = result
            savePersistent 'campusAreas', campusAreas

# Clears data in persistent storage and displays confirmation message
clearPersistent = () ->
    sessionStorage.clear()

    # Replace control with success message for a few seconds
    container = $(this)
    container.unbind 'click'
    currentContents = container.html()
    container.html '<span class="label success">Done</span>'
    window.setTimeout (-> 
        container.html currentContents
        container.bind 'click', clearPersistent
    ), 1500

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
    buildingSelect.trigger 'liszt:updated'

# Selects each given occupancy in this tab's select box
selectOccupancy = (tabNumber, occupancies) ->
    if tabNumber != -1 and occupancies? and occupancies.length > 0
        occupancySelect = $(TAB tabNumber).find(OCCUPANCY_FIELD)

        occupancySelect.find("option[value=\"#{ occupancy }\"]").attr('selected',
            'selected') for occupancy in occupancies

# Selects each of the given buildings in this tab's building select box
selectBuildings = (tabNumber, buildings) ->
    if tabNumber != -1 and buildings? and buildings.length > 0
        buildingSelect = $(TAB tabNumber).find(BUILDINGS_FIELD)

        buildingSelect.find("option[value=\"#{ building }\"]").attr('selected',
            'selected') for building in buildings

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
roomHTML = (room, filledStar=false) ->
    star = if filledStar then STAR_FILLED else STAR_EMPTY
    "<tr class=\"room#{ room.id }\">
        <td class=\"star\">#{ star }</td>
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
        isStarred = if activeRooms[STAR_TAB]? then \
            activeRooms[STAR_TAB].indexOf(roomID) != -1 else false
        html = roomHTML allRooms[roomID], isStarred
    else
        roomsToLookUp.push roomID
        html = "<tr class=\"room#{ roomID }\"><td colspan=\"7\"></td></tr>"
    $(TAB tabNumber).find(RESULTS_DIV).append html

# Removes room from tab
removeRoom = (tabNumber, roomID) ->
    $(TAB tabNumber).find(".room#{ roomID }").remove()

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

                roomsToLookUp = [] # no more rooms to look up (for now)

                # Update allRooms in storage
                savePersistent 'allRooms', allRooms

                next()
    else
        next()

# Updates the result table to show the given rooms
# Calls next after it's done.
activateRooms = (tabNumber, rooms, next = ->) ->
    activeRooms[tabNumber] = rooms
    savePersistent 'activeRooms', activeRooms

    # add activated rooms to table
    myTab = $(TAB tabNumber)
    myTab.find(RESULTS_DIV).html ''
    addRoom tabNumber, room for room in activeRooms[tabNumber]
    lookUpRooms ->
        myTab.find('.star').click toggleStar
        updateProbabilities()
        myTab.find(ROOM_TABLE).trigger 'update'
        next()

# Callback that gets called when the filter options are changed
filterChanged = (event) ->
    if activeTab != -1
        occupancy = getChosenOccupancy activeTab
        buildings = getChosenBuildings activeTab

        $.getJSON 'get_rooms',
            {
                occupancy: occupancy.join ','
                buildings: buildings.join ','
            },
            (resultRooms) ->
                activateRooms activeTab, resultRooms

        selectedOccupancy[activeTab] = occupancy 
        selectedBuildings[activeTab] = buildings
        savePersistent 'selectedOccupancy', selectedOccupancy
        savePersistent 'selectedBuildings', selectedBuildings

# Returns the ID of the room whose star was clicked 
# (or a similar event was generated)
# Return -1 if no match was found.
getRoomFromStarEvent = (event) ->
    roomRow = $(event.target).parent 'tr'
    if roomRow.length > 0
        roomString = roomRow.attr 'class'
        matches = (new RegExp 'room(\\d+)').exec roomString
        parseInt matches[1] ? -1
    else
        -1

# "Stars" the room with the given ID
# Starred rooms are saved and displayed in the "star" tab 
starRoom = (roomID) ->
    # Set a "starred" icon (for all rooms with this ID in all tables)
    $(".room#{ roomID }").children('.star').html STAR_FILLED

    # Remember this room as being starred
    if not activeRooms[STAR_TAB]?
        activeRooms[STAR_TAB] = []
    (activeRooms[STAR_TAB]).push roomID
    savePersistent 'activeRooms', activeRooms

    # Add this room to starred-result table
    addRoom STAR_TAB, roomID

    # Add toggle listener
    $(TAB STAR_TAB).find('.star').click toggleStar

# Undoes the starring of the given room
unstarRoom = (roomID) ->
    # Set "unstarred" icon
    $(".room#{ roomID }").children('.star').html STAR_EMPTY

    # Remove from list of starred rooms
    index = activeRooms[STAR_TAB].indexOf roomID
    if index == -1
        return
    activeRooms[STAR_TAB][index..index] = []
    savePersistent 'activeRooms', activeRooms

    # Remove this room from star-table
    removeRoom STAR_TAB, roomID


# Processes a click event and stars/unstars its room
toggleStar = (event) ->
    room = getRoomFromStarEvent event
    if room != -1
        isStarred = activeRooms[STAR_TAB].indexOf(room) != -1
        if isStarred
            unstarRoom room
        else
            starRoom room

# Returns the number of the newest tab that exists on the tab
# (i.e., ignoring deleted tabs)
# Returns -1 if there is no newest tab.
getNewestTab = ->
    i = nextTabNumber - 1
    while i >= 0 and $(TAB i).length == 0
        i--
    return i

# Activates the given tab by triggering a click on its tab control
activateTab = (tabNumber) ->
    $("#tab#{ tabNumber }control").children('a').trigger 'click'

# Deletes the table and tab with the given number
closeTab = (tabToDelete) ->
    # Remove the tab and its content
    $("#tab#{ tabToDelete }control").remove()
    $(TAB tabToDelete).remove()

    activeRooms[tabToDelete] = null
    savePersistent 'activeRooms', activeRooms

    tabCount--

    # If we're out of tables, create a new one.
    if tabCount == 0
        loadNewTab()
    # If current tab is being deleted, switch to last active tab,
    # or the newest one, if the last active one is no longer known.
    else if tabToDelete == activeTab
        nextTab = if lastActiveTab == -1 then getNewestTab() else lastActiveTab
        activateTab nextTab
        lastActiveTab = -1

# Creates a new tab with given tab number and loads a new table into it
loadTab = (tabNumber, next = ->) ->
    # Create a div to hold the table
    $(RESULT_TABLES).append "<div id=\"tab#{ tabNumber }\"></div>"

    # Load empty table into tab
    $(TAB tabNumber).load 'table.html', ->
        populateBuildingSelect tabNumber

        selectOccupancy tabNumber, selectedOccupancy[tabNumber]
        selectBuildings tabNumber, selectedBuildings[tabNumber]

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

        next()

    # Create a new tab for this table
    new_tab = $("<li id=\"tab#{ tabNumber }control\">
                <a href=\"#tab#{ tabNumber }\">
                Search #{ tabNumber }
                <span class=\"close_tab\" title=\"Close tab\">&#10006;</span>
                </a></li>")
    $(NEW_TAB_BUTTON).parent().before new_tab

    new_tab.find('.close_tab').click (-> closeTab tabNumber)

    activateTab tabNumber

# Creates a new tab with the next available tab number, call next when done
loadNewTab = (next) ->
    tabNumber = nextTabNumber

    nextTabNumber++
    tabCount++

    loadTab tabNumber, next

# Given a change event from a tab, returns the number of the tab activated
# Returns -1 if activated tab couldn't be detected
getActivatedTab = (event) ->
    targetString = $(event.target).attr 'href'
    re = new RegExp '#tab(\\d+)'
    matches = re.exec targetString
    parseInt matches[1] ? -1

# Loads application state from storage
# This includes rooms, open tabs, etc.
loadStateFromStorage = () ->
    t = getPersistent 'allRooms'
    allRooms = t if t?

    lotteryNumber = getPersistent 'lotteryNumber'
    if lotteryNumber?
        $(LOTTERY_NUMBER_DISPLAY).text lotteryNumber
        $(LOTTERY_SLIDER).slider('value', lotteryNumber)

    t = getPersistent 'selectedOccupancy'
    selectedOccupancy = t if t?
    t = getPersistent 'selectedBuildings'
    selectedBuildings = t if t?

    retrievedLastActiveTab = getPersistent 'lastActiveTab'
    retrievedActiveTab = getPersistent 'activeTab'

    # Load tabs
    t = getPersistent 'activeRooms'
    if t?
        activeRooms = t

        # Set aside starred rooms to process after all the tabs are created
        starredRooms = activeRooms[STAR_TAB]
        activeRooms[STAR_TAB] = null

        tabCount = 0
        nextTabNumber = 0

        (->
            if tab?
                tabCount++

                # Create function that, when called, activates this tab's rooms
                activateMyRooms = ( (tabToActivate) ->
                    () -> activateRooms tabToActivate, activeRooms[tabToActivate]
                ) nextTabNumber # avoids binding to nextTabNumber

                loadTab nextTabNumber, activateMyRooms

            nextTabNumber++
        )() for tab in activeRooms

        # Re-star the starred rooms
        if starredRooms?
            # TODO: this is a hacky way to make sure rooms are starred
            # only after all the tabs have been loaded.
            # What we really want is to have this wait on an event, or be in a callback.
            window.setTimeout (-> starRoom room for room in starredRooms), 250
        else
            activeRooms[STAR_TAB]= []

    lastActiveTab = retrievedLastActiveTab if retrievedLastActiveTab?
    activeTab = retrievedActiveTab if retrievedActiveTab?
    activateTab activeTab


$(document).ready ->
    # activate lottery number slider
    $(LOTTERY_SLIDER).slider {
        min: MIN_LOTTERY_NUMBER,
        max: MAX_LOTTERY_NUMBER,
        slide: (event, ui) ->
            $(LOTTERY_NUMBER_DISPLAY).text ui.value
            updateProbabilities()
            $(ROOM_TABLE).trigger 'update'
            savePersistent 'lotteryNumber', ui.value
    }

    $(NEW_TAB_BUTTON).click loadNewTab

    $('#clear_data').click clearPersistent

    # When switching tabs, remember the currently active one
    $(RESULT_TABS).change (event) ->
        lastActiveTab = activeTab
        activeTab = getActivatedTab event

        savePersistent 'lastActiveTab', lastActiveTab
        savePersistent 'activeTab', activeTab

        # Also, make sure the probabilities are updated
        updateProbabilities()
    
    # Retrieve all buildings, which will then be used to populate select box
    loadBuildings()

    loadStateFromStorage()

    # If there are no tabs, create one
    if tabCount == 0
        # But switch back to the star-tab if it's activated
        next = if activeTab == STAR_TAB then (-> activateTab STAR_TAB) else (->)
        loadNewTab next


    
