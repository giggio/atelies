Q = require 'q'
module.exports = class TestFiddlers
  @_errorbacks: []
  @test: (testMethod) ->
    (testCallback) ->

      title = @_runnable.title
      testCompleted = (err) ->
        if err?
          TestFiddlers._notifyOfError title, err
          .then -> testCallback err
        else
          testCallback err

      try
        if testMethod.length is 1 #async test
          testMethod.call @, testCompleted
        else
          result = testMethod.call @
          if typeof result?.then is 'function' #promise
            result.then (-> testCompleted()), testCompleted
          else
            testCompleted()
      catch err
        testCompleted err

  @onTestError: (errorback) -> TestFiddlers._errorbacks.push errorback

  @_notifyOfError: (title, err) ->
    results = (errorback title, err for errorback in TestFiddlers._errorbacks)
    Q.all results
