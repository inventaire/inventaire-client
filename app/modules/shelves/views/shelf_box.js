import ShelfEditor from './shelf_editor'
import ShelfItemsAdder from './shelf_items_adder'
import shelfBoxTemplate from './templates/shelf_box.hbs'
import '../scss/shelf_box.scss'

export default Marionette.View.extend({
  className: 'shelfBox',
  template: shelfBoxTemplate,

  initialize () {
    this.isEditable = this.model.get('owner') === app.user.id
  },

  events: {
    'click #showShelfEdit': 'showEditor',
    'click .closeButton': 'closeShelf',
    'click .addItems': 'addItems'
  },

  modelEvents: {
    change: 'lazyRender'
  },

  serializeData () {
    const attrs = this.model.toJSON()
    return _.extend(attrs, {
      isEditable: this.isEditable
    })
  },

  closeShelf () {
    this.triggerMethod('close:shelf')
  },

  showEditor (e) {
    app.layout.showChildView('modal', new ShelfEditor({ model: this.model }))
  },

  addItems () {
    app.layout.showChildView('modal', new ShelfItemsAdder({ model: this.model }))
  }
})
