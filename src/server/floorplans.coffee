## This module provides an API for looking up the floorplans for a given room.

# A map from the building name to the floorplan file prefix
building_map = null

# URL portions
PREFIX = 'http://reslife.brown.edu/current_students/lottery/floorplans/'
SUFFIX = '.pdf'


# On startup
do ->
    fs = require 'fs'
    fs.readFile __dirname + '/..' + '/data/floorplans.json',
        (err, data) ->
            if err
                console.error err
            else
                try
                    building_map = JSON.parse data
                catch err
                    console.error err

# Given a building and a room number (as string), returns the URL of the floorplan.
# The prefix for the appropriate building is looked up in the building_map,
# and we get the floor by looking at the first digit of the room number.
# (XXX: this is a strong assumption; any counterexamples should be reported.)
exports.url = (building, room) ->
    if (not building_map?) or not (building of building_map)
        return null
    else if building == 'Hegeman' # special case: Hegeman
        PREFIX + building_map[building] + room[1] + SUFFIX
    else if building == '315 Thayer' # special case: 315 Thayer
        PREFIX + building_map[building] + SUFFIX
    else
        PREFIX + building_map[building] + room[0] + SUFFIX
