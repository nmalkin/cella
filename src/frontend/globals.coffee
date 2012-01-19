## GLOBALS

# The number of tables/tabs currently open
tabCount = 0

# Number of the next tab to be created (numbers are not reused)
nextTabNumber = 1 # starts at 1 because 0 is reserved for STAR_TAB

# The number of the currently activated tab
activeTab = -1;

# The number of the previous activated tab
lastActiveTab = -1;

# Whether or not multiple buildings are being selected at once
multiSelect = false;

# The occupancy selected in each tab
selectedOccupancy = []

# The buildings selected in each tab
selectedBuildings = []

# The choice of whether to include or exclude buildings from each tab
selectedIncludes = []

# An array of all campus areas
# Campus areas are objects with a name and an array of buildings
campusAreas = []

# All rooms whose information we have, referenced by id
allRooms = {}

# Array of arrays; each is an array of rooms displayed in respective tab
activeRooms = []
activeRooms[STAR_TAB] = []

# List of rooms that we need to look up
roomsToLookUp = []
