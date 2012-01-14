## Functions that initialize the application

# Loads application state from storage
# This includes rooms, open tabs, etc.
loadStateFromStorage = () ->
    t = getPersistent 'allRooms'
    allRooms = t if t?

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

        (->
            if tab?
                tabCount++

                # Create function that, when called, activates this tab's rooms
                activateMyRooms = ( (tabToActivate) ->
                    () -> activateRooms tabToActivate, activeRooms[tabToActivate]
                ) nextTabNumber # avoids binding to nextTabNumber

                loadTab nextTabNumber, activateMyRooms

            nextTabNumber++
        )() for tab in activeRooms

        # Re-star the starred rooms
        if starredRooms? and starredRooms.length > 0
            clearStarPlaceholderMessage()

            # TODO: this is a hacky way to make sure rooms are starred
            # only after all the tabs have been loaded.
            # What we really want is to have this wait on an event, or be in a callback.
            window.setTimeout (-> starRoom room for room in starredRooms), 250
        else
            activeRooms[STAR_TAB]= []
            showStarPlaceholderMessage()

    lastActiveTab = retrievedLastActiveTab if retrievedLastActiveTab?
    activeTab = retrievedActiveTab if retrievedActiveTab?
    activateTab activeTab


$(document).ready ->
    # activate lottery number slider
    $(LOTTERY_SLIDER).slider {
        min: MIN_LOTTERY_NUMBER,
        max: MAX_LOTTERY_NUMBER,
        slide: sliderChanged
    }

    $(NEW_TAB_BUTTON).click loadNewTab

    $('#clear_data').click clearPersistent

    # When switching tabs, remember the currently active one
    $(RESULT_TABS).change (event) ->
        lastActiveTab = activeTab
        activeTab = getActivatedTab event

        savePersistent 'lastActiveTab', lastActiveTab
        savePersistent 'activeTab', activeTab

        # Also, make sure the probabilities are updated
        updateProbabilities()
    
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
