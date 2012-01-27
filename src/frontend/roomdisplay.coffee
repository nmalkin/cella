## Functions that have to do with the display of the rooms
#  (adding, removing, generating HTML for them).

# Returns a string with the HTML for a row in the table with the given room information
roomHTML = (room, filledStar=false) ->
    # Is this room starred?
    star = if filledStar then STAR_FILLED else STAR_EMPTY

    label = (text, color = null) ->
        bg = if color? then "style=\"background-color: #{ color }\"" else ''
        "<span class=\"label\" #{ bg }>#{ text }</span> "

    labels = ''
    labels += if room.apartment then label 'Apartment Rate', APARTMENT_RATE_COLOR else ''
    labels += if room.sophomore then label 'Sophomore-Only', SOPHOMORE_COLOR else ''
    labels += if room.gender_neutral and
        room.occupancy > 1 then label 'Gender-Neutral', GENDER_NEUTRAL_COLOR else ''

    "<tr class=\"#{ NAME ROOM room.id }\">
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
        html = "<tr class=\"#{ NAME ROOM roomID }\"><td colspan=\"7\"></td></tr>"
    $(TAB tabNumber).find(RESULTS_DIV).append html

# Removes room from tab
removeRoom = (tabNumber, roomID) ->
    $(TAB tabNumber).find(ROOM roomID).remove()


