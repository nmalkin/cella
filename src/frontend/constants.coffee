## CONSTANTS

MIN_LOTTERY_NUMBER = 1
MAX_LOTTERY_NUMBER = 800

LOTTERY_SLIDER = '#lottery'
LOTTERY_NUMBER_DISPLAY = '#lottery_number'
NEW_TAB_BUTTON = '#new_tab'
RESULT_TABS = '#result_tabs'
RESULT_TABLES = '#result_tables'
ROOM_TABLE = '.room_table'
RESULTS_DIV = '.results'
OCCUPANCY_FIELD = '.occupancy'
BUILDING_MODE_FIELD = '.building-mode'
BUILDINGS_FIELD = '.select-buildings'

STAR_TAB = 0
STAR_FILLED = '&#9733;'
STAR_EMPTY = '&#9734;'

# PARAMETERIZED CONSTANTS

TAB = (tabNumber) -> "#tab#{ tabNumber }"
    # NOTE: this scheme is also used in loadNewTab and getActivatedTab