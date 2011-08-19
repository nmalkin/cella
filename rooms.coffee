db = require('./housing.js').db
buildings = require('./buildings').buildings

# Returns true if the given variable is an array.
# The check is done using the method recommended here:
#   http://stackoverflow.com/questions/4775722/javascript-check-if-object-is-array
isArray = (variable) ->
    Object.prototype.toString.call variable == '[object Array]'

# Returns true if this is an array that has at least one element
nonEmptyArray = (arr) ->
    (isArray arr) and arr.length > 0

# Looks up rooms that match the given occupancy [an array of ints] 
# and are in the given buildings [an array of strings],
# then calls the callback with the array of room ids
exports.select = (occupancy, buildings, callback) ->
    console.log "Selecting rooms of size #{ occupancy } in #{ buildings }"

    query = 'SELECT rowid FROM rooms WHERE ('
    params = []
    
    buildQuery = (database_field, values) ->
        if nonEmptyArray values
            # get the first allowed value
            query += database_field + ' = ?'
            params.push values[0]

            # if there are any other values, get them now
            for value in values[1..]
                query += " OR #{ database_field } = ?"
                params.push value
        else
            console.error "Invalid #{ database_field }: #{ values}"
    
    buildQuery 'occupancy', occupancy
    query += ') AND ('
    buildQuery 'building', buildings
    query += ')'

    db.all query, params, (err, rows) ->
        if err?
            console.error "An error occurred with the query: #{ error }"
            callback [] # return empty array
        else
            console.log "Search returned #{ rows.length } results"

            # get the ids from the rows and put them in to an array
            # then give it to the callback
            callback (row.rowid for row in rows)
    return # otherwise, the database object would be returned

# Looks up information about the given rooms [an array of room ids].
# Calls the callback with an array of objects, each of which has an
#  * id
#  * building
#  * room [room number]
#  * occupancy
#  * apartment: true if apartment rate is applicable
#  * sophomore: true if sophomore-only
#  * gender_neutral: true/false
exports.info = (ids, callback) ->
    console.log "Information requested about rooms #{ ids }"
    
    query = 'SELECT rowid, * FROM rooms WHERE '
    params = []

    if nonEmptyArray ids
        # get the first allowed value
        query += 'rowid = ?'
        params.push ids[0]

        # if there are any other ids, get them now
        for value in ids[1..]
            query += " OR rowid = ?"
            params.push value
    else
        console.error "Invalid room id: #{ ids}"
    
    db.all query, params, (err, rows) ->
         if err?
            console.error "An error occurred with the query: #{ error }"
            callback [] # return empty array
         else
            console.log "Successfully received information about #{ rows.length } rooms"
            results = []
            # rows is an array of objects with the data.
            # for each result,
            # construct a new object with just the information in the format we need
            # and return it to the callback.
            for row in rows
                result =
                    id: row.rowid
                    building: row.building
                    room: row.roomNumber
                    occupancy: row.occupancy
                    apartment: row.apartmentRate?
                    sophomore: buildings[row.building].sophomore
                    gender_neutral: buildings[row.building].gender_neutral
                
                results.push result
            callback results

