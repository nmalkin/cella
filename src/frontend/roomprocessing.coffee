## Functions having to do with processing rooms:
#  looking them up, activating them

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
