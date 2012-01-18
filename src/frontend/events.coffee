## Functions that respond to events that occur in the application.

# Callback that gets called when the filter options are changed
filterChanged = (event) ->
    if activeTab != -1
        findSelectedRooms activeTab

# Called when user switches between tabs
tabChanged = (event) ->
    # Keep track of, and store, current and last active tab
    lastActiveTab = activeTab
    activeTab = getActivatedTab event

    savePersistent 'lastActiveTab', lastActiveTab
    savePersistent 'activeTab', activeTab

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
        roomString = roomRow.attr 'class'
        matches = (new RegExp 'room(\\d+)').exec roomString
        parseInt matches[1] ? -1
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
    while (tab < nextTabNumber) and activeRooms[tab]?
        findSelectedRooms tab
        tab++

# Extracts and saves the clicked-on column number from the results table
tableHeaderClicked = (event) ->
    # Get the column that was clicked
    target = $(event.target)
    header = if target.is 'th' then target else target.parent 'th'
    column = header.index()

    # Next, we want to get the direction of the sort (ascending/descending),
    # but the sort may not be done yet. Wait for it to finish.
    $(TAB activeTab).find(ROOM_TABLE).bind 'sortEnd', ->
        # Unbind, because there's no need to listen further.
        $(TAB activeTab).find(ROOM_TABLE).unbind()

        # Determine the sort order (0 = ascending, 1 = descending)
        sortOrder = if header.hasClass('headerSortDown') then 0 else 1

        # Save the sort order for the session
        savePersistent "sort_tab#{ activeTab }", [column, sortOrder]
