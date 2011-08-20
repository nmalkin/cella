# DEBUG
log = (message) ->
    $("#log").append message

# Form field ids
occupancy_field_id = 'occupancy'
building_mode_field_id = 'building-mode'
buildings_field_id = 'select-buildings'

# Populates the building select field
populateBuildingSelect = ->
    $.getJSON 'campus_areas', (campusAreas) ->
        addCampusAreaToSelect campusArea.name, campusArea.buildings.sort() for campusArea in campusAreas
        
        # Tell the Chosen plugin that the select has been updated
        $("##{ buildings_field_id }").trigger "liszt:updated"

# Adds an option group to the building select box
# with its value being the campus area
# and its options - the buildings
addCampusAreaToSelect = (campusArea, buildings) ->
    str = "<optgroup label=\"#{ campusArea }\">"
    str += "<option value=\"#{ building }\">#{ building }</option>" for building in buildings
    str += "</optgroup>"
    $("##{ buildings_field_id }").append str

# DEPRECATED
# Add an option with the given building to the building select box
addBuildingToSelect = (building) ->
    option_string = "<option value=\"#{ building }\">#{ building }</option>"
    $("##{ buildings_field_id }").append option_string

# Returns an array with integer values for occupancy selected by the user
getChosenOccupancy = ->
    value = $("##{ occupancy_field_id }").val() ? []
    parseInt occupancy for occupancy in value

# Returns true if the chosen buildings should be included, false if they should be excluded.
includeChosenBuildings = ->
    building_mode = $("##{ building_mode_field_id }").val()
    if building_mode == 'include'
        true
    else if building_mode == 'exclude'
        false
    else
        throw 'Illegal value in building mode field'

# Returns an array with the currently selected buildings
getChosenBuildings = ->
    $("##{ buildings_field_id }").val() ? []

# Callback that gets called when the filter options are changed
filterChanged = (event) ->
    #TODO: get rooms from server

$("##{ occupancy_field_id }").change filterChanged
$("##{ building_mode_field_id }").change filterChanged
$("##{ buildings_field_id }").change filterChanged

$(document).ready ->
    # activate Chosen plugin
    $(".chzn-select").chosen()

    # populate building select with buildings
    populateBuildingSelect()


