import autosize from 'autosize'

export default Marionette.Behavior.extend({
  ui: {
    textarea: 'textarea'
  },

  events: {
    'elastic:textarea:update': 'update'
  },

  // Init somehow needs to be run on the next tick to be effective
  onRender () {
    setTimeout(this.init.bind(this), 0)
  },

  init () {
    // Known case: the view does not always display a textarea
    if (this.ui.textarea.length === 0) return
    autosize(this.ui.textarea)
  },

  update () {
    autosize.update(this.ui.textarea)
  }
})
