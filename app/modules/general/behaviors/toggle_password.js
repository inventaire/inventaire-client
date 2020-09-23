// requires the view to have a ui.password defined

export default Marionette.Behavior.extend({
  ui: {
    showPassword: '.showPassword'
  },

  initialize () {
    return this.passwordShown = false
  },

  events: {
    'click .showPassword': 'togglePassword'
  },

  togglePassword () {
    if (this.passwordShown) {
      return this.passwordType('password')
    } else { return this.passwordType('text') }
  },

  passwordType (type) {
    const el = this.view.ui.passwords || this.view.ui.password
    el.attr('type', type)
    this.ui.showPassword.toggleClass('toggled')
    return this.passwordShown = !this.passwordShown
  }
})
