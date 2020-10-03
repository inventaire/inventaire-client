export default Marionette.ItemView.extend({
  tagName: 'div',
  className: 'text-center hidden',
  template: require('./templates/no_item.hbs'),
  onShow () { this.$el.fadeIn() },
  serializeData () {
    return {
      showIcon: this.options.showIcon !== false,
      message: this.options.message || 'nothing here'
    }
  }
})
