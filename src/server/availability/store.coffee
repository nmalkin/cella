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

# Returns the key to use in the data store for given room
getKey = (building, room) ->
    PREFIX + building + ':' + room

# Sets the availability for given room:
# true=available, false=not available
exports.setAvailability = (building, room, available, cb = ->) ->
    key = getKey building, room

    # Find out the current status
    redis.get key, (err, currentStatus) ->
        if err then log error; return cb()

        # Do we need to change the status?
        status = false
        if currentStatus == null # status not set
            status = if available then exports.AVAILABLE else exports.NOT_AVAILABLE
        else if available and currentStatus != exports.AVAILABLE
            status = exports.AVAILABLE
        else if (not available) and currentStatus = exports.AVAILABLE
            # Room was available, now isn't. Consider the room taken.
            status = exports.TAKEN
        
        # Set status (if necessary)
        if status then redis.set key, status

        cb()

# Retrieves the availability for the given room.
# Availability is one of NOT_AVAILABLE, AVAILABLE, TAKEN.
# Calls the callback with this availability
exports.getAvailability = (building, room, cb = ->) ->
    key = getKey building, room
    redis.get key, (err, availability) ->
        if err then log error
        cb availability
