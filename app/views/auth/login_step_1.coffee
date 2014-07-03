LoginStep1Template = require 'views/auth/templates/login_step1'

module.exports = SignupStep2View = Backbone.View.extend
  el: '#authViews'
  template: LoginStep1Template
  initialize: ->
    @render()

  render: ->
    @$el.html @template
    @$el.foundation()
    return @

  events:
    'click #backToSignupOrLoginView': 'backToSignupOrLoginView'

  backToSignupOrLoginView: (e)->
    e.preventDefault()
    # callback scope issue: for some reason, I can't find a nice way not to require it here oO
    SignupOrLoginView = require "views/auth/signup_or_login_view"
    new SignupOrLoginView