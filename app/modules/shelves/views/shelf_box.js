import ShelfEditor from './shelf_editor'
import ShelfItemsAdder from './shelf_items_adder'
import shelfBoxTemplate from './templates/shelf_box.hbs'

export default Marionette.ItemView.extend({
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
    app.layout.modal.show(new ShelfEditor({ model: this.model }))
  },

  addItems () {
    app.layout.modal.show(new ShelfItemsAdder({ model: this.model }))
  }
})
