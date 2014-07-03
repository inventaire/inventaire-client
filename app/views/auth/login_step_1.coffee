LoginStep1Template = require 'views/auth/templates/login_step1'

module.exports = LoginStep1View = Backbone.View.extend
  tagName: 'div'
  template: LoginStep1Template
  initialize: ->
    @render()
    $('#authViews').html @$el

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