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
# The probability returned is a value between 0 and 1 or -1 if there is no data.
getRoomProbability = (room, lotteryNumber) ->
    if room.b0? and room.b1?
        logit room.b0, room.b1, lotteryNumber
    else
        -1

# Returns the color of the probability bar given the probability
getProbabilityBarColors = (probability) ->
    category = parseInt probability / (1.0 / 5)
    if category > 4
       category = 4
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
    if _allRooms[roomID]?
        # Get probability
        probability = getRoomProbability _allRooms[roomID], lotteryNumber

        if probability == -1
            # Probability not available. Display empty bar.
            probability = 0
        else if probability < .05
        # Very low probability should still be seen; therefore "round" up to 5%.
            probability = .05

        probabilityContainer = $(PROBABILITY roomID)

        # Set the text value (for sorting; it will not be displayed)
        percentage = "#{ Math.round probability * 100 }%"
        probabilityContainer.children(PROBABILITY_TEXT).text percentage

        # Display colored bar representing likelihood
        background = probabilityContainer.css "background-image"
        colors = getProbabilityBarColors probability
        if background?
            newBackground = recreateProbabilityGradient background, colors
            probabilityContainer.css "background-color", colors[1]
            probabilityContainer.css "background-image", newBackground
            probabilityContainer.css "width", percentage
        
# Goes through all active rooms and updates their probabilities
# to match the lottery number.
# If no lottery number is given, the currently selected one is used.
# If 'force' is false, the probability is updated only if the
# lottery number has changed since the last time this tab was updated.
updateProbabilities = (lotteryNumber = null, force = false) ->
    lotteryNumber ?= getLotteryNumber()

    # Only update rooms in the current tab (to increase speed) and
    # if the lottery number has changed since the last update
    if _activeTab != -1 and _activeRooms[_activeTab]? and
    (force or _lotteryNumberWhenUpdated[_activeTab] != lotteryNumber)
        for roomID in _activeRooms[_activeTab]
            updateRoomProbability roomID, lotteryNumber

        _lotteryNumberWhenUpdated[_activeTab] = lotteryNumber

