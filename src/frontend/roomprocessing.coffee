## Functions having to do with processing rooms:
#  looking them up, activating them

# Given a room result row, extracts the ID of the given room
# (More generally, takes an element whose class identifies a room.)
# e.g., <tr class="room1234">...</tr> -> 1234
# Returns -1 if there was a problem with the parsing.
getRoomFromRow = (roomRow) ->
    roomString = roomRow.attr 'class'
    matches = (new RegExp NAME ROOM '(\\d+)').exec roomString
    return if matches? then parseInt matches[1] ? -1 else -1

# Performs a query to find the rooms according to the criteria in the filters
# of the given tab.
findSelectedRooms = (tab) ->
    occupancy = getChosenOccupancy tab
    buildings = getChosenBuildings tab
    includeBuildings = includeChosenBuildings tab

    if noResultsPossible tab
        activateRooms tab, []
    else
        $.getJSON 'get_rooms',
            {
                occupancy: occupancy.join ','
                buildings: buildings.join ','
                include_buildings: includeBuildings 
                sophomore: isSophomore()
            },
            (resultRooms) ->
                activateRooms tab, resultRooms

    selectedOccupancy[tab] = occupancy 
    selectedBuildings[tab] = buildings
    selectedIncludes[tab] = includeBuildings
    savePersistent 'selectedOccupancy', selectedOccupancy
    savePersistent 'selectedBuildings', selectedBuildings
    savePersistent 'selectedIncludes', selectedIncludes 

# Looks up any rooms in the roomsToLookUp list
# Calls next with list of rooms successfully looked up.
lookUpRooms = (next = ->)->
    if roomsToLookUp.length > 0
        $.getJSON 'room_info', 
            {ids: roomsToLookUp.join ','},
            (resultRooms) ->
                # Store the rooms that were successfully looked up
                for room in resultRooms
                    allRooms[room.id] = room

                # Update allRooms in storage
                savePersistent 'allRooms', allRooms

                roomsToLookUp = [] # no more rooms to look up (for now)

                next resultRooms
    else
        next []

# Updates the result table to show the given rooms
# Calls next after it's done.
activateRooms = (tabNumber, rooms, next = ->) ->
    activeRooms[tabNumber] = rooms
    savePersistent 'activeRooms', activeRooms

    myTab = $(TAB tabNumber)

    # add activated rooms to table
    if activeRooms[tabNumber].length == 0
        if noResultsPossible tabNumber
            message = NO_RESULT_POSSIBLE_PLACEHOLDER_MESSAGE 
        else
            message = NO_RESULT_PLACEHOLDER_MESSAGE 

        myTab.find(RESULTS_DIV).html message
        myTab.find(ROOM_TABLE).trigger 'update'
        next()
    else
        myTab.find(RESULTS_DIV).html ''
        addRoom tabNumber, room for room in activeRooms[tabNumber]
        lookUpRooms (lookedUpRooms) ->
            # Display the looked up rooms
            for room in lookedUpRooms
                $(ROOM room.id).replaceWith roomHTML room
                initResultPopover room

            updateProbabilities null, true

            # Update TableSorter with new information
            myTab.find(ROOM_TABLE).trigger 'update'

            next()

# Gets previous results for given room and calls cb with them as argument
getResults = (roomID, cb) ->
    if roomID of roomResults
        cb roomResults[roomID]
    else
        $.getJSON 'results', {id: roomID}, (results) ->
            roomResults[roomID] = results
            savePersistent 'roomResults', roomResults
            cb results
