## Functions that initialize the application

# Loads application state from storage
# This includes rooms, open tabs, etc.
loadStateFromStorage = () ->
    t = getPersistent 'allRooms'
    allRooms = t if t?

    sophomore = getPersistent 'sophomore'
    if sophomore?
        setSophomoreStatus sophomore

    lotteryNumber = getPersistent 'lotteryNumber'
    if lotteryNumber?
        $(LOTTERY_NUMBER_DISPLAY).text lotteryNumber
        $(LOTTERY_SLIDER).slider('value', lotteryNumber)

    t = getPersistent 'selectedOccupancy'
    selectedOccupancy = t if t?
    t = getPersistent 'selectedBuildings'
    selectedBuildings = t if t?
    t = getPersistent 'selectedIncludes'
    selectedIncludes = t if t?

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

        # Wait for all tabs to be loaded
        await
            loadAndActivateTab = (tabNumber, rooms, next) ->
                if rooms?
                    tabCount++

                    # Load current tab
                    await loadTab tabNumber, defer()
                    
                    # Now that tab is loaded, populate it with rooms
                    await activateRooms tabNumber, rooms, defer()

                    # Execute callback
                    next()
                    # XXX: for some reason, if this is placed after the sorting
                    # trigger (and it gets called), the code is never reached.

                    # Sort the table according to the saved order
                    sortOrder = getPersistent "sort_tab#{ tabNumber }"
                    if sortOrder?
                        $(TAB tabNumber).find(ROOM_TABLE).trigger 'sorton',
                            [[sortOrder]]
                else
                    next()

                return

            for tab in activeRooms
                loadAndActivateTab nextTabNumber, tab, defer()
                nextTabNumber++

        # Now that all tabs have been loaded:
        # Re-star the starred rooms
        if starredRooms? and starredRooms.length > 0
            clearStarPlaceholderMessage()
            starRoom room for room in starredRooms
        else
            activeRooms[STAR_TAB]= []
            showStarPlaceholderMessage()

        # Activate the last active tab
        lastActiveTab = retrievedLastActiveTab if retrievedLastActiveTab?
        if retrievedActiveTab? and activeRooms[retrievedActiveTab]
            activeTab = retrievedActiveTab
        else
            activeTab = getNewestTab()
        activateTab activeTab


$(document).ready ->
    # activate lottery number slider
    $(LOTTERY_SLIDER).slider {
        min: MIN_LOTTERY_NUMBER,
        max: MAX_LOTTERY_NUMBER,
        slide: sliderChanged
    }

    $(SOPHOMORE_CHECKBOX).change sophomoreChanged 

    $(NEW_TAB_BUTTON).click newTabClicked

    $('#clear_data').click clearPersistent

    $(RESULT_TABS).change tabChanged
            
    # Retrieve all buildings, which will then be used to populate select box
    loadBuildings()

    loadStateFromStorage()

    # If there are no tabs, create one
    if tabCount == 0
        # But switch back to the star-tab if it's activated
        next = if activeTab == STAR_TAB then (-> activateTab STAR_TAB) else (->)
        loadNewTab next

    # Display star placeholder message if no rooms are starred
    if activeRooms[STAR_TAB]? and activeRooms[STAR_TAB].length == 0
        showStarPlaceholderMessage()
