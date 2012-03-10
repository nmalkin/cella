## Functions that deal with the process of starring rooms.

# "Stars" the room with the given ID
# Starred rooms are saved and displayed in the "star" tab 
starRoom = (roomID) ->
    # Set a "starred" icon (for all rooms with this ID in all tables)
    $(ROOM roomID).children('.star').html STAR_FILLED

    # Remember this room as being starred
    if not activeRooms[STAR_TAB]?
        activeRooms[STAR_TAB] = []
    (activeRooms[STAR_TAB]).push roomID
    savePersistent 'activeRooms', activeRooms

    # Add this room to starred-result table
    addRoom STAR_TAB, roomID

# Undoes the starring of the given room
unstarRoom = (roomID) ->
    # Set "unstarred" icon
    $(ROOM roomID).children('.star').html STAR_EMPTY

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

            # If no rooms are left in the star tab, display placeholder message
            if activeRooms[STAR_TAB].length == 0
                showStarPlaceholderMessage()
        else
            # If the placeholder message is there, remove it
            # (now that there are some rooms in the list)
            if activeRooms[STAR_TAB].length == 0
                clearStarPlaceholderMessage()

            starRoom room

# Displays placeholder message in the star tab
showStarPlaceholderMessage = () ->
    $(TAB STAR_TAB).find(RESULTS_DIV).html STAR_PLACEHOLDER_MESSAGE

# Clears the placeholder message from the star tab
clearStarPlaceholderMessage = () ->
    $(TAB STAR_TAB).find(RESULTS_DIV).html ''
