## Functions that have to do with calculating the probability of obtaining rooms.
#  Also includes functions for setting/retrieving lottery number
#  (since that is the primary determinant of the probability).

# Returns the number currently selected on the lottery number slider
getLotteryNumber = ->
    $(LOTTERY_SLIDER).slider('value')

# Computes the value at x of the logistic function with regression coefficients b0, b1
# That is 1/(1+e^-(b0 + b1*x)).
logit = (b0, b1, x) ->
    1 / (1 + Math.exp(-1 * (b0 + b1 * x)))

# Returns probability that given room is obtained under currently selected lottery number
# 'room' is a room object
# The probability returned is a value between 0 and 1.
getRoomProbability = (room, lotteryNumber) ->
    logit room.b0, room.b1, lotteryNumber

# Returns the color of the probability bar given the probability
getProbabilityBarColor = (probability) ->
    console.log category = parseInt probability / (1.0 / 5)
    PROBABILITY_COLORS[category]

# Reconstruct a new gradient for a probability bar given the old graident
# and a new color
recreateProbabilityGradient = (gradient, color) ->
    if gradient.indexOf "linear-gradient" != -1
        replacement = ", #{ color } 0%, "
        replacement += "#{ color } 100%,"
        regex = new RegExp ",[^,]+,[^,]+,"
        gradient.replace regex, replacement
    else
        decimal = percentage.substr 0, pecentage.length - 2
        replacement = "color-stop(0, #{ color }), "
        replacement += "color-stop(1 #{ color }),"
        regex = new RegExp ", color-stop[^)]+), color-stop[^)]+),"
        gradient.replace regex, replacement

# Update probability of room with given ID based on given lottery number
updateRoomProbability = (roomID, lotteryNumber) ->
    if allRooms[roomID]?
        probability = getRoomProbability allRooms[roomID], lotteryNumber
        percentage = "#{ Math.round probability * 100 }%"
        #$(".room#{ roomID }probability").text percentage
        background = $(".room#{ roomID }probability").css "background-image"
        if background?
            color = getProbabilityBarColor probability
            newBackground = recreateProbabilityGradient background, color
            $(".room#{ roomID }probability").css "background-color", color
            $(".room#{ roomID }probability").css "width", percentage
        
# Goes through all active rooms and updates their probabilities
# to match the lottery number.
# If no lottery number is given, the currently selected one is used.
updateProbabilities = (lotteryNumber = null) ->
    lotteryNumber ?= getLotteryNumber()
    if activeTab != -1 and activeRooms[activeTab]?
        for roomID in activeRooms[activeTab] # only update rooms in active tab
            updateRoomProbability roomID, lotteryNumber
