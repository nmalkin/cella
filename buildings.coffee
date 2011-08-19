db = require('./housing.js').db

# load all buildings to exports.buildings
( ->
    exports.buildings = []
    db.each 'SELECT * FROM buildings', (err, row) ->
        if err?
            console.log 'An error occurred when selecting buildings'
        else
            exports.buildings[row.building] =
                campus_area: row.campus_area
                gender_neutral: row.gender_neutral == 1
                sophomore: row.sophomore_only == 1
)()
