import { isOpenedOutside } from 'lib/utils'
export default Marionette.ItemView.extend({
  tagName: 'li',
  className: 'imported-item-row',
  template: require('./templates/imported_item_row.hbs'),
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
    if (isOpenedOutside(e)) {

    } else { app.execute('show:item', this.model) }
  }
})
