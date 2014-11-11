module.exports = class CommonEl extends Backbone.Marionette.Region
  attachHtml: (view)->
    this.el.innerHTML = view.el.innerHTML
    # seems to be needed as this way to attachHtml
    # messes with the view el at render
    view.bindUIElements()