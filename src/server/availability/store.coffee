## Stores and retrieves availability information using Redis

PREFIX = 'cella:'

# Status codes
exports.NOT_AVAILABLE = '0'
exports.AVAILABLE = '1'
exports.TAKEN = '2'

log = require('util').debug 

# Connect to Redis
if process.env.REDISTOGO_URL # for production (on Heroku)
    redis = require('redis-url').connect process.env.REDISTOGO_URL
else # Redis running on localhost
    redis = require('redis').createClient()
redis.on 'error', (err) ->
    log err

# Returns the key to use in the data store for given ID
getIDKey = (id) ->
    PREFIX + id + ':availability'

# Returns the key to use in the data store for given room
getRoomKey = (building, room) ->
    PREFIX + building + ':' + room + ':id'

# Calls cb with the ID of the given building and room
getID = (building, room, cb) ->
    key = getRoomKey building, room
    redis.get key, (err, id) ->
        if err then log error; return cb() else cb id

# Sets the availability for given room:
# true=available, false=not available
exports.setAvailability = (building, room, available, cb = ->) ->
    getID building, room, (id) ->
        if id?
            # Find out the current status
            key = getIDKey id
            redis.get key, (err, currentStatus) ->
                if err then log error; return cb()

                # Do we need to change the status?
                status = false
                if currentStatus == null # status not set
                    status = if available then exports.AVAILABLE else exports.NOT_AVAILABLE
                else if available and currentStatus != exports.AVAILABLE
                    status = exports.AVAILABLE
                else if (not available) and currentStatus == exports.AVAILABLE
                    # Room was available, now isn't. Consider the room taken.
                    status = exports.TAKEN
                
                # Set status (if necessary)
                if status then redis.set key, status, cb
        else
            console.log "#{ building } #{ room } is not in database"
            cb()

# Retrieves the availability for the given room.
# Availability is one of NOT_AVAILABLE, AVAILABLE, TAKEN.
# Calls the callback with this availability
exports.getAvailability = (id, cb = ->) ->
    key = getIDKey id
    redis.get key, (err, availability) ->
        if err then log error
        cb availability

# Stores the ID for each room in the databse
storeRoomIDs = () ->
    require('../rooms').allRooms (allRooms) ->
        for room in allRooms
            key = getRoomKey room.building, room.room
            redis.set key, room.id


# On load, populate database with room IDs
storeRoomIDs()
