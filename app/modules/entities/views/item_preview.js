export default Marionette.ItemView.extend({
  template: require('./templates/item_preview'),
  className() {
    let className = 'item-preview';
    if (this.options.compact) { className += ' compact'; }
    return className;
  },

  behaviors: {
    PreventDefault: {}
  },

  onShow() {
    if (this.model.user == null) { return this.model.waitForUser.then(this.lazyRender.bind(this)); }
  },

  serializeData() {
    const transaction = this.model.get('transaction');
    const attrs = this.model.serializeData();
    return _.extend(attrs, {
      title: buildTitle(this.model.user, transaction),
      distanceFromMainUser: this.model.user.distanceFromMainUser,
      compact: this.options.compact,
      displayCover: this.options.displayItemsCovers && (attrs.picture != null)
    }
    );
  },

  events: {
    'click .showItem': 'showItem'
  },

  showItem(e){
    if (_.isOpenedOutside(e)) { return; }
    return app.execute('show:item', this.model);
  }
});

var buildTitle = function(user, transaction){
  if (user == null) { return; }
  const username = user.get('username');
  let title = _.i18n(`${transaction}_personalized`, { username });
  if (user.distanceFromMainUser != null) {
    title += ` (${_.i18n('km_away', { distance: user.distanceFromMainUser })})`;
  }
  return title;
};
