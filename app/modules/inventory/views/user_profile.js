import forms_ from 'modules/general/lib/forms';
import relationsActions from 'modules/users/plugins/relations_actions';
import { buildPath } from 'lib/location';
import NewShelfEditor from 'modules/shelves/views/new_shelf_editor';

// TODO: add a 'close' button to allow to unfocus a user in group context
export default Marionette.ItemView.extend({
  className: 'userProfile',
  template: require('./templates/user_profile'),
  events: {
    'click .editProfile': _.clickCommand('show:settings:profile'),
    'click .addItems': _.clickCommand('show:add:layout'),
    'click .showUserOnMap': 'showUserOnMap',
    'click #createShelf': 'showNewShelfEditor'
  },

  behaviors: {
    PreventDefault: {}
  },

  initialize() {
    ({ isMainUser: this.isMainUser } = this.model);
    this.listenTo(this.model, 'change', this.render.bind(this));
    return this.initPlugin();
  },

  initPlugin() {
    if (!this.isMainUser) { return relationsActions.call(this); }
  },

  serializeData() {
    // Show private items in items counts if available
    const nonPrivate = false;
    return _.extend(this.model.serializeData(nonPrivate), {
      onUserProfile: true,
      loggedIn: app.user.loggedIn,
      positionUrl: this.getPositionUrl(),
      distance: this.model.distanceFromMainUser
    }
    );
  },

  getPositionUrl() {
    if (this.model.distanceFromMainUser == null) { return; }
    const [ lat, lng ] = Array.from(this.model.get('position'));
    return buildPath('/network/users/nearby', { lat, lng });
  },

  showUserOnMap(e){
    if (_.isOpenedOutside(e)) { return; }
    if (this.model.distanceFromMainUser == null) { return; }
    return app.execute('show:models:on:map', [ this.model, app.user ]);
  },

  showNewShelfEditor(e){
    app.layout.modal.show(new NewShelfEditor({}));
    return e.stopPropagation();
  }
});
