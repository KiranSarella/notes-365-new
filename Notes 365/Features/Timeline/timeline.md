#  Timeline

- day, week, month - calender views
- day content, week content, month content
- path of each note change

- take responsibility to create version in respective timeline path
    - on notebook close/save/update get notification
    - get base verion from today verson business
    - get new content from notebook editor
    - do string diff to get only modified content
    - save it.


#  Timeline View

- maintain only one selectedDate
- when month is selected, reset to 1st of that month
- when week is selected, reset to 1st day of that week


#### Navigation Date vs Selected (Day/Week/Month) Date:
- after selection on (day/week/month) button/block, then only the detail should load.
- while navigating? all day/week/month should be in sync
    - sync? describe..
    - navigation date will be ignored while changing calender type.
    
    

## to fix navigation to work on both iOS, iPadOS:
iOS - using navigation link and navigation destination in calender views
iPad - using contentView - detail block



# Inputs
notebook updated/saved notification with new content and path 

# Operations
#### notebook updated/saved notication
- get base version content from /todaysVersion
- get updated version content from - notification
- do string diff.
- save notechanges in to timeline path

# Outputs
- notechanges will be saved to timeline path



year
month
day
content
id
filename
path
date

