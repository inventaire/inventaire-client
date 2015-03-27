module.exports = CommonEl = Backbone.Marionette.Region.extend
  attachHtml: (view)->
    # uses the fake region el to have it's own el
    # inserted just after the fake region
    $(view.el).insertAfter @$el