## Functions that have to do with the display of the rooms
#  (adding, removing, generating HTML for them).

# Returns a string with the HTML for a row in the table with the given room information
roomHTML = (room, filledStar=false) ->
    star = if filledStar then STAR_FILLED else STAR_EMPTY
    "<tr class=\"room#{ room.id }\">
        <td class=\"star\">#{ star }</td>
        <td>#{ room.occupancy }</td>
        <td>#{ room.building}</td>
        <td>#{ room.room }</td>
        <td></td>
        <td class=\"room#{ room.id }probability\"></td>
        <td></td>
    </tr>"

# Adds room with given room id to the table
addRoom = (tabNumber, roomID) ->
    if roomID of allRooms
        isStarred = if activeRooms[STAR_TAB]? then \
            activeRooms[STAR_TAB].indexOf(roomID) != -1 else false
        html = roomHTML allRooms[roomID], isStarred
    else
        roomsToLookUp.push roomID
        html = "<tr class=\"room#{ roomID }\"><td colspan=\"7\"></td></tr>"
    $(TAB tabNumber).find(RESULTS_DIV).append html

# Removes room from tab
removeRoom = (tabNumber, roomID) ->
    $(TAB tabNumber).find(".room#{ roomID }").remove()

