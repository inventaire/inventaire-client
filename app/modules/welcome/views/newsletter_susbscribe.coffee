email_ = require 'modules/user/lib/email_tests'
forms_ = require 'modules/general/lib/forms'

module.exports =
  subscribeData: ->
    nameBase: 'subscribe'
    field:
      name: 'email'
      placeholder: 'email'
    button:
      icon: 'envelope'
      text: _.i18n 'subscribe'

  subscribeToNewsletter: ->
    email = @ui.email.val()

    _.preq.start()
    .then email_.pass.bind(null, email, '#subscribeField')
    .then @startLoading.bind(@, '#subscribeGroup')
    .then @sendSubscribtionRequest.bind(@, email)
    .then @stopLoading.bind(@)
    .then @subscribtionSuccess.bind(@)
    .catch forms_.catchAlert.bind(null, @)

  sendSubscribtionRequest: (email)->
    _.preq.post app.API.newsletter, {email: email}

  subscribtionSuccess: ->
    # empty email field
    @ui.email.val('')
    @ui.thanks.hide().slideDown()
