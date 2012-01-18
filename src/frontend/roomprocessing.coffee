## Functions having to do with processing rooms:
#  looking them up, activating them

# Performs a query to find the rooms according to the criteria in the filters
# of the given tab.
findSelectedRooms = (tab) ->
    occupancy = getChosenOccupancy tab
    buildings = getChosenBuildings tab
    includeBuildings = includeChosenBuildings tab

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

    myTab = $(TAB tabNumber)

    # add activated rooms to table
    if activeRooms[tabNumber].length == 0
        myTab.find(RESULTS_DIV).html NO_RESULT_PLACEHOLDER_MESSAGE 
        next()
    else
        myTab.find(RESULTS_DIV).html ''
        addRoom tabNumber, room for room in activeRooms[tabNumber]
        lookUpRooms ->
            myTab.find('.star').click toggleStar
            updateProbabilities()
            myTab.find(ROOM_TABLE).trigger 'update'
            next()
