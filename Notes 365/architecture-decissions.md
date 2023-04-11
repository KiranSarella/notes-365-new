#  Architecture Decissios 
>based on your experience and usecases 

- use extensions for create same feature related functionality (ex: notebook)
- try to separate objects as per the feature instead of where is will be used 
    (ex: VersionBusiness vs Notebook)
- use seperate business object where the conditions that use more then object involved
- avoid nested dependencies (ex: StringDiff)


- state should be light weight
- when a state is removed, the business logic should work
- use notifications to commincat between business - to make more loose coupling
- unit testing - should not include any UI related code

- think like writing apis while working on business layer.
- think like stateless brower UI while working on presentation layer. - temp, might remove in future.

- think of stateless all the time.



## business logic examples
- crud operations



## presentation logic examples
- soring list items
- loading state variables


coordinator? - is required 



we fear because, the business logic is some how dependent on UI state, if that state not loaded the business will not run as expected.
that should not be like that.


