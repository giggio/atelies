Page          = require './seleniumPage'
async         = require 'async'
Q             = require 'q'

module.exports = class StoreEvaluationsPage extends Page
  visit: (storeSlug) -> super "#{storeSlug}/evaluations"
  evaluations: ->
    @findElementsIn('#evaluations', '.evaluation').then (els) =>
      getEvaluationsAction =
        for el in els
          do (el) =>
            (getEvaluationCb) =>
              getEvaluationActions =
                userName: (cb) => @getTextIn(el, ".userName").then (t) -> cb null, t
                userPicture: (cb) => @getSrcIn(el, ".userPicture").then (t) -> cb null, t
                body: (cb) => @getTextIn(el, ".body").then (t) -> cb null, t
                date: (cb) => @getTextIn(el, ".date").then (t) -> cb null, t
                rating: (cb) => @getTextIn(el, ".rating").then (t) -> cb null, parseInt t
              async.parallel getEvaluationActions, getEvaluationCb
      Q.nfcall async.parallel, getEvaluationsAction
