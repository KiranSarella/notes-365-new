#  Architecture Decissios 
>based on your experience and usecases 

- use extensions for create same feature related functionality (ex: notebook)
- try to separate objects as per the feature instead of where is will be used 
    (ex: VersionBusiness vs Notebook)
- use seperate business object where the conditions that use more then object involved
- avoid nested dependencies (ex: StringDiff)


