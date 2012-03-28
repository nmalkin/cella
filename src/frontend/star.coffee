## Functions that deal with the process of starring rooms.

# "Stars" the room with the given ID
# Starred rooms are saved and displayed in the "star" tab 
starRoom = (roomID) ->
    if not roomID of _allRooms then return # An invalid ID has snuck in somehow. Ignore it.

    # Set a "starred" icon (for all rooms with this ID in all tables)
    $(ROOM roomID).children('.star').html STAR_FILLED

    # Remember this room as being starred
    if not _activeRooms[STAR_TAB]?
        _activeRooms[STAR_TAB] = []
    (_activeRooms[STAR_TAB]).push roomID
    savePersistent '_activeRooms', _activeRooms

    # Add this room to starred-result table
    addRoom STAR_TAB, roomID

# Undoes the starring of the given room
unstarRoom = (roomID) ->
    # Set "unstarred" icon
    $(ROOM roomID).children('.star').html STAR_EMPTY

    # Remove from list of starred rooms
    index = _activeRooms[STAR_TAB].indexOf roomID
    if index == -1 then return
    _activeRooms[STAR_TAB][index..index] = []
    savePersistent '_activeRooms', _activeRooms

    # Remove this room from star-table
    removeRoom STAR_TAB, roomID


# Processes a click event and stars/unstars its room
toggleStar = (event) ->
    room = getRoomFromStarEvent event
    if room != -1
        isStarred = _activeRooms[STAR_TAB].indexOf(room) != -1
        if isStarred
            unstarRoom room

            # If no rooms are left in the star tab, display placeholder message
            if _activeRooms[STAR_TAB].length == 0
                showStarPlaceholderMessage()
        else
            # If the placeholder message is there, remove it
            # (now that there are some rooms in the list)
            if _activeRooms[STAR_TAB].length == 0
                clearStarPlaceholderMessage()

            starRoom room

        updateStarredRoomURL()

        # Star status has changed, so update TableSorter
        $(ROOM_TABLE).trigger 'update'

# Displays placeholder message in the star tab
showStarPlaceholderMessage = () ->
    $(TAB STAR_TAB).find(RESULTS_DIV).html STAR_PLACEHOLDER_MESSAGE

# Clears the placeholder message from the star tab
clearStarPlaceholderMessage = () ->
    $(TAB STAR_TAB).find(RESULTS_DIV).html ''

# Returns the current page's URL, with starred rooms appended as argument
getStarredRoomURL = () ->
    window.location.protocol + '//' +
        window.location.host + '?starred=' + 
        _activeRooms[STAR_TAB].join ','

# Updates page with link that includes currently starred rooms
updateStarredRoomURL = () ->
    starredRoomURL = getStarredRoomURL()
    $(SHARE_LINK).val starredRoomURL
