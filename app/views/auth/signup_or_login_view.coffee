SignupLoginTemplate = require 'views/auth/templates/signup_login'

SignupStep1View = require 'views/auth/signup_step_1'
LoginStep1 = require 'views/auth/login_step_1'

module.exports = SignupOrLoginView = Backbone.View.extend
  tagName: 'div'
  template: SignupLoginTemplate
  initialize: ->
    @render()
    $('#authViews').html @$el

  render: ->
    @$el.html @template
    @$el.foundation()
    return @

  events:
    'click #signupWay': 'signupWay'
    'click #loginWay': 'loginWay'

  signupWay: (e)->
    e.preventDefault()
    new SignupStep1View
    @remove()

  loginWay: (e)->
    e.preventDefault()
    new LoginStep1
    @remove()