import noItemTemplate from './templates/no_item.hbs'

export default Marionette.View.extend({
  tagName: 'div',
  className: 'text-center',
  template: noItemTemplate,
  serializeData () {
    return {
      showIcon: this.options.showIcon !== false,
      message: this.options.message || 'nothing here'
    }
  }
})
