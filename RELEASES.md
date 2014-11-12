A brief list of new features and changes introduced with the specified version.

### 0.5.1
* Removing the thrown exception for invoking the "executed" macro twice

### 0.5.0
* Adding [rollback](https://github.com/adomokos/light-service#action-rollback) functionality
* Adding [message localization](https://github.com/adomokos/light-service#localizing-messages) feature

### 0.4.0
* Adding [logging](https://github.com/adomokos/light-service#logging) to LightService

### 0.3.6
* [Collecting](https://github.com/adomokos/light-service/commit/29817de3ad589441788077368ad1d7e723286def) the `expects` and `promises` keys when they are called multiple times in an action

### 0.3.5
* remove previously deprecated method Context#context_hash
* [Skipping](https://github.com/adomokos/light-service/commit/d2bd05455a7e4f78aa448db1ea1d692f7b8b67d3) the promised keys check in the context when the context is in failure state

### 0.3.4
* The method call `with` is [now optional](https://github.com/adomokos/light-service/blob/master/spec/organizer_spec.rb#L18) in case you have nothing to put into the context.
* Action name is being displayed in the error message when the expected or promised key is not in the context.

### 0.3.3
* Switching the promises and expects key accessors from Action to Context

### 0.3.2
* Fixing documentation and using separate arguments instead of a hash when setting the context to failure with error code

### 0.3.1
* Adding [error codes](https://github.com/adomokos/light-service#error-codes) to the context

### 0.3.0
* Adding the `expects` and `promises` macros - Read more about it in [this blog post](http://www.adomokos.com/2014/05/expects-and-promises-in-lightservice.html)

### 0.2.2
* Adding the gem version icon to README
* Actions can be invoked now [without arguments](https://github.com/adomokos/light-service/commit/244d5f03b9dbf61c97c1fdb865e6587f9aea177d), this makes it super easy to play with an action in the command line

### 0.2.1
* [Improving](https://github.com/adomokos/light-service/commit/fc7043241396b4a2556e9664c13c6929f8330025) deprecation warning for the renamed methods
* Making the message an optional argument for `succeed!` and `fail!` methods

### 0.2.0
* [Renaming](https://github.com/adomokos/light-service/commit/8d40ff7d393a157a8a558f9e4e021b8731550834) the `set_success!` and `set_failure!` methods to `succeed!` and `fail!`
* [Throwing](https://github.com/adomokos/light-service/commit/5ef315b8aeeafc99e38676adad3c11df5d93b0e3) an ArgumentError if the `make` method's argument is not Hash or LightService::Context
