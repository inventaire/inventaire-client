export default Marionette.ItemView.extend({
  tagName: 'li',
  className: 'text-center hidden',
  template: require('./templates/no_user.hbs'),

  onShow () { this.$el.fadeIn() },

  serializeData () {
    return { message: this.options.message || "can't find anyone with that name" }
  }
})
