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
    style=\"color:inherit\">
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

                # Update TableSorter in all tables
                $(ROOM_TABLE).trigger 'update'

# Returns true if the room is unavailable, false otherwise
isUnavailable = (roomID) ->
    if roomID of _available then _available[roomID] == ROOM_STATUS_NOT_AVAILABLE else false
