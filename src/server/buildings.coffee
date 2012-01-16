db = require('./housing.js').db

# An object with properties for each of the buildings
exports.buildings = {}
# An array of all the building names, sorted
exports.names = []
# An array of objects, 
# each of which has a name (the campus area) and an array of the buildings in that area
# sorted by name, alphabetically
exports.campusAreas = []
# An array with the names of buildings that are sophomore-only.
exports.sophomoreOnly = []

# load all buildings from database and build derivatives
do ->
    db.all 'SELECT * FROM buildings', (err, rows) ->
        if err?
            console.log 'An error occurred when selecting buildings'
        else
            campusAreas = {}

            for row in rows
                # store the building
                exports.buildings[row.building] =
                    campus_area: row.campus_area
                    gender_neutral: row.gender_neutral == 1
                    sophomore: row.sophomore_only == 1
                
                # remember what campus area it's in
                campusArea = row.campus_area
                if not campusAreas[campusArea]?
                    campusAreas[campusArea] = []
                campusAreas[campusArea].push row.building

            exports.names = (building for own building, data of exports.buildings).sort()

            # translate object properties to an array of areas and values
            # Note: we do this so that we can sort the campus areas.
            exports.campusAreas = []
            for own campusArea, data of campusAreas
                exports.campusAreas.push
                    name: campusArea
                    buildings: data

            # sort campus areas by name, alphabetically
            exports.campusAreas.sort (a, b) ->
                a.name > b.name

            # Identify sophomore-only buildings
            exports.sophomoreOnly.push name \
                for name, building of exports.buildings when building.sophomore
