import { listingsData as listingsDataFn } from 'modules/inventory/lib/item_creation';
import getActionKey from 'lib/get_action_key';
import ShelfEditor from './shelf_editor';
import ShelfItemsAdder from './shelf_items_adder';
import Items from 'modules/inventory/collections/items';

export default Marionette.ItemView.extend({
  className: 'shelfBox',
  template: require('./templates/shelf_box'),

  initialize() {
    return this.isEditable = this.model.get('owner') === app.user.id;
  },

  events: {
    'click #showShelfEdit': 'showEditor',
    'click .closeButton': 'closeShelf',
    'click .addItems': 'addItems'
  },

  modelEvents: {
    'change': 'lazyRender'
  },

  serializeData() {
    const attrs = this.model.toJSON();
    return _.extend(attrs,
      {isEditable: this.isEditable});
  },

  closeShelf() {
    const ownerId = this.model.get('owner');
    return this.triggerMethod('close:shelf');
  },

  showEditor(e){
    return app.layout.modal.show(new ShelfEditor({ model: this.model }));
  },

  addItems() {
    return app.layout.modal.show(new ShelfItemsAdder({ model: this.model }));
  }});
