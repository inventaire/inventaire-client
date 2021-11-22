import noUserTemplate from './templates/no_user.hbs'

export default Marionette.View.extend({
  tagName: 'li',
  className: 'text-center hidden',
  template: noUserTemplate,

  onRender () { this.$el.fadeIn() },

  serializeData () {
    return { message: this.options.message || "can't find anyone with that name" }
  }
})
