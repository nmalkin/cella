## Functions that deal with the process of starring rooms.

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


