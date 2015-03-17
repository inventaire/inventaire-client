SignupClassic = require './signup_classic'
SignupPersona = require './signup_persona'

module.exports = Backbone.Marionette.LayoutView.extend
  className: 'book-bg'
  template: require './templates/signup'
  regions:
    classic: '#classic'
    persona: '#persona'

  onShow: ->
    @classic.show new SignupClassic
    @persona.show new SignupPersona

  serializeData:->
    smallscreen: _.smallScreen()
