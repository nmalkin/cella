## CONSTANTS

MIN_LOTTERY_NUMBER = 1
MAX_LOTTERY_NUMBER = 800

SOPHOMORE_CHECKBOX = '#sophomore'
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
STAR_PLACEHOLDER_MESSAGE = '<tr><td colspan="7" style="text-align: center">
                                Starred results will appear in this tab.
                            </td></tr>'

# COLORS

PROBABILITY_COLORS_DARK = [
    'rgb(204, 57, 74)'  # very unlikely
    'rgb(240, 144, 34)' # unlikely
    'rgb(219, 202, 68)' # average
    'rgb(20, 199, 89)'  # likely
    'rgb(0, 133, 4)'    # very likely
]

PROBABILITY_COLORS = [
    'rgb(245, 79, 98)'  # very unlikely
    'rgb(255, 179, 87)' # unlikely
    'rgb(240, 222, 82)' # average
    'rgb(23, 230, 74)'  # likely
    'rgb(0, 184, 9)'    # very likely
]

NO_RESULT_PLACEHOLDER_MESSAGE = '<tr><td colspan="7" style="text-align: center">
                                No results were found. Try some other criteria.
                            </td></tr>'

# PARAMETERIZED CONSTANTS

TAB = (tabNumber) -> "#tab#{ tabNumber }"
    # NOTE: this scheme is also used in loadNewTab and getActivatedTab
