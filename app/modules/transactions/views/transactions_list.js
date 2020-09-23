import folders from '../lib/folders';

export default Marionette.CompositeView.extend({
  template: require('./templates/transactions_list'),
  className: 'transactionList',
  childViewContainer: '.transactions',
  childView: require('./transaction_preview'),
  emptyView: require('./no_transaction'),
  initialize() {
    this.folder = this.options.folder;
    this.filter = folders[this.folder].filter;
    return this.listenTo(app.vent, 'transactions:folder:change', this.render.bind(this));
  },

  serializeData() {
    const attrs = {};
    attrs[this.folder] = true;
    return attrs;
  }
});
