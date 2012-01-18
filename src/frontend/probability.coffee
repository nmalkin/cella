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
getProbabilityBarColors = (probability) ->
    category = parseInt probability / (1.0 / 5)
    [PROBABILITY_COLORS_DARK[category], PROBABILITY_COLORS[category]]

# Reconstruct a new gradient for a probability bar given the old graident
# and new colors
recreateProbabilityGradient = (gradient, colors) ->
    if gradient.indexOf "linear-gradient" != -1
        idx = gradient.indexOf "("
        prefix = gradient.substr 0, idx
        prefix + "(bottom, #{ colors[0] } 0%, #{ colors[1] } 70%)"
    else
        idx = gradient.indexOf "("
        prefix = gradient.substr 0, idx
        newGradient += "(linear, left bottom, left top, "
        newGradient += "color-stop(0, #{ colors[0] }), "
        newGradient += "color-stop(0.7, #{ colors[1] }))"

# Update probability of room with given ID based on given lottery number
updateRoomProbability = (roomID, lotteryNumber) ->
    if allRooms[roomID]?
        probability = getRoomProbability allRooms[roomID], lotteryNumber
        if probability < .05
            probability = .05
        percentage = "#{ Math.round probability * 100 }%"
        #$(".room#{ roomID }probability").text percentage
        background = $(".room#{ roomID }probability").css "background-image"
        colors = getProbabilityBarColors probability
        if background?
            console.log newBackground = recreateProbabilityGradient background, colors
            $(".room#{ roomID }probability").css "background-color", colors[1]
            console.log $(".room#{ roomID }probability").css "background-image", newBackground
            $(".room#{ roomID }probability").css "width", percentage
        
# Goes through all active rooms and updates their probabilities
# to match the lottery number.
# If no lottery number is given, the currently selected one is used.
updateProbabilities = (lotteryNumber = null) ->
    lotteryNumber ?= getLotteryNumber()
    if activeTab != -1 and activeRooms[activeTab]?
        for roomID in activeRooms[activeTab] # only update rooms in active tab
            updateRoomProbability roomID, lotteryNumber
