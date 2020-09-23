/* eslint-disable
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Marionette.ItemView.extend({
  tagName: 'li',
  className: 'imported-item-row',
  template: require('./templates/imported_item_row'),
  serializeData () {
    const attrs = this.model.serializeData()
    const [ prefix, id ] = Array.from(attrs.entity.split(':'))
    if (prefix === 'isbn') { attrs.isbn = id }
    return attrs
  },

  events: {
    'click .showItem': 'showItem'
  },

  showItem (e) {
    if (_.isOpenedOutside(e)) {

    } else { return app.execute('show:item', this.model) }
  }
})
