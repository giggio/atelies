define [
  'jquery'
  'underscore'
  'backboneConfig'
  'handlebars'
  'text!./templates/storesReport.html'
  'boostrap-sortable'
], ($, _, Backbone, Handlebars, storesReportTemplate) ->
  class ApproveStoresView extends Backbone.Open.View
    events: ->
      'click #exportStoresReport': '_download'
    template: storesReportTemplate
    initialize: (opt) ->
      @stores = opt.stores.toJSON()
    render: ->
      context = Handlebars.compile @template
      numberOfProducts = numberOfOrders = evaluationAvgRating = numberOfEvaluations = numberOfApprovedFlyers = numberOfPagseguroEnabled = 0
      for store in @stores
        store.categories = _.reduce(store.categories, ((a, c) -> a += ", #{c}"), "").replace ", ", ""
        store.hasEvaluations = store.numberOfEvaluations > 0
        store.dateCreated = new Date parseInt(store._id.slice(0,8), 16)*1000
        numberOfProducts+= store.numberOfProducts or 0
        numberOfOrders += store.numberOfOrders or 0
        if store.numberOfEvaluations > 0
          evaluationAvgRating += (evaluationAvgRating*numberOfEvaluations + store.evaluationAvgRating*store.numberOfEvaluations) / (numberOfEvaluations+store.numberOfEvaluations)
          numberOfEvaluations += store.numberOfEvaluations
        numberOfApprovedFlyers++ if store.isFlyerAuthorized
        numberOfPagseguroEnabled++ if store.pagseguro
      @$el.html context stores: @stores, numberOfProducts: numberOfProducts, numberOfOrders: numberOfOrders, evaluationAvgRating: evaluationAvgRating, numberOfEvaluations: numberOfEvaluations, numberOfApprovedFlyers: numberOfApprovedFlyers, numberOfPagseguroEnabled: numberOfPagseguroEnabled, numberOfStores: @stores.length
      $.bootstrapSortable()
      @$('#storesReport .name').popover
        trigger: 'hover'
        container: '#storesReport'
        html: on
        delay: show: 50, hide: 5000
      @$('#storesReport .categories').popover
        trigger: 'hover'
        container: '#storesReport'
        html: off
        delay: show: 50, hide: 5000
      @$('#storesReport .ownerName').popover
        trigger: 'hover'
        container: '#storesReport'
        html: on
    _download: ->
      csv = "_id;name;slug;email;description;urlFacebook;urlTwitter;phoneNumber;city;state;zip;otherUrl;numberOfEvaluations;evaluationAvgRating;isFlyerAuthorized;categories;pagseguro;ownerName;ownerEmail;hasEvaluations;dateCreated\n"
      for store in @stores
        csv += "\"#{store['_id']}\";\"#{store['name']}\";\"#{store['slug']}\";\"#{store['email']}\";\"#{store['description']}\";\"#{store['urlFacebook']}\";\"#{store['urlTwitter']}\";\"#{store['phoneNumber']}\";\"#{store['city']}\";\"#{store['state']}\";\"#{store['zip']}\";\"#{store['otherUrl']}\";\"#{store['numberOfEvaluations']}\";\"#{store['evaluationAvgRating']}\";\"#{store['isFlyerAuthorized']}\";\"#{store['categories']}\";\"#{store['pagseguro']}\";\"#{store['ownerName']}\";\"#{store['ownerEmail']}\";\"#{store['hasEvaluations']}\";\"#{store['dateCreated']}\"\n"
      csv.substr 0, csv.length - 1
      blob = new Blob [csv], type: "text/csv"
      url = URL.createObjectURL(blob)
      a = $('<a target="_blank" download="stores.csv" data-not-push-state="true"></a>')[0]
      a.href = url
      a.click()
