export default Marionette.ItemView.extend({
  tagName: 'li',
  className: 'item-row',
  template: require('./templates/item_row'),

  initialize() {
    ({ getSelectedIds: this.getSelectedIds, isMainUser: this.isMainUser, groupContext: this.groupContext } = this.options);
    this.listenTo(this.model, 'change', this.lazyRender.bind(this));

    if (!this.model.userReady) {
      return this.model.waitForUser.then(this.lazyRender.bind(this));
    }
  },

  serializeData() {
    return _.extend(this.model.serializeData(), {
      checked: this.getCheckedStatus(),
      isMainUser: this.isMainUser,
      groupContext: this.groupContext
    }
    );
  },

  events: {
    'click .showItem': 'showItem'
  },

  showItem(e){
    if (_.isOpenedOutside(e)) { return;
    } else { return app.execute('show:item', this.model); }
  },

  getCheckedStatus() {
    if (this.getSelectedIds != null) { let needle;
    return (needle = this.model.id, this.getSelectedIds().includes(needle));
    } else { return false; }
  }
});
