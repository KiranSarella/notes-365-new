# Backlogs
[-] timeline filter tabs with all first level folders
[ ] read text
[ ] read in background audio
[ ] TipKit
[ ] MetricKit

# Issues 
[ ] single line full path for recents and search content rows
[ ] limit search content results (100) and - use load more
[ ] update UI for search content


#### editor related
[ ] replace matched options are showing in editor?
[ ] diff - just for two new words added in different paras, whole paras are timelined insteated of two lines
[ ] emoji and telugu not working in code block
[ ] code block not working in timeline
[ ] in different bg, code block is not visible


# Completed
[x] hang on inner file and folder deleting


# first level filters
[-] have to get all note ids for top level
    - get folders and files for parent
        - files - add to set
        - folders - repeat above steps - recursive
    - you have all note ids set
[ ] get only change note ids for each day
    - filter with noteids set
    - if exists, then load content
    - else repeat for previous day
    - till, last record or first record date



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
