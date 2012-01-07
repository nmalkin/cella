url = require 'url'

rooms = require './rooms.js'
buildings = require('./buildings')


# Given a result, writes it stringified to the response
# with normal HTTP status code and a JSON content-type
resultToResponse = (result, response) ->
    result ?= '' # If nothing else, we'll return an empty string
    response.writeHead 200, {'Content-Type': 'application/json'}
    response.write JSON.stringify result
    response.end '\n'


# Builds a response that is a JSON array of room ids
# of rooms that fit the required features.
# The query must include the following fields: occupancy, buildings
exports.get_rooms = (req, res, next) ->
    # get the query parameters: occupancy, buildings
    params = (url.parse req.url, true).query
    
    # make sure we actually have some values for occupancy and buildings
    if not (params.occupancy? and params.buildings?)
        res.writeHead 200, {'Content-Type': 'text/plan'} # TODO: I'd like this to be a 400 code, but browsers seem to interpret that as a 404
        res.end 'Missing required parameters\n'
    else
        # multiple values in the query strings will be delimited by commas.
        # explode them into arrays
        occupancy = params.occupancy.split ','
        buildings = params.buildings.split ','

        # the occupancy values are strings, should be converted to ints
        occupancy = (parseInt value for value in occupancy \
                     when not isNaN parseInt value) # exclude non-integer values

        if occupancy.length == 0
            # There are no valid values for occupancy.
            # Because this happens when the user hasn't inputted all the criteria,
            # we just return no results.
            resultToResponse [], res
        else
            rooms.select occupancy, buildings, (result) ->
                resultToResponse result, res
            
# Sets the response to a JSON array of objects with room info
exports.room_info = (req, res, next) ->
    params = (url.parse req.url, true).query
    
    if not params.ids?
        res.writeHead 200, {'Content-Type': 'text/plan'}
        res.end 'Missing required parameters\n'
    else
        ids = params.ids.split ','

        ids = (parseInt value for value in ids) # as ints

        rooms.info ids, (result) ->
            resultToResponse result, res

# Responds with an array of building names
exports.buildings = (req, res, next) ->
    resultToResponse buildings.names, res

# Responds with an array of objects,
# each of which has a name (the campus area) and an array of the buildings in that area
exports.campus_areas = (req, res, next) ->
    resultToResponse buildings.campusAreas, res
