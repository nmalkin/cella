## GLOBALS

# The number of tables/tabs currently open
_tabCount = 0

# Number of the next tab to be created (numbers are not reused)
_nextTabNumber = 1 # starts at 1 because 0 is reserved for STAR_TAB

# The number of the currently activated tab
_activeTab = -1;

# The number of the previous activated tab
_lastActiveTab = -1;

# Whether or not multiple buildings are being selected at once
_multiSelect = false;

# The occupancy selected in each tab
_selectedOccupancy = []

# The buildings selected in each tab
_selectedBuildings = []

# The choice of whether to include or exclude buildings from each tab
_selectedIncludes = []

# An array of all campus areas
# Campus areas are objects with a name and an array of buildings
_campusAreas = []

# All rooms whose information we have, referenced by id
_allRooms = {}

# Array of arrays; each is an array of rooms displayed in respective tab
_activeRooms = []
_activeRooms[STAR_TAB] = []

# List of rooms that we need to look up
_roomsToLookUp = []

# For each tab, the lottery number reflected by the rooms' probabilities
_lotteryNumberWhenUpdated = []

# Past results for a particular room
_roomResults = {}

# HTML for a new, blank tab
_newTabHTML = null
