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

in d2:
case 1. if sync done, and later date check done, this is remove all sync files, because they don't know if that sycned files are todays or old once.
solution: 
maitain folder /2022-04-02 for system date, on every app foreground/launch - remove all folders except that system date folder.


 
