import Shelves from '../collections/shelves';
import { getShelvesByOwner } from 'modules/shelves/lib/shelves';
import ShelvesList from './shelves_list';

export default Marionette.LayoutView.extend({
  template: require('./templates/shelves_section'),

  regions: {
    shelvesList: '#shelvesList'
  },

  behaviors: {
    BackupForm: {}
  },

  events: {
    'click #hideShelves': 'hideShelves',
    'click #showShelves': 'showShelves',
    'click #shelvesHeader': 'toggleShelves'
  },

  initialize() {
    return this._shelvesShown = true;
  },

  serializeData() {
    const inventoryUsername = this.options.username;
    const currentUserName = app.user.get('username');
    if (inventoryUsername === currentUserName) {
      return {editable: true};
    }
  },

  ui: {
    shelvesList: '#shelvesList',
    hideShelves: '#hideShelves',
    showShelves: '#showShelves',
    toggleButtons: '#toggleButtons'
  },

  onShow() {
    const { username } = this.options;

    this.waitForList = getUserId(username)
      .then(getShelvesByOwner)
      .then(this.ifViewIsIntact('showFromModel'))
      .catch(app.Execute('show:error'));

    return this.ui.showShelves.hide();
  },

  hideShelves(e){
    this.ui.shelvesList.addClass('wrapped');
    this.ui.showShelves.show();
    this.ui.hideShelves.hide();
    e.stopPropagation();
    return this._shelvesShown = false;
  },

  showShelves(e){
    this.ui.shelvesList.removeClass('wrapped');
    this.ui.hideShelves.show();
    this.ui.showShelves.hide();
    e.stopPropagation();
    return this._shelvesShown = true;
  },

  toggleShelves(e){
    if (this._shelvesShown) { return this.hideShelves(e);
    } else { return this.showShelves(e); }
  },

  showFromModel(docs){
    if (docs && (docs.length < 1)) { return; }
    this.collection = new Shelves(docs);
    this.shelvesList.show(new ShelvesList({ collection: this.collection }));
    if (this.collection.length > 5) { return this.ui.toggleButtons.removeClass('hidden'); }
  }
});

var getUserId = function(username){
  if (!username) { return Promise.resolve(app.user.id); }
  return app.request('get:userId:from:username', username);
};
