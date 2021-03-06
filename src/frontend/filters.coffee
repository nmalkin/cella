## Functions that have to do with setting and getting the filter values
#  -- the select boxes that specify desired room attributes
#  (e.g., occupancy, buildings)

# Adds an option group to the building select box (given)
# with its value being the campus area
# and its options - the buildings
addCampusAreaToSelect = (select, campusArea, buildings) ->
    str = "<optgroup label=\"#{ campusArea }\">"
    str += "<option value=\"#{ building }\">#{ building }</option>" \
        for building in buildings
    str += "</optgroup>"
    
    select.append str

# Populates the building select field for the given tab
populateBuildingSelect = (tabNumber) ->
    buildingSelect = $(TAB tabNumber).find(BUILDINGS_FIELD)

    addCampusAreaToSelect buildingSelect, campusArea.name, \
        campusArea.buildings.sort() for campusArea in _campusAreas
    
    # Tell the Chosen plugin that the select has been updated
    buildingSelect.trigger 'liszt:updated'

# Selects each given occupancy in this tab's select box
selectOccupancy = (tabNumber, occupancies) ->
    if tabNumber != -1 and occupancies? and occupancies.length > 0
        occupancySelect = $(TAB tabNumber).find(OCCUPANCY_FIELD)

        occupancySelect.find("option[value=\"#{ occupancy }\"]").attr('selected',
            'selected') for occupancy in occupancies

# Selects each of the given buildings in this tab's building select box
selectBuildings = (tabNumber, buildings) ->
    if tabNumber != -1 and buildings? and buildings.length > 0
        buildingSelect = $(TAB tabNumber).find(BUILDINGS_FIELD)

        buildingSelect.find("option[value=\"#{ building }\"]").attr('selected',
            'selected') for building in buildings

# Selects the include or exclude option in the given tab
selectInclude = (tabNumber, includeBuildings) ->
    if tabNumber != -1 and (includeBuildings == true or includeBuildings == false)
        select = $(TAB tabNumber).find(BUILDING_MODE_FIELD)
        option = if includeBuildings then 'include' else 'exclude'
        select.find("option[value=\"#{ option }\"]").attr('selected', 'selected')

# Returns an array with integer values for occupancy selected by the user
getChosenOccupancy = (tabNumber) ->
    value = $(TAB tabNumber).find(OCCUPANCY_FIELD).val() ? []
    parseInt occupancy for occupancy in value

# Returns true if the chosen buildings should be included, false if they should be excluded.
includeChosenBuildings = (tabNumber) ->
    building_mode = $(TAB tabNumber).find(BUILDING_MODE_FIELD).val()
    if building_mode == 'include'
        true
    else if building_mode == 'exclude'
        false
    else
        throw 'Illegal value in building mode field'

# Returns an array with the currently selected buildings
getChosenBuildings = (tabNumber) ->
    $(TAB tabNumber).find(BUILDINGS_FIELD).val() ? []

# Returns true if the "I am a sophomore" checkbox is checked.
isSophomore = () ->
    $(SOPHOMORE_CHECKBOX).prop 'checked'

# Checks the sophomore checkbox if argument is true
setSophomoreStatus = (sophomore) ->
    $(SOPHOMORE_CHECKBOX).prop 'checked', sophomore

# Returns true if the user wants to hide unavailable rooms
excludeUnavailable = () ->
    $(AVAILABILITY_CHECKBOX).prop 'checked'

# Checks the availability checkbox if argument is true
setExcludeUnavailable = (exclude) ->
    $(AVAILABILITY_CHECKBOX).prop 'checked', exclude

# Called when a group item is selected in a Chosen select item, this function
# selects all items in the group and adds them to the filter. This is needed
# because Chosen does not provide for it out of the box.
selectCampusArea = (event) =>
    _multiSelect = true
    next = event.target
    buildings = []
    while next.nextSibling? and "group-result" != building = next.nextSibling.className
        next = next.nextSibling
        if -1 != building.indexOf "active-result"
            buildings.push next
    for building in buildings
       e = $("##{ building.id }")
       e.trigger 'mouseup'
    $("input:last").trigger 'mouseenter' 
    _multiSelect = false
    $(BUILDINGS_FIELD).trigger 'change'

# Returns true if we know a priori
# that no results can be found based on current filter values.
noResultsPossible = (tab) ->
    occupancy = getChosenOccupancy tab
    buildings = getChosenBuildings tab
    includeBuildings = includeChosenBuildings tab

    return (occupancy.length == 0 or (buildings.length == 0 and includeBuildings))
