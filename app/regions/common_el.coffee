module.exports = class CommonEl extends Backbone.Marionette.Region
  attachHtml: (view)->
    # uses the fake region el to have it's own el
    # inserted just after the fake region
    $(view.el).insertAfter @$el