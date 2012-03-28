## Functions having to do with the persistent storage of data across sessions

# Saves key->item in persistent storage
savePersistent = (key, item) ->
    sessionStorage.setItem key, JSON.stringify item

# Retrieves the item at the given key from persistent storage,
# automatically parsing it as JSON
getPersistent = (key) ->
    item = sessionStorage.getItem key
    if item?
        JSON.parse item
    else
        null

# Loads buildings from storage (if available) or downloads them from the server
loadBuildings = ->
    _campusAreas = getPersistent '_campusAreas'

    # If buildings haven't been saved yet, get them from the server
    if not _campusAreas?
        $.getJSON 'campus_areas', (result) ->
            _campusAreas = result
            savePersistent '_campusAreas', _campusAreas

# Clears data in persistent storage and displays confirmation message
clearPersistent = () ->
    if window.confirm 'Are you sure you want to reset the application?\n
This will clear any searches and starred rooms.'
        sessionStorage.clear()
        window.location.reload()
