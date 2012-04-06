## Functions that respond to events that occur in the application.

# Callback that gets called when the filter options are changed
filterChanged = (event) ->
    if _activeTab != -1 and !_multiSelect
        findSelectedRooms _activeTab

# Called when user switches between tabs
tabChanged = (event) ->
    # Keep track of, and store, current and last active tab
    _lastActiveTab = _activeTab
    _activeTab = getActivatedTab event

    savePersistent '_lastActiveTab', _lastActiveTab
    savePersistent '_activeTab', _activeTab

    # Also, make sure the probabilities are updated
    updateProbabilities()

# Called when the new-tab button is clicked
newTabClicked = (event) ->
    loadNewTab()

# Returns the ID of the room whose star was clicked 
# (or a similar event was generated)
# Return -1 if no match was found.
getRoomFromStarEvent = (event) ->
    roomRow = $(event.target).parent 'tr'
    if roomRow.length > 0
        getRoomFromRow roomRow
    else
        -1

# Called when the slider is changed, this function updates all probabilities
# in the active tab.
sliderChanged = (event, ui) ->
    lotteryNumber = if ui.value? then ui.value else MIN_LOTTERY_NUMBER 

    # Display the selected lottery number to the user
    $(LOTTERY_NUMBER_DISPLAY).text lotteryNumber

    # Update the probability values in the table
    updateProbabilities lotteryNumber

    # Let the TableSorter plugin know the table has been updated
    $(ROOM_TABLE).trigger 'update'

    # Save the new lottery number
    savePersistent 'lotteryNumber', lotteryNumber

# Called when the sophomore status checkbox is toggled
sophomoreChanged = (event) ->
    savePersistent 'sophomore', isSophomore()
    
    tab = STAR_TAB + 1
    while (tab < _nextTabNumber) and _activeRooms[tab]?
        findSelectedRooms tab
        tab++

# Called when the availability preference checkbox is toggled
availabilityPreferenceChanged = (event) ->
    exclude = excludeUnavailable()
    log exclude
    savePersistent 'excludeUnavailable', exclude

    document.styleSheets[4].disabled = ! exclude

    tab = STAR_TAB
    while (tab < _nextTabNumber) and _activeRooms[tab]?
        if exclude
            showUnavailablePlaceholder tab
        else
            hideUnavailablePlaceholder tab
        tab++

# Extracts and saves the current sort order from the results table
tableSorted = (event, table) ->
    # Get the sortList from the table
    sortList = event.target.config.sortList

    # Save the sort order for the session
    savePersistent "sort_tab#{ _activeTab }", sortList

# Helper for jQuery UI's sortable plugin, preserves row width when dragging.
# (Without it, columns shrink in the process.)
# Code from http://stackoverflow.com/a/1372954 and based on 
# http://www.foliotek.com/devblog/make-table-rows-sortable-using-jquery-ui-sortable/
tableDragHelper = (event, tr) ->
    originals = tr.children()
    helper = tr.clone()
    helper.children().each (index) ->
        $(this).width originals.eq(index).width()
    return helper

# Called when the star tab's result table has been reordered
starTableReordered = (event, ui) ->
    # Clear the array of starred tabs
    _activeRooms[STAR_TAB] = []

    # Re-populate the array in the new order of the rooms
    $(TAB STAR_TAB).find(RESULTS_DIV).children().each (index, row) ->
        room = getRoomFromRow $(row)
        if room != -1 then _activeRooms[STAR_TAB].push room

    # Store the updated list of rooms
    savePersistent '_activeRooms', _activeRooms

    updateStarredRoomURL()

toggleShareWell = () ->
    $(SHARE_WELL).toggle()
