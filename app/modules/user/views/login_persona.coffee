subject = 'I need help on switching from Persona to an account with a password'

module.exports = Marionette.ItemView.extend
  className: 'authMenu persona'
  template: require './templates/login_persona'
  events:
    'click #createPassword': 'createPassword'
    'click #askForHelp': 'askForHelp'

  createPassword: ->
    app.execute 'show:forgot:password',
      createPasswordMode: true

  askForHelp: ->
    app.execute 'show:feedback:menu',
      subject: _.i18n subject
