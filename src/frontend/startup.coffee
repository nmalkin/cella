## Functions that initialize the application

# Loads application state from storage
# This includes rooms, open tabs, etc.
loadStateFromStorage = (cb) ->
    t = getPersistent '_allRooms'
    _allRooms = t if t?

    t = getPersistent '_roomResults'
    _roomResults = t if t?

    sophomore = getPersistent 'sophomore'
    if sophomore?
        setSophomoreStatus sophomore

    availabilityPreference = getPersistent 'excludeUnavailable'
    if availabilityPreference?
        setExcludeUnavailable availabilityPreference

    # Update availability settings based on checkbox
    availabilityPreferenceChanged()

    lotteryNumber = getPersistent 'lotteryNumber'
    if lotteryNumber?
        $(LOTTERY_NUMBER_DISPLAY).text lotteryNumber
        $(LOTTERY_SLIDER).slider('value', lotteryNumber)

    t = getPersistent '_selectedOccupancy'
    _selectedOccupancy = t if t?
    t = getPersistent '_selectedBuildings'
    _selectedBuildings = t if t?
    t = getPersistent '_selectedIncludes'
    _selectedIncludes = t if t?

    retrievedLastActiveTab = getPersistent '_lastActiveTab'
    retrievedActiveTab = getPersistent '_activeTab'

    # Load tabs
    t = getPersistent '_activeRooms'
    if t?
        _activeRooms = t

        # This might take a while... show loading message
        $(LOADING_MESSAGE).show()

        # Set aside starred rooms to process after all the tabs are created
        starredRooms = _activeRooms[STAR_TAB]
        _activeRooms[STAR_TAB] = null

        _tabCount = 0
        _nextTabNumber = 0

        # Wait for all tabs to be loaded
        await
            loadAndActivateTab = (tabNumber, rooms, next) ->
                if rooms?
                    _tabCount++

                    # Load current tab
                    await loadTab tabNumber, defer()
                    
                    # Now that tab is loaded, populate it with rooms
                    await activateRooms tabNumber, rooms, defer()

                    # Sort the table according to the saved order
                    sortOrder = getPersistent "sort_tab#{ tabNumber }"
                    if sortOrder?
                        # XXX: if the tab isn't activated when the sort is
                        # triggered, the sort doesn't happen.
                        # (The correct tab will be activated afterwards.)
                        activateTab tabNumber

                        try
                            $(TAB tabNumber).find(ROOM_TABLE).trigger 'sorton', [sortOrder]
                        catch error
                            log error

                    # Execute callback
                    next()
                else
                    next()

                return

            for tab in _activeRooms
                loadAndActivateTab _nextTabNumber, tab, defer()
                _nextTabNumber++

        # Now that all tabs have been loaded:
        # Re-star the starred rooms
        if starredRooms? and starredRooms.length > 0
            clearStarPlaceholderMessage()
            starRoom room for room in starredRooms
            updateStarredRoomURL()
        else
            _activeRooms[STAR_TAB]= []
            showStarPlaceholderMessage()

        # There may be rooms that we need to look up.
        lookUpAvailability()

        # Activate the last active tab
        _lastActiveTab = retrievedLastActiveTab if retrievedLastActiveTab?
        if retrievedActiveTab? and _activeRooms[retrievedActiveTab]
            _activeTab = retrievedActiveTab
        else
            _activeTab = getNewestTab()
        activateTab _activeTab

        cb()
    else
        cb()

$(document).ready ->
    # activate lottery number slider
    $(LOTTERY_SLIDER).slider {
        min: MIN_LOTTERY_NUMBER,
        max: MAX_LOTTERY_NUMBER,
        slide: sliderChanged
    }

    $(SOPHOMORE_CHECKBOX).change sophomoreChanged 
    $(AVAILABILITY_CHECKBOX).change availabilityPreferenceChanged 

    $(NEW_TAB_BUTTON).click newTabClicked

    $('#clear_data').click clearPersistent

    $(RESULT_TABS + ' a[data-toggle="tab"]').live 'show', tabChanged
            
    # Retrieve all buildings, which will then be used to populate select box
    loadBuildings()

    loadStateFromStorage ->
        $(RESULT_TABLES).show()
        $(RESULT_TABS).show()
        $(LOADING_MESSAGE).hide()

        # Try to import starred room from URL query string
        importRooms()

    # If there are no tabs, create one
    if _tabCount == 0
        # But switch back to the star-tab if it's activated
        next = if _activeTab == STAR_TAB then (-> activateTab STAR_TAB) else (->)
        loadNewTab next

    # Display star placeholder message if no rooms are starred
    if (not _activeRooms[STAR_TAB]?) or _activeRooms[STAR_TAB].length == 0
        showStarPlaceholderMessage()

    # Activate drag-and-drop of results in star tab
    $(TAB STAR_TAB).find(RESULTS_DIV).sortable
        helper: tableDragHelper
        update: starTableReordered

    # Enable sorting of results in star tab
    starResultTable = $(TAB STAR_TAB).find(ROOM_TABLE)
    try
        starResultTable.tablesorter
            debug: false
            textExtraction: 'simple'
    catch error
        log error

    # At the end of sorting, store the new order of the starred rooms
    starResultTable.bind 'sortEnd', starTableReordered

    # When user initiates sorting, new rooms may have been starred/added,
    # so trigger a table update, so that these rooms are taken into account.
    # NOTE that this means the table will be sorted twice (once by the 'update'
    # and once by the actual click handler; and if the latter happens first,
    # that sort will be "incorrect"); however, this doesn't have side-effects.
    starResultTable.find('.header').click ->
        starResultTable.trigger 'update'

    # Activate tooltips
    $("[rel=tooltip]").live 'mouseover', -> $(this).tooltip('show')

    # Toggle star status when stars are clicked
    $("td.star").live 'click', toggleStar

    # Show sharing-info well when toggle message is clicked
    $(SHARE_WELL_TOGGLE).click toggleShareWell

    $(SHARE_LINK).focus -> $(this).select()

    # Show a random hint in the MOTD box
    hint = getRandomInt 0, HINTS.length - 1
    showHint hint

    # Rotate hints every 15 seconds
    setInterval (->
        showHint ++hint % HINTS.length
    ), 1000*15

    # ...or when the user advances them manually
    $(PREVIOUS_HINT).click -> showHint ((--hint % HINTS.length) + HINTS.length) % HINTS.length
    $(NEXT_HINT).click -> showHint ++hint % HINTS.length


importRooms = () ->
    # Try to get starred rooms from search string
    starred_param = /[\?&]starred=([\d,]*)(?:&|$)/.exec(window.location.search)
    if not starred_param then return

    # Extract room numbers from query string.
    inputRooms = []
    inputRoomsObject = {} # used to check for duplicates
    re = /\d+/g # match numbers
    while (match = re.exec starred_param[0])?
        roomNumber = parseInt match[0]
        if (not isNaN roomNumber) and # is a valid number
        roomNumber > 0 and # somewhere in the expected range
        not (roomNumber of inputRoomsObject) # not a duplicate
            # Okay, save for further processing.
            inputRooms.push roomNumber
            inputRoomsObject[roomNumber] = true

    knownRooms = []
    for roomID in inputRooms
        # Do I already have this room's information?
        if roomID of _allRooms # Yes
            knownRooms.push roomID
        else # No. We should look it up.
            _roomsToLookUp.push roomID

    showImportWindow = (extraRooms = []) ->
        # Get room information for known rooms (and add the extra ones in)
        rooms = (_allRooms[room] for room in knownRooms).concat extraRooms

        if rooms.length == 0 then return

        # Load modal window contents
        $(IMPORT_WINDOW).load IMPORT_WINDOW_URL, ->
            # Create a <li> for each room
            makeRoomListItem = (room) -> "<li>#{ room.building } #{room.room }</li>"
            roomList = (makeRoomListItem room for room in rooms).join ''

            # Inject the list into the modal
            $(IMPORT_ROOM_LIST).html roomList

            # Are there starred rooms already?
            importConflict = _activeRooms[STAR_TAB]? and _activeRooms[STAR_TAB].length > 0
            
            # Display the appropriate footer based on the answer.
            $(IMPORT_CONFLICT).toggle importConflict
            $(IMPORT_NO_CONFLICT).toggle !importConflict

            # Show the modal
            $(IMPORT_WINDOW).modal()

            # When the modal is closed:
            $(IMPORT_WINDOW).on 'hide', ->

                # Clear search string
                history.replaceState null, null, '/'

            # If the user wants to add to the currently starred rooms.
            $(IMPORT_UNION).click () ->
                for room in rooms
                    if -1 == _activeRooms[STAR_TAB].indexOf room.id
                        starRoom room.id

                updateProbabilities null, true
                updateStarredRoomURL()
                lookUpAvailability()

                # Activate star tab to show change
                activateTab STAR_TAB

            # If the user wants to replace the currently starred rooms.
            $(IMPORT_REPLACE).click () ->
                # Unstar currently starred rooms
                if _activeRooms[STAR_TAB]?
                    toUnstar = _activeRooms[STAR_TAB].slice 0 # make a copy
                    unstarRoom room for room in toUnstar
                else
                    _activeRooms[STAR_TAB] = []

                if _activeRooms[STAR_TAB].length == 0
                    clearStarPlaceholderMessage()

                # Star the new rooms
                starRoom room.id for room in rooms

                updateProbabilities null, true
                updateStarredRoomURL()
                lookUpAvailability()

                # Activate star tab to show change
                activateTab STAR_TAB

    if _roomsToLookUp.length > 0
        # Don't have information about some rooms. Look them up.
        lookUpRooms (lookedUpRooms) ->
            # Then, display import window
            showImportWindow lookedUpRooms
    else
        showImportWindow()

# Shows the hint defined by the given index in the MOTD box
showHint = (hint) ->
    $(MOTD).html HINTS[hint]

# Generates a random integer between min and max (inclusive)
# Code from: https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Math/random
getRandomInt = (min, max) ->
    Math.floor(Math.random() * (max - min + 1)) + min
