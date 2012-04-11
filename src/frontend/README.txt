Following are the descriptions of the files that make up the frontend of Cella.
In the build process, they are all joined into one file, then compiled into JavaScript.
The resultant file is index.js (located in public/scripts).

*** Be sure that any additions or removals here are reflected in the build file! ***

==> availability.coffee <==
## Functions for retrieving and updating the availability of rooms

==> constants.coffee <==
## CONSTANTS

==> debug.coffee <==
## DEBUG

==> events.coffee <==
## Functions that respond to events that occur in the application.

==> filters.coffee <==
## Functions that have to do with setting and getting the filter values
#  -- the select boxes that specify desired room attributes
#  (e.g., occupancy, buildings)

==> globals.coffee <==
## GLOBALS

==> persistence.coffee <==
## Functions having to do with the persistent storage of data across sessions

==> probability.coffee <==
## Functions that have to do with calculating the probability of obtaining rooms.
#  Also includes functions for setting/retrieving lottery number
#  (since that is the primary determinant of the probability).

==> roomdisplay.coffee <==
## Functions that have to do with the display of the rooms
#  (adding, removing, generating HTML for them).

==> roomprocessing.coffee <==
## Functions having to do with processing rooms:
#  looking them up, activating them

==> star.coffee <==
## Functions that deal with the process of starring rooms.

==> startup.coffee <==
## Functions that initialize the application

==> tabs.coffee <==
## Functions that deal the creation, deletion, and information-gathering about tabs.

