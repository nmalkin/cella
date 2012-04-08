## Functions that have to do with the display of the rooms
#  (adding, removing, generating HTML for them).

# Returns a string with the HTML for a row in the table with the given room information
roomHTML = (room, filledStar=false) ->
    # Is this room starred?
    star = if filledStar then STAR_FILLED else STAR_EMPTY

    # Is this room unavailable
    unavailable = isUnavailable room.id
    availableClass = if unavailable then NAME ROOM_NOT_AVAILABLE else ''

    label = (text, color = null) ->
        "<p class=\"label_container\"><span class=\"label #{ color }\">#{ text }</span></p>"
   
    labels = label (FLOORPLAN_LABEL room), FLOORPLAN_COLOR
    labels += if room.apartment then label APARTMENT_RATE_LABEL, APARTMENT_RATE_COLOR else ''
    labels += if room.sophomore then label SOPHOMORE_LABEL, SOPHOMORE_COLOR else ''
    labels += if room.gender_neutral and
        room.occupancy > 1 then label GENDER_NEUTRAL_LABEL, GENDER_NEUTRAL_COLOR else ''

    "<tr class=\"#{ NAME ROOM room.id } #{ availableClass }\">
        <td class=\"star\">#{ star }</td>
        <td>#{ room.occupancy }</td>
        <td>#{ room.building}</td>
        <td>#{ room.room }</td>
        <td>#{ labels }</td>
        <td>
            <div class=\"probability\">
                <div class=\"#{ NAME PROBABILITY room.id }\">
                    <span class=\"probability-text\">&nbsp;</span>
                    &nbsp;
                </div
            </div>
        </td>
        <td style=\"text-align: center\">#{ getAvailabilityLabel room.id }</td>
    </tr>"

# Activate the popover that shows previous room results
initResultPopover = (room, tabNumber) ->
    target = $(TAB tabNumber).find(PROBABILITY room.id).parent '.probability'
    hover = false
    target.hover (-> # on mouse in
        hover = true
        
        # Is this the first time this has been moused over?
        if not target.data('popover_init')? # yes, set up the popover
            getResults room.id, (results) ->
                table = resultTableHTML results
                target.popover
                    trigger: 'manual',
                    animation: true,
                    placement: 'top',
                    title: room.building + ' ' + room.room,
                    content: table
                target.data 'popover_init', true
                if hover
                    target.popover 'show'
        else # no, show the popover
            target.popover 'show'
    ), (-> # on mouse out
        hover = false

        # Assuming the popover exists, hide it
        if target.data('popover_init')? 
            target.popover 'hide'
    )

# Returns a string of HTML with a table displaying given results
# 'results' is an object of the form {year: number, ...); e.g,. {2011: 415}
resultTableHTML = (results) ->
    table = '<table class="table">'
    
    head = '<thead><tr><th>Year</th>'
    body = '<tbody><tr><th>Lottery number</th>'
    for year of results
        head += "<td>#{ year }</td>"
        body += "<td>#{ results[year] ? '-' }</td>"
    
    head += '</tr></thead>'
    body += '</tr></tbody>'
    
    table += head + body + '</table>'
    table

# Adds room with given room id to the table
addRoom = (tabNumber, roomID) ->
    if roomID > 0
        # Is this a known room?
        if roomID of _allRooms # Yes, we can display it now.
            isStarred = if _activeRooms[STAR_TAB]? then \
                _activeRooms[STAR_TAB].indexOf(roomID) != -1 else false
            room = _allRooms[roomID]
            html = roomHTML room, isStarred

            $(TAB tabNumber).find(RESULTS_DIV).append html
            initResultPopover room, tabNumber
        else # No, it needs to be looked up. (Display placeholder for now.)
            _roomsToLookUp.push roomID
            html = "<tr class=\"#{ NAME ROOM roomID }\"><td colspan=\"7\"></td></tr>"
            $(TAB tabNumber).find(RESULTS_DIV).append html

# Removes room from tab
removeRoom = (tabNumber, roomID) ->
    $(TAB tabNumber).find(ROOM roomID).remove()


