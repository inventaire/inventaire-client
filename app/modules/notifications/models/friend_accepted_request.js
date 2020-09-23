import Notification from './notification';

export default Notification.extend({
  initSpecific() { return this.grabAttributeModel('user'); },

  serializeData() {
    const attrs = this.toJSON();
    attrs.username = this.user?.get('username');
    attrs.picture = this.user?.get('picture');
    attrs.pathname = `/inventory/${attrs.username}`;
    return attrs;
  }
});
