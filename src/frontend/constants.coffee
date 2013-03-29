## CONSTANTS

DATA_EPOCH = 3

MIN_LOTTERY_NUMBER = 1
MAX_LOTTERY_NUMBER = 800

SOPHOMORE_CHECKBOX = '#sophomore'
AVAILABILITY_CHECKBOX = '#exclude-unavailable'
LOTTERY_SLIDER = '#lottery'
LOTTERY_NUMBER_DISPLAY = '#lottery_number'
LOADING_MESSAGE = '#loading'
NEW_TAB_BUTTON = '#new_tab'
RESULT_TABS = '#result_tabs'
RESULT_TABLES = '#result_tables'
ROOM_TABLE = '.room_table'
RESULTS_DIV = '.results'
OCCUPANCY_FIELD = '.occupancy'
BUILDING_MODE_FIELD = '.building-mode'
BUILDINGS_FIELD = '.select-buildings'
PROBABILITY_TEXT = '.probability-text'
SHARE_WELL = '#share-well'
SHARE_WELL_TOGGLE = '#toggle-share-well'
SHARE_LINK = '#share-link'
IMPORT_WINDOW_URL = 'import_rooms.html'
IMPORT_WINDOW = '#import-modal'
IMPORT_ROOM_LIST = '#import-room-list'
IMPORT_UNION = '.import-union'
IMPORT_REPLACE = '.import-replace'
IMPORT_CONFLICT = '#import-conflict'
IMPORT_NO_CONFLICT = '#import-no-conflict'

NO_AVAILABILITY_DATA = 'availability not available'
ROOM_NOT_AVAILABLE = '.roomUnavailable'
ROOMS_HIDDEN_PLACEHOLDER = '.roomsHidden'

STAR_TAB = 0
STAR_TABLE = '#star-table'
STAR_FILLED = '&#9733;'
STAR_EMPTY = '&#9734;'
STAR_PLACEHOLDER_MESSAGE = '<tr><td colspan="7" style="text-align: center">
                                Starred results will appear in this tab.
                            </td></tr>'

# LABELS
APARTMENT_RATE_LABEL = '<a href="http://brown.edu/lottery/rooms/rates.php" style="color:inherit" target="_blank">Apartment Rate</a>'
SOPHOMORE_LABEL = 'Sophomore-Only'
GENDER_NEUTRAL_LABEL = '<a href="http://brown.edu/lottery/rooms/gender_neutral.php" target="_blank" style="color:inherit">Gender-Neutral</a>'
FLOORPLAN_LABEL = (room) ->
    "<a href=\"/floorplan?building=#{ encodeURIComponent room.building }&room=#{ room.room }\"
    rel=\"tooltip\" title=\"Click to access floorplans\"
    target=\"_blank\"
    style=\"color:inherit\">Floorplan</a>"


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

# Label color classes
FLOORPLAN_COLOR = 'floorplan_color'
APARTMENT_RATE_COLOR = 'apartment_rate_color'
SOPHOMORE_COLOR = 'sophomore_color'
GENDER_NEUTRAL_COLOR = 'gender_neutral_color'

NO_RESULT_PLACEHOLDER_MESSAGE = '<tr><td colspan="7" style="text-align: center">
                                No results were found. Try some other criteria.
                            </td>
                            <td class="no-width"></td>
                            <td class="no-width"></td>
                            <td class="no-width"></td>
                            <td class="no-width"></td>
                            <td class="no-width"></td>
                            <td class="no-width"></td>
                            </tr>'

NO_RESULT_POSSIBLE_PLACEHOLDER_MESSAGE = '<tr><td colspan="7" style="text-align: center">
    To get results, make sure both occupancy and buildings are selected.
    </td>
    <td class="no-width"></td>
    <td class="no-width"></td>
    <td class="no-width"></td>
    <td class="no-width"></td>
    <td class="no-width"></td>
    <td class="no-width"></td>
    </tr>'
# PARAMETERIZED CONSTANTS

# Given a constant (like the ones above), removes the first character,
# which would be the . (for classes) or # (for IDs)
NAME = (constant) -> constant.substring(1)

TAB = (tabNumber) -> "#tab#{ tabNumber }"

CONTROL = (tabNumber) -> "#tab#{ tabNumber }control"

ROOM = (roomID) -> ".room#{ roomID }"

PROBABILITY = (roomID) -> ".room#{ roomID }probability"

AVAILABILITY = (roomID) -> ".availability#{ roomID }"

HIDDEN_ROOMS = (count) ->
    if count == 1
        words = ['room is', 'it is', 'it']
    else
        words = ['rooms are', 'they are', 'them']

    "<tr class=\"#{ NAME ROOMS_HIDDEN_PLACEHOLDER }\">" +
    '<td colspan="7" style="text-align: center"> ' + 
    "#{ count } #{ words[0] } " +
    "not shown because #{ words[1] } unavailable. " +
    "<a onclick=\"$('#{ AVAILABILITY_CHECKBOX }').prop('checked',false).trigger('change')\">Show #{ words[2] } now</a>." +
    '</td>
    <td class="no-width"></td>
    <td class="no-width"></td>
    <td class="no-width"></td>
    <td class="no-width"></td>
    <td class="no-width"></td>
    <td class="no-width"></td>
</tr>'

MOTD = '#motd-text'
PREVIOUS_HINT = '#previous-hint'
NEXT_HINT = '#next-hint'
HINTS = [
    'Hint: click the + icon to open a new search tab',
    'Hint: sort results by clicking on the column headers',
    'Hint: sort results by <i>multiple columns</i> by pressing down the <i>Shift</i> key when clicking on the header',
    'Hint: click on the stars next to the results to add them to the "star tab"',
    'Hint: rearrange results in the star tab by dragging and dropping',
    'Hint: adjust your lottery number to get a probability estimate'
    'Hint: hover over the probability bar to see past results',
    'The availability data is updated based on the <a href="http://www.brown.edu/Student_Services/Residential_Council/lottery/broadcast/" target="_blank">online lottery projection</a> every two hours.'
    'During the lottery, availability changes show up automatically - no need to refresh the page!'
    'Hint: if you navigate away from the page, your results will be here when you come back'
]
