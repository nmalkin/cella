url = require 'url'

rooms = require './rooms.js'
buildings = require './buildings'


# Given a result, writes it stringified to the response
# with normal HTTP status code and a JSON content-type
resultToResponse = (result, response) ->
    result ?= '' # If nothing else, we'll return an empty string
    response.writeHead 200, {'Content-Type': 'application/json'}
    response.write JSON.stringify result
    response.end '\n'


# Builds a response that is a JSON array of room ids
# of rooms that fit the required features.
exports.get_rooms = (req, res, next) ->
    requiredParams = ['occupancy', 'buildings', 'include_buildings', 'sophomore']

    params = (url.parse req.url, true).query

    # Check for required parameters
    requiredParamsPresent = true 
    requiredParamsPresent &= params[req]? for req in requiredParams
    if not requiredParamsPresent 
        res.writeHead 200, {'Content-Type': 'text/plan'}
        # TODO: I'd like this to be a 400 code, but browsers seem to interpret that as a 404
        res.end 'Missing required parameters\n'
    else
        # multiple values in the query strings will be delimited by commas.
        # explode them into arrays
        req_occupancy = params.occupancy.split ','
        req_buildings = params.buildings.split ','

        # Check for whether the parameter is a boolean.
        # The comparison uses strings since this is a GET request (passed in URL).
        isBoolean = (val) -> val == 'true' or val == 'false'
        booleanValue = (val) -> val == 'true'

        # Include or exclude the buildings from the query? (default: include)
        req_include = if isBoolean params.include_buildings \
            then booleanValue params.include_buildings else true

        # Include sophomore-only housing? (default: no)
        req_sophomore = if isBoolean params.sophomore \
            then booleanValue params.sophomore else false

        # the occupancy values are strings, should be converted to ints
        req_occupancy = (parseInt value for value in req_occupancy \
                     when not isNaN parseInt value) # exclude non-integer values

        if req_occupancy.length == 0
            # There are no valid values for occupancy.
            # Because this happens when the user hasn't inputted all the criteria,
            # we just return no results.
            resultToResponse [], res
        else
            if req_include # If including given buildings:
                # If the user isn't a sophomore, we should check if any of their
                # buildings are sophomore-only (and exclude them).
                if not req_sophomore
                    sophomoreCheck = (building) ->
                        buildings.buildings[building].sophomore == false
                else
                    sophomoreCheck = -> true
            else # If excluding given buildings:
                # If not a sophomore, add sophomore-only buildings to those
                # being excluded.
                if not req_sophomore
                    req_buildings = req_buildings.concat buildings.sophomoreOnly

                sophomoreCheck = -> true

            # Make sure the buildings exist and do the sophomore check, if needed.
            req_buildings = (building for building in req_buildings \
                when buildings.buildings[building]? and sophomoreCheck building)

            rooms.select req_occupancy, req_include, req_buildings, (result) ->
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

# Responds with an object with lottery numbers for the given room
exports.results = (req, res, next) ->
    params = (url.parse req.url, true).query
    
    if not params.id?
        res.writeHead 200, {'Content-Type': 'text/plan'}
        res.end 'Missing required parameter\n'
    else
        id = parseInt params.id
        if isNaN id
            res.writeHead 200, {'Content-Type': 'text/plan'}
            res.end 'Invalid parameter\n'
            return

        rooms.results id, (result) ->
            resultToResponse result, res
