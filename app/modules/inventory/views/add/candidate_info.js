export default Marionette.ItemView.extend({
  template: require('./templates/candidate_info.hbs'),
  className: 'candidate-info',

  initialize () {
    // Terminate the promise
    this.listenTo(app.vent, 'modal:closed', this.onClose.bind(this))
  },

  onShow () { app.execute('modal:open') },

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
      this.ui.disabledValidateInfo.removeClass('hidden')
    } else {
      this.ui.disabledValidateInfo.addClass('hidden')
      this.ui.validateInfo.removeClass('hidden')
    }
  },

  validateInfo () {
    const title = this.ui.title.val()
    const authors = this.ui.authors.val()
    this.options.resolve({ title, authors })
    this._resolved = true
    app.execute('modal:close')
  },

  onClose () {
    if (!this._resolved) { return this.options.reject(new Error('modal closed')) }
  }
})
