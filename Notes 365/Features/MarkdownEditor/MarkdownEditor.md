# Markdown Editor

# Overview
- WYSIWYG markdown editor.
- purpose is we give content, display it, after editing give the udpated content when ever some object asks.
- Don't do any loading/saving on yourself.


# Inputs
- file name
- file content
- selected theme


# Operations
- show content
- make editable editor


# Outputs
- give updated content when asked / when registed notification for changes.




# ContentEdited 
(*true/false* is Important for every new editing/formating action)
FormatOptionsView => contentEdited = true
TextDidChange => contentEdited = true
