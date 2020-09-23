export default Marionette.ItemView.extend({
  template: require('./templates/candidate_info'),
  className: 'candidate-info',

  initialize () {
    // Terminate the promise
    return this.listenTo(app.vent, 'modal:closed', this.onClose.bind(this))
  },

  onShow () { return app.execute('modal:open') },

  ui: {
    title: 'input[name="title"]',
    authors: 'input[name="authors"]',
    validateInfo: '.validateInfo',
    disabledValidateInfo: '.disabledValidateInfo'
  },

  events: {
    'keyup input[name="title"]': 'updateButton',
    'click .validateInfo': 'validateInfo'
  },

  updateButton (e) {
    if (e.currentTarget.value === '') {
      this.ui.validateInfo.addClass('hidden')
      return this.ui.disabledValidateInfo.removeClass('hidden')
    } else {
      this.ui.disabledValidateInfo.addClass('hidden')
      return this.ui.validateInfo.removeClass('hidden')
    }
  },

  validateInfo () {
    const title = this.ui.title.val()
    const authors = this.ui.authors.val()
    this.options.resolve({ title, authors })
    this._resolved = true
    return app.execute('modal:close')
  },

  onClose () {
    if (!this._resolved) { return this.options.reject(new Error('modal closed')) }
  }
})
