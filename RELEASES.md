A brief list of new features and changes introduced with the specified version.

### 0.20.0
* [Add back ActiveSupport](https://github.com/adomokos/light-service/pull/259)
* [Fix argument errors of LightService::LocalizationAdapter](https://github.com/adomokos/light-service/pull/263)
* [Change deprecation_warning method call](https://github.com/adomokos/light-service/pull/265)

### 0.19.0
* [Implement built-in localization adapter](https://github.com/adomokos/light-service/pull/238)
* [Swap ActiveSupport::Deprecation with built-in LightSupport::Deprecation](https://github.com/adomokos/light-service/pull/241)
* [Remove Active Support dependency](https://github.com/adomokos/light-service/pull/246)

### 0.18.0
* [Remove Ruby 2.6, add 3.1 to build](https://github.com/adomokos/light-service/pull/233)
* [Add reduce_when](https://github.com/adomokos/light-service/pull/232)
* [Drop Ruby 2.5 version support, add 3.0 build](https://github.com/adomokos/light-service/pull/225)
* [Support for named argument in Ruby](https://github.com/adomokos/light-service/pull/224)

### 0.17.0
* [Fix around_action hook for nested actions](https://github.com/adomokos/light-service/pull/217)
* [Add ReduceIfElse macro](https://github.com/adomokos/light-service/pull/218)
* [Implement support for default values for optional expected keys](https://github.com/adomokos/light-service/pull/219)
* [Add light-service.js implementation to README](https://github.com/adomokos/light-service/pull/222)

### 0.16.0
* [Drop Ruby 2.4 support](https://github.com/adomokos/light-service/pull/207)
* [Fix callback current action](https://github.com/adomokos/light-service/pull/209)
* [Add Context accessors](https://github.com/adomokos/light-service/pull/211)
* [Switched to GH Actions from Travis CI](https://github.com/adomokos/light-service/pull/212)

### 0.15.0
* [Add Rails Generators](https://github.com/adomokos/light-service/pull/194) - LightService actions and organizers can be generated with generators
* [Add CodeCov](https://github.com/adomokos/light-service/pull/195) - Upload code coverage report to codecov.io
* [Remove ActiveSupport 3 checks](https://github.com/adomokos/light-service/pull/197) - They are unsupported, no need to tests them any more.

### 0.14.0
* [Add 'organized_by' to context](https://github.com/adomokos/light-service/pull/192) - Context now have an #organized_by attribute

### 0.13.0
* [Add 'add_to_context' and 'add_aliases'](https://github.com/adomokos/light-service/pull/172) - Updating Ruby compatibility, minor fixes

### 0.12.0
* [Per organizer logger](https://github.com/adomokos/light-service/pull/162)
* [Fix 'fail_and_return!' not accepting 'error_code' option](https://github.com/adomokos/light-service/pull/168)

### 0.11.0
* [Switch to 'each_with_object' in WithReducer](https://github.com/adomokos/light-service/pull/149).

### 0.10.3
* [Adding ContextFactory](https://github.com/adomokos/light-service/pull/147).

### 0.10.2
* [Revert 0.10.1](https://github.com/adomokos/light-service/pull/146), it breaks tests in our apps :-(.

### 0.10.1
* [Fixing ContextFactory](https://github.com/adomokos/light-service/pull/141) for orchestrator methods in Organizers.

### 0.10.0
* Adding [before_actions and after_actions hooks](https://github.com/adomokos/light-service/pull/144).

### 0.9.0
* [Deprecate Orchestrator](https://github.com/adomokos/light-service/pull/132) by moving its functionality to Organizers.

### 0.8.4
* Only pass [default argument](https://github.com/adomokos/light-service/pull/123) to Hash#fetch in context if no block given.

### 0.8.3
* Make logging more [efficient](https://github.com/adomokos/light-service/pull/120) the context.

### 0.8.2
* A better way to [inspect](https://github.com/adomokos/light-service/pull/110) the context.
* [Short-circuiting](https://github.com/adomokos/light-service/pull/113) the Orchestrator methods.
* [Fail and return - with one call](https://github.com/adomokos/light-service/pull/115), no `and next` is needed.
* Adding [with_callback](https://github.com/adomokos/light-service/pull/116) to Orchestrators, allows us to process large data in smaller chunks.

### 0.8.1
* Renaming `skip_all!` to [skip_remaining!](https://github.com/adomokos/light-service/pull/103).
* Adding [ContextFactory](https://github.com/adomokos/light-service/pull/107) for easier testing.

### 0.8.0
* Adding [orchestrators](https://github.com/adomokos/light-service/pull/99).

### 0.7.0
* Organizers should have a public method [call](https://github.com/adomokos/light-service/pull/98) in preparation of orchestrators.

### 0.6.1
* Introducing [around_each](https://github.com/adomokos/light-service/pull/79) for AOP style logging and code execution
* Introducing [Rubocop](https://github.com/adomokos/light-service/commit/39aa7ea39f69a16c2df66b213fb6d638796e25f2) to the project, forcing consistant style

### 0.6.0
* Using [extend](https://github.com/adomokos/light-service/pull/64) for using class methods in Actions and Organizers
* Setting [key aliases](https://github.com/adomokos/light-service/pull/69) for the Context from the Organizer

### 0.5.2
* Guarding context keys against the reserved keys the context needs to operate.

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
