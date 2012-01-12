## Functions that respond to events that occur in the application.

# Callback that gets called when the filter options are changed
filterChanged = (event) ->
    if activeTab != -1
        occupancy = getChosenOccupancy activeTab
        buildings = getChosenBuildings activeTab

        $.getJSON 'get_rooms',
            {
                occupancy: occupancy.join ','
                buildings: buildings.join ','
            },
            (resultRooms) ->
                activateRooms activeTab, resultRooms

        selectedOccupancy[activeTab] = occupancy 
        selectedBuildings[activeTab] = buildings
        savePersistent 'selectedOccupancy', selectedOccupancy
        savePersistent 'selectedBuildings', selectedBuildings

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


