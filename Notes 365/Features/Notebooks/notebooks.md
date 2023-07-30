#  Notebooks


## current
- contains nested hierarcy of notebooks
- heirarcy is stored in local plist for now; (later have to save in cloud folder)
- content of each notebook is saved in .md file
- each nested notebooks level is under a /folder with parent notebook name (better to use UUID instead of filename; as the store of files are not visible; then can be exported)
- hierarcy operations - add/delete/move/get/getchildren/
- content operations - save/update/delete
- diff operation to track timeline changes

## future
- sync local and cloud hierarcy and folder/file contents
- disable/enable cloud


- will take care of only notebooks
- not timeline, not today version


# Unit Testing
- test notebooks list - add inside, add below, remove, rename
- test content - load, save, update


are you testing business layer or state models?
- it doesn't matter, test a small independent feature. means trigger access visible functions (mostly these are state models), the underlaying business logic will be also covered.


# Inputs



# Operations



# Output


for results count



all - hidden
search results
recently modified
deleted items

notebooks + all
notebooks + search
notebooks + recently modified

recently deleted + all


can we hide or remove - searchable
