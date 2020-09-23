import { listingsData } from 'modules/inventory/lib/item_creation';
import forms_ from 'modules/general/lib/forms';
import getActionKey from 'lib/get_action_key';
import UpdateSelector from 'modules/inventory/behaviors/update_selector';
import { deleteShelf, updateShelf } from 'modules/shelves/lib/shelves';
import { startLoading } from 'modules/general/plugins/behaviors';

export default Marionette.LayoutView.extend({
  template: require('./templates/shelf_editor'),

  behaviors: {
    AlertBox: {},
    BackupForm: {},
    ElasticTextarea: {},
    Loading: {},
    UpdateSelector: {
      behaviorClass: UpdateSelector
    }
  },

  events: {
    'keydown .shelfEditor': 'shelfEditorKeyAction',
    'click .validate': 'validateAction',
    'click .delete': 'askDeleteShelf'
  },

  serializeData() {
    return _.extend(this.model.toJSON(),
      {listings: listingsData()});
  },

  onShow() {
    app.execute('modal:open');
    const listing = this.model.get('listing');
    const $el = this.$el.find(`#${listing}`);
    $el.siblings().removeClass('selected');
    return $el.addClass('selected');
  },

  shelfEditorKeyAction(e){
    const key = getActionKey(e);
    if (key === 'esc') {
      return closeModal();
    } else if ((key === 'enter') && e.ctrlKey) {
      return this.validateAction();
    }
  },

  validateAction(e){
    const shelfId = this.model.get('_id');
    const name = $('#shelfNameEditor').val();
    let description = $('#shelfDescEditor').val();
    if (description === '') { description = null; }
    const selected = app.request('last:listing:get');
    startLoading.call(this, '.validate .loading');
    return updateShelf({
      shelf: shelfId,
      name,
      description,
      listing: selected
    })
    .catch(function(err){
      if (err.message === 'nothing to update') { return;
      } else { throw err; }}).then(afterUpdate(selected, this.model))
    .then(closeModal)
    .catch(forms_.catchAlert.bind(null, this));
  },

  askDeleteShelf() {
    return app.execute('ask:confirmation', {
      confirmationText: _.i18n('delete_shelf_confirmation', { name: this.model.get('name') }),
      warningText: _.i18n('cant_undo_warning'),
      action: deleteShelfAction(this.model)
    }
    );
  }
});

var closeModal = e => app.execute('modal:close');

var afterUpdate = (selected, model) => (function(updatedShelf) {
  app.user.trigger('shelves:change', 'createShelf');
  const listingData = listingsData()[selected];
  model.set(updatedShelf);
  model.set('icon', listingData.icon);
  return model.set('label', listingData.label);
});

var deleteShelfAction = (model, withItems) => (function() {
  const id = model.get('_id');
  let params = { ids: id };
  if (withItems) { params = _.extend({ 'with-items': true }, params); }
  return deleteShelf(params)
  .then(_.Log('shelf destroyed'))
  .then(afterShelfDelete)
  .catch(_.ErrorRethrow('shelf delete error'));
});

var afterShelfDelete = function(res){
  app.execute('show:inventory:main:user');
  app.user.trigger('shelves:change', 'removeShelf');
  const { items } = res;
  if (items != null) {
    return items.forEach(function(item){
      const { listing } = item;
      if (listing) {
        return app.user.trigger('items:change', listing, null);
      }
    });
  }
};
