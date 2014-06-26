Page          = require './seleniumPage'
Q             = require 'q'

module.exports = class StoreEvaluationsPage extends Page
  visit: (storeSlug) -> super "#{storeSlug}/evaluations"
  evaluations: ->
    @findElementsIn('#evaluations', '.evaluation').then (els) =>
      getEvaluationsAction = for el in els
        do (el) =>
          @resolveObj
            userName: @getTextIn el, ".userName"
            userPicture: @getSrcIn el, ".userPicture"
            body: @getTextIn el, ".body"
            date: @getTextIn el, ".date"
            rating: @getTextIn(el, ".rating").then (t) -> parseInt t
      Q.all getEvaluationsAction
