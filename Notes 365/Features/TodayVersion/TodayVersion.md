#  Today Version


- able to decide which day the system is
- able to remove/clean yesterdays version files
- able to sync with iCloud
- on notebook open, create base version for that day


# Inputs
device date
notebook loaded content notification - with path 

# Operations
#### device date
- on app launch, get device date and clear all old base versions
- at exactly 12:00 am, get notification and clear all base versions
#### notebook loaded notification
- creates base version daily in /todaysVersion folder

# Outputs
gives today base version for the given uuid

# Questions
how to know if base version file is todays or old one? - that was synced from iCloud.
- based on user defaults sync date.
- need to do icloud sync user defaults also.


# iCloud Sync Steps
- on app launch force fetch/sync /today-base-version folder files
    - using metadataQuery get added, removed, updated items and do the same actions manually.


### When to sync?
1. ~~on app launch~~ - not required
2. 
    


https://stackoverflow.com/questions/49066409/nsmetadataquery-by-folders-ios

