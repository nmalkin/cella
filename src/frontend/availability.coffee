## Functions for retrieving and updating the availability of rooms

ROOM_STATUS_NOT_AVAILABLE = '0'
ROOM_STATUS_AVAILABLE = '1'
ROOM_STATUS_TAKEN = '2'

AVAILABILITY_PLACEHOLDER = (roomID) ->
    "<span class=\"#{ NAME AVAILABILITY roomID } label\" rel=\"tooltip\" title=\"#{ NO_AVAILABILITY_DATA }\">?</span>"

# Returns label for availability based on given status
availabilityHTML = (roomID, status) ->
    if status == ROOM_STATUS_NOT_AVAILABLE
        labelClass = 'label-important'
        labelText = 'Not Available'
    else if status == ROOM_STATUS_AVAILABLE
        labelClass = 'label-success'
        labelText = 'Available'
    else if status == ROOM_STATUS_TAKEN
        labelClass = 'label-warning'
        labelText = 'Taken'

    "<span class=\"#{ NAME AVAILABILITY roomID } label #{ labelClass }\">
    <a href=\"http://www.brown.edu/Student_Services/Residential_Council/lottery/broadcast/\"
    style=\"color:inherit\" target=\"_blank\">
    #{ labelText }
    </a></span>"

# Returns the HTML representing availability of given room
# (May be placeholder, until availability is looked up.)
getAvailabilityLabel = (roomID) ->
    if roomID of _available # availability known
        # Return label
        availabilityHTML roomID, _available[roomID]
    else # availability not known
        # Have to look it up
        _availabilityToLookUp.push roomID

        # Return placeholder
        AVAILABILITY_PLACEHOLDER roomID

# Performs a lookup of unknown availabilities.
# On getting the result, stores it and uses it to replace placeholder values.
lookUpAvailability = () ->
    if _availabilityToLookUp.length > 0
        $.getJSON 'availability', {ids: _availabilityToLookUp.join ','},
            (resultAvailabilities) ->
                _availabilityToLookUp = []

                for room, status of resultAvailabilities
                    # Clarify room status
                    if status == null # Room not in lottery
                        # Treat as 'not available'
                        status = ROOM_STATUS_NOT_AVAILABLE

                    # Store room status
                    _available[room] = status

                    # Update room availability label in result table
                    $(AVAILABILITY room).replaceWith availabilityHTML room, status

                    # Update availability class
                    if status == ROOM_STATUS_NOT_AVAILABLE
                        $(ROOM room).addClass NAME ROOM_NOT_AVAILABLE

                # Display placeholder if necessary
                showUnavailablePlaceholder tab for tab in [0..._nextTabNumber] when _activeRooms[tab]?

                # Update TableSorter in all tables
                $(ROOM_TABLE).trigger 'update'

# Returns true if the room is unavailable, false otherwise
isUnavailable = (roomID) ->
    if roomID of _available then _available[roomID] == ROOM_STATUS_NOT_AVAILABLE else false

# Adds a placeholder about hidden unavailable rooms to the given tab
showUnavailablePlaceholder = (tabNumber) ->
    if excludeUnavailable()
        tab = $(TAB tabNumber)
        count = tab.find(ROOM_NOT_AVAILABLE).length # number of unavailable rooms

        if count > 0
            content = HIDDEN_ROOMS count

            # Is the placeholder already in place?
            if (placeholder = tab.find(ROOMS_HIDDEN_PLACEHOLDER)).length == 0
                tab.find(ROOM_TABLE).append content # No. Set it.
            else
                placeholder.replaceWith content # Yes. Update it.

# Removes the placeholder about hidden unavailable rooms from the given tab
hideUnavailablePlaceholder = (tabNumber) ->
    $(TAB tabNumber).find(ROOMS_HIDDEN_PLACEHOLDER).remove()


# Connect to server and listen for updates on rooms that have been taken
socket = io.connect '/'
socket.on 'taken', (room) ->
    _available[room] = ROOM_STATUS_TAKEN
    $(AVAILABILITY room).replaceWith availabilityHTML room, ROOM_STATUS_TAKEN
