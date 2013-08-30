Page          = require './seleniumPage'
async         = require 'async'

module.exports = class StoreEvaluationsPage extends Page
  visit: (storeSlug, cb) => super "#{storeSlug}#evaluations", cb
  evaluations: (cb) ->
    @findElementsIn('#evaluations', '.evaluation').then (els) =>
      getEvaluationsAction =
        for el in els
          do (el) =>
            (getEvaluationCb) =>
              getEvaluationActions =
                userName: (cb) => @getTextIn el, ".userName", (t) -> cb null, t
                userPicture: (cb) => @getSrcIn el, ".userPicture", (t) -> cb null, t
                body: (cb) => @getTextIn el, ".body", (t) -> cb null, t
                date: (cb) => @getTextIn el, ".date", (t) -> cb null, t
                rating: (cb) => @getTextIn el, ".rating", (t) -> cb null, parseInt t
              async.parallel getEvaluationActions, getEvaluationCb
      async.parallel getEvaluationsAction, (err, evaluations) -> cb evaluations
