## Functions that deal the creation, deletion, and information-gathering about tabs.

# Given a change event from a tab, returns the number of the tab activated
# Returns -1 if activated tab couldn't be detected
getActivatedTab = (event) ->
    targetString = $(event.target).attr 'href'
    re = new RegExp '#tab(\\d+)'
    matches = re.exec targetString
    parseInt matches[1] ? -1

# Returns the number of the newest tab that exists on the tab bar
# (i.e., ignoring deleted tabs)
# Returns -1 if there is no newest tab.
getNewestTab = ->
    i = nextTabNumber - 1
    while i >= 0 and $(TAB i).length == 0
        i--
    return i

# Activates the given tab by triggering a click on its tab control
activateTab = (tabNumber) ->
    $("#tab#{ tabNumber }control").children('a').trigger 'click'

# Deletes the table and tab with the given number
closeTab = (tabToDelete) ->
    # Remove the tab and its content
    $("#tab#{ tabToDelete }control").remove()
    $(TAB tabToDelete).remove()

    activeRooms[tabToDelete] = null
    savePersistent 'activeRooms', activeRooms

    tabCount--

    # If we're out of tables, create a new one.
    if tabCount == 0
        loadNewTab()
    # If current tab is being deleted, switch to last active tab,
    # or the newest one, if the last active one is no longer known.
    else if tabToDelete == activeTab
        nextTab = if lastActiveTab == -1 then getNewestTab() else lastActiveTab
        activateTab nextTab
        lastActiveTab = -1

# Creates a new tab with given tab number and loads a new table into it
loadTab = (tabNumber, next = ->) ->
    # Create a div to hold the table
    $(RESULT_TABLES).append "<div id=\"tab#{ tabNumber }\"></div>"

    # Load empty table into tab
    $(TAB tabNumber).load 'table.html', ->
        populateBuildingSelect tabNumber

        selectOccupancy tabNumber, selectedOccupancy[tabNumber]
        selectBuildings tabNumber, selectedBuildings[tabNumber]

        # Activate Chosen plugin for the new table
        $(".chzn-select").chosen()
 
        # activate TableSorter plugin
        $(TAB tabNumber).find(ROOM_TABLE).tablesorter
            debug: false
            textExtraction: 'simple'

        # Activate change listeners
        $(OCCUPANCY_FIELD).change filterChanged
        $(BUILDING_MODE_FIELD).change filterChanged
        $(BUILDINGS_FIELD).change filterChanged

        next()

    # Create a new tab for this table
    new_tab = $("<li id=\"tab#{ tabNumber }control\">
                <a href=\"#tab#{ tabNumber }\">
                Search #{ tabNumber }
                <span class=\"close_tab\" title=\"Close tab\">&#10006;</span>
                </a></li>")
    $(NEW_TAB_BUTTON).parent().before new_tab

    new_tab.find('.close_tab').click (-> closeTab tabNumber)

    activateTab tabNumber

# Creates a new tab with the next available tab number, calls next when done
loadNewTab = (next) ->
    tabNumber = nextTabNumber

    nextTabNumber++
    tabCount++

    loadTab tabNumber, next
