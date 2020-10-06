import noUserTemplate from './templates/no_user.hbs'

export default Marionette.ItemView.extend({
  tagName: 'li',
  className: 'text-center hidden',
  template: noUserTemplate,

  onShow () { this.$el.fadeIn() },

  serializeData () {
    return { message: this.options.message || "can't find anyone with that name" }
  }
})
