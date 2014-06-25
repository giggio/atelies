mongoose    = require 'mongoose'
_           = require 'underscore'
Q           = require 'q'

evaluationSchema = new mongoose.Schema
  body:         type: String, required: true
  rating:       type: Number, required: true
  date:         type: Date, required: true, default: Date.now
  user:         type: mongoose.Schema.Types.ObjectId, ref: 'user', required: true
  userName:     type: String, required: true
  userEmail:    type: String, required: true
  order:        type: mongoose.Schema.Types.ObjectId, ref: 'order', required: true
  store:        type: mongoose.Schema.Types.ObjectId, ref: 'store', required: true

module.exports = Evaluation = mongoose.model 'storeevaluation', evaluationSchema

Evaluation.create = (evaluationAttrs) ->
  evaluation = new Evaluation evaluationAttrs
  evaluation.userName = evaluationAttrs.user.name
  evaluation.userEmail = evaluationAttrs.user.email
  Q.ninvoke(evaluation, 'validate').then -> evaluation

Evaluation.getSimpleFromStore = (storeId) ->
  Q.ninvoke Evaluation, 'find', { store: storeId }
  .then (evals) ->
    simpleEvals = _.map evals, (e) -> body: e.body, rating: e.rating, date: e.date, userName: e.userName, userEmail: e.userEmail
    simpleEvals
