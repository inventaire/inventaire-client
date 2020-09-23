// TRANSACTION STATES (actor)
// - requested (requester)
// - accepted / declined (owner)
// - performed (requester)
// - returned (owner) (for lending only)
// - cancelled (owner/requester)
import { getNextActionsData, isArchived } from '../lib/next_actions';

import cancellableStates from '../lib/cancellable_states';
import applySideEffects from '../lib/apply_side_effects';
import { buildPath } from 'lib/location';
import Action from '../models/action';
import Message from '../models/message';
import Timeline from '../collections/timeline';
import formatSnapshotData from '../lib/format_snapshot_data';
import { data as transactionsData } from 'modules/inventory/lib/transactions_data';

export default Backbone.NestedModel.extend({
  url() { return app.API.transactions; },
  initialize() {
    this.set('pathname', `/transactions/${this.id}`);

    this.setMainUserIsOwner();
    this.setArchivedStatus();
    // re-set mainUserIsOwner once app.user.id is accessible
    this.listenToOnce(app.user, 'change', this.setMainUserIsOwner.bind(this));

    return this.set('icon', this.getIcon());
  },

  beforeShow() {
    // All the actions to run once before showing any view displaying
    // deep transactions data, but that can be spared otherwise
    if (this._beforeShowCalledOnce) { return; }
    this._beforeShowCalledOnce = true;

    this.waitForData = this.grabLinkedModels();
    this.buildTimeline();
    this.fetchMessages();
    // provide views with a flag on actions data state
    this.set('actionsReady', false);

    this.once('grab:owner', this.setNextActions.bind(this));
    this.once('grab:requester', this.setNextActions.bind(this));

    this.on('change:state', this.setNextActions.bind(this));
    this.on('change:state', this.setArchivedStatus.bind(this));
    this.on('change:read', this.deduceReadStatus.bind(this));

    // snapshot data are to be used in views only when the snapshot
    // is more meaningful than the current version
    // ex: the item transaction mode at the time of the transaction request
    return formatSnapshotData.call(this);
  },

  setMainUserIsOwner() {
    this.mainUserIsOwner = this.get('owner') === app.user.id;
    this.role = this.mainUserIsOwner ? 'owner' : 'requester';
    return this.deduceReadStatus();
  },

  deduceReadStatus() {
    this.mainUserRead = this.get('read')[this.role];

    const prev = this.unreadUpdate;
    this.unreadUpdate = this.mainUserRead ? 0 : 1;
    if (this.unreadUpdate !== prev) { return app.vent.trigger('transactions:unread:change'); }
  },

  grabLinkedModels() {
    this.reqGrab('get:user:model', this.get('requester'), 'requester');

    // wait for the owner to be ready to fetch the item
    // to avoid errors at item initialization
    // during sync functions depending on the owner data
    return this.reqGrab('get:user:model', this.get('owner'), 'owner')
    .then(() => this.reqGrab('get:item:model', this.get('item'), 'item'));
  },

  markAsRead() {
    if (!this.mainUserRead) {
      this.set(`read.${this.role}`, true);
      return _.preq.put(app.API.transactions, {
        id: this.id,
        action: 'mark-as-read'
      }).catch(_.Error('markAsRead'));
    }
  },

  buildTimeline() {
    if (this.timeline != null) { return; }
    this.timeline = new Timeline;
    return this.get('actions').map((action) =>
      this.addActionToTimeline(action));
  },

  addActionToTimeline(action){
    action = new Action(action);
    action.transaction = this;
    return this.timeline.add(action);
  },

  fetchMessages() {
    const url = buildPath(app.API.transactions, {
      action: 'get-messages',
      transaction: this.id
    }
    );

    return _.preq.get(url)
    .get('messages')
    .then(this.addMessagesToTimeline.bind(this));
  },

  addMessagesToTimeline(messages){
    return messages.map((message) =>
      this.timeline.add(new Message(message)));
  },

  setNextActions() {
    // /!\ if the other user stops being accessible (ex: deleted user)
    // next actions will never be ready
    if ((this.owner != null) && (this.requester != null)) {
      return this.set({
        nextActions: getNextActionsData(this),
        actionsReady: true
      });
    }
  },

  serializeData() {
    const attrs = this.toJSON();
    attrs[attrs.state] = true;
    _.extend(attrs, {
      item: this.itemData(),
      entity: this.get('snapshot.entity'),
      owner: this.ownerData(),
      requester: this.requesterData(),
      messages: this.messages,
      mainUserIsOwner: this.mainUserIsOwner,
      context: this.context(),
      mainUserRead: this.mainUserRead,
      cancellable: this.isCancellable()
    }
    );

    [ attrs.user, attrs.other ] = Array.from(this.aliasUsers(attrs));

    // Legacy: the title and image were previously snapshot on snapshot.item
    if (!attrs.entity) { attrs.entity = {}; }
    if (!attrs.entity.title) { attrs.entity.title = attrs.item.title; }
    if (!attrs.entity.image) { attrs.entity.image = attrs.item.pictures?.[0]; }

    return attrs;
  },

  itemData() { return this.item?.serializeData() || this.get('snapshot.item'); },
  ownerData() { return this.owner?.serializeData() || this.get('snapshot.owner'); },
  requesterData() { return this.requester?.serializeData() || this.get('snapshot.requester'); },

  aliasUsers(attrs){
    if (this.mainUserIsOwner) { return [ attrs.owner, attrs.requester ];
    } else { return [ attrs.requester, attrs.owner ]; }
  },

  otherUser() { if (this.mainUserIsOwner) { return this.requester; } else { return this.owner; } },

  getIcon() {
    const transaction = this.get('transaction');
    return transactionsData[transaction].icon;
  },

  context() {
    if (this.owner != null) {
      const transaction = this.get('transaction');
      if (this.mainUserIsOwner) { return _.i18n(`main_user_${transaction}`);
      } else {
        const [ username, pathname ] = Array.from(this.owner.gets('username', 'pathname'));
        const link = `<a href='${pathname}'>${username}</a>`;
        return _.i18n(`other_user_${transaction}`, { username: link });
      }
    }
  },

  accepted() { return this.updateState('accepted'); },
  declined() { return this.updateState('declined'); },
  confirmed() { return this.updateState('confirmed'); },
  returned() { return this.updateState('returned'); },
  cancelled() { return this.updateState('cancelled'); },

  updateState(state){
    this.backup();
    // redondant info:
    // might need to be refactored to deduce state from last action
    this.set({ state });
    const action = { action: state, timestamp: Date.now() };
    // keep track of the actor when it can be both
    if (actorCanBeBoth.includes(state)) { action.actor = this.role; }
    this.push('actions', action);
    const actionModel = this.addActionToTimeline(action);
    const userStatus = this.otherUser().get('status');

    return _.preq.put(app.API.transactions, {
      transaction: this.id,
      state,
      action: 'update-state'
    }).then(() => applySideEffects(this, state))
    .catch(this._updateFail.bind(this, actionModel));
  },

  _updateFail(actionModel, err){
    this.restore();
    this.timeline.remove(actionModel);
    // let the view handle the error
    throw err;
  },

  // quick and dirty backup/restore mechanism
  // fails to delete new attributes
  backup() { return this._backup = this.toJSON(); },
  restore() { return this.set(this._backup); },

  setArchivedStatus() {
    const previousStatus = this.archived;
    this.archived = this.isArchived();
    if (this.archived !== previousStatus) {
      return app.vent.trigger('transactions:folder:change');
    }
  },

  isArchived() { return isArchived(this); },
  isCancellable() {
    const [ state, transaction ] = Array.from(this.gets('state', 'transaction'));
    return cancellableStates[transaction][this.role].includes(state);
  },

  updateMetadata() {
    return this.waitForData
    .then(() => {
      return {
        title: this.getTitle(),
        image: this.itemData().picture,
        url: this.get('pathname')
      };
    });
  },

  getTitle() {
    const username = this.otherUser().get('username');
    const base = _.i18n('transaction_with', { username });
    const { title } = this.itemData();
    return `[${base}] ${title}`;
  }
});

var actorCanBeBoth = [ 'cancelled' ];
