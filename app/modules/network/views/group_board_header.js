import { GroupItemView } from './group_views_commons';

export default GroupItemView.extend({
  template: require('./templates/group_board_header'),
  className: 'group-board-header',

  modelEvents: {
    'change': 'lazyRender'
  },

  behaviors: {
    PreventDefault: {}
  },

  serializeData() {
    const attrs = this.model.serializeData();
    attrs.invitor = this.invitorData();
    return attrs;
  },

  invitorData() {
    const username = this.model.findMainUserInvitor()?.get('username');
    return { username };
  }});
