module.exports = Backbone.Marionette.ItemView.extend
  tagName: 'div'
  template: require './templates/valid_email_confirmation'
  onShow: ->  app.execute('modal:open')

  serializeData: ->
    validEmail: @options.validEmail is "true"
