# Backlogs
[ ] read text
[ ] read in background audio
[ ] TipKit
[ ] MetricKit
[ ] update search UI
 
# Issues 
[ ] limit search content results (100) and - use load more
[ ] update UI for search content
[ ] search results sort based on alphabetic or (count if possible)
[ ] calendar state not preserving on sidebar navigation change 

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
