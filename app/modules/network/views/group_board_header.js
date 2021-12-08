import { GroupItemView } from './group_views_commons'
import groupBoardHeaderTemplate from './templates/group_board_header.hbs'
import '../scss/group_board_header.scss'
import PreventDefault from 'behaviors/prevent_default'
import SuccessCheck from 'behaviors/success_check'

export default GroupItemView.extend({
  template: groupBoardHeaderTemplate,
  className: 'group-board-header',

  modelEvents: {
    change: 'lazyRender'
  },

  behaviors: {
    PreventDefault,
    SuccessCheck,
  },

  serializeData () {
    const attrs = this.model.serializeData()
    attrs.invitor = this.invitorData()
    return attrs
  },

  invitorData () {
    const username = this.model.findMainUserInvitor()?.get('username')
    return { username }
  }
})
