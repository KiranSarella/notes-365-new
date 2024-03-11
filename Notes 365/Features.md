# Backlogs
[ ] default themes cells view
    - 1. gray - menlo
    - 2. 
    - 3. 
    - 4.
    - check text editors and prepare 
    - atleast 4 themes
    
[ ] read text
[ ] read in background audio
[ ] TipKit
[ ] MetricKit
[ ] update search UI
[ ] minimap with headings selection and with horizontal interactive scroll bar
[ ] folding - expand collapse heading sections as scope
// editor related
[] on hover on a line or block, control chars should visible
[ ] export all notebooks - ext?
[ ] do not track flag - (until that book closed)
[ ] table block - new syntax
 
# Issues 
[x] months tabs - not working - showing empty 
[ ] show year in timeline if year is not current year (for folders) 
[ ] update UI for search content
[ ] calendar state not preserving on sidebar navigation change
[ ] cancel loading timelines if user moved to other sidebar.
// search
[ ] limit search content results (100) and - use load more
[ ] search results sort based on alphabetic or (count if possible) 
[ ] search is crasing for 'ipad' keyword
[ ] search not working for two chars
[ ] search paths are not working - priority
[ ] searhc inputs - need fuzy search like so, (ex: ipad hang) - should show results for `ipad hang`, `ipad`, `hang` also.


#### editor related
[ ] replace matched options are showing in editor?
[ ] diff - just for two new words added in different paras, whole paras are timelined insteated of two lines
[ ] emoji and telugu not working in code block
[ ] code block not working in timeline
[ ] in different bg, code block is not visible


# Completed
[x] hang on inner file and folder deleting
[x] timeline filter tabs with all first level folders
[x] single line full path for recents and search content rows



Yearly - 395
Lifetime - 1349
Family Sharing - 749



timeline loading data
- to apply folder filters later in mind
    - fetch only info, not content
- once all filers applied for that day, then process each day content with delay and cancel task on dates changed.
- use scrollview only, but use single data source list
    - why single view, because the scrollID should be wrt timeline block, not wrt day block.
    - append each item once content is loaded
    - append date header if record is first one on that day
    - on discard?
        - create id for each day and keep in each contentdata
        - using that id, we can get all records in a day.
        - id records are empty, remove date header with that id 
