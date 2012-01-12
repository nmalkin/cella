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

# Update probability of room with given ID based on given lottery number
updateRoomProbability = (roomID, lotteryNumber) ->
    if allRooms[roomID]?
        probability = getRoomProbability allRooms[roomID], lotteryNumber
        percentage = "#{ Math.round probability * 100 }%"
        $(".room#{ roomID }probability").text percentage

# Goes through all active rooms and updates their probabilities
# to match the currently selected lottery number
updateProbabilities = ->
    if activeTab != -1 and activeRooms[activeTab]?
        lotteryNumber = getLotteryNumber()
        for roomID in activeRooms[activeTab] # only update rooms in active tab
            updateRoomProbability roomID, lotteryNumber
