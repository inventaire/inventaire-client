import { GroupLayoutView } from './group_views_commons.js'
import GroupBoardHeader from './group_board_header.js'
import GroupSettings from './group_settings.js'
import UsersSearchLayout from '../views/users_search_layout.js'
import UsersList from '#users/views/users_list'
import InviteByEmail from './invite_by_email.js'
import screen_ from '#lib/screen'
import groupBoardTemplate from './templates/group_board.hbs'
import '../scss/group_board.scss'
import PreventDefault from '#behaviors/prevent_default'
import SuccessCheck from '#behaviors/success_check'

export default GroupLayoutView.extend({
  template: groupBoardTemplate,
  className () {
    const standalone = this.options.standalone ? 'standalone' : ''
    return `groupBoard ${standalone}`
  },

  initialize () {
    ({ standalone: this.standalone, openedSection: this.openedSection } = this.options)

    // Join requests will be showned instead
    if ((this.openedSection === 'groupSettings') && this.model.mainUserIsAdmin() && (this.model.get('requested').length > 0)) {
      this.openedSection = null
    }

    this._alreadyShownSection = {}
    this.listenTo(this.model, 'action:accept', this.render.bind(this))
    this.listenTo(this.model, 'action:leave', this.onLeave.bind(this))
  },

  behaviors: {
    PreventDefault,
    SuccessCheck,
  },

  regions: {
    header: '.header',
    groupSettings: '#groupSettings > .inner',
    groupRequests: '#groupRequests > .inner',
    groupMembers: '#groupMembers > .inner',
    groupInvite: '#groupInvite > .inner',
    groupEmailInvite: '#groupEmailInvite > .inner'
  },

  ui: {
    groupSettings: '#groupSettings > .inner',
    groupRequests: '#groupRequests > .inner',
    groupMembers: '#groupMembers > .inner',
    groupInvite: '#groupInvite > .inner',
    groupEmailInvite: '#groupEmailInvite > .inner',
    groupRequestsSection: '#groupRequests'
  },

  serializeData () {
    const attrs = this.model.serializeData()
    attrs.sections = sectionsData
    return attrs
  },

  events: _.extend({}, GroupLayoutView.prototype.events, {
    'click .section-toggler': 'toggleSection'
  }),

  async onRender () {
    await this.model.beforeShow()
    if (this.isIntact()) this._showBoard()
    if (this.openedSection != null) this.toggleUi(this.openedSection)
  },

  showHeader () {
    this.showChildView('header', new GroupBoardHeader({ model: this.model }))
  },

  toggleSection (e) {
    const section = e.currentTarget.parentElement.attributes.id.value
    this.toggleUi(section)
  },

  // acting on ui objects and not a region.$el as a region
  // doesn't have a $el before being shown
  toggleUi (uiLabel, scroll = true) {
    if (!this._alreadyShownSection[uiLabel] && (this.onFirstToggle[uiLabel] != null)) {
      const fnName = this.onFirstToggle[uiLabel]
      this[fnName]()
      this._alreadyShownSection = true
    }

    this._toggleUi(uiLabel, scroll)
  },

  _toggleUi (uiLabel, scroll) {
    const $el = this.ui[uiLabel]
    const $parent = $el.parent()
    $el.slideToggle()
    $parent.find('.fa-caret-right').toggleClass('toggled')
    if (scroll && $el.visible()) screen_.scrollTop($parent, null, 20)
  },

  onFirstToggle: {
    groupSettings: 'showSettings',
    groupMembers: 'showMembers',
    groupRequests: 'showJoinRequests',
    groupInvite: 'showMembersInvitor',
    groupEmailInvite: 'showMembersEmailInvitor'
  },

  _showBoard () {
    this.showHeader()
    this.prepareJoinRequests()
    if (this.model.mainUserIsMember()) this.initSettings()
  },

  initSettings () {
    if (this.standalone && this.model.mainUserIsAdmin()) {
      this.listenTo(this.model, 'change:slug', this.updateRoute.bind(this))
    }
  },

  showSettings () {
    this.showChildView('groupSettings', new GroupSettings({ model: this.model }))
  },

  prepareJoinRequests () {
    if ((this.model.requested.length > 0) && this.model.mainUserIsAdmin()) {
      this.ui.groupRequestsSection.show()
      return this.toggleUi('groupRequests', false)
    } else {
      this.ui.groupRequestsSection.hide()
    }
  },

  showJoinRequests () {
    this.showChildView('groupRequests', new UsersList({
      collection: this.model.requested,
      groupContext: true,
      group: this.model,
      emptyViewMessage: 'no more pending requests'
    }))
  },

  showMembers () {
    this.showChildView('groupMembers', new UsersList({
      collection: this.model.members,
      groupContext: true,
      group: this.model
    }))
  },

  showMembersInvitor () {
    const group = this.model
    // TODO: replace UsersSearchLayout by a user list fed with search results
    // that aren't added to the deprecated global users collections
    this.showChildView('groupInvite', new UsersSearchLayout({
      stretch: false,
      updateRoute: false,
      groupContext: true,
      group,
      emptyViewMessage: 'no user found',
      viewFilter (view) {
        const user = view.model
        return group.userStatus(user) !== 'member'
      }
    }))
  },

  onLeave () { app.execute('show:inventory:group', this.model, true) },

  showMembersEmailInvitor () {
    this.showChildView('groupEmailInvite', new InviteByEmail({ group: this.model }))
  },

  updateRoute () {
    app.navigateFromModel(this.model, 'settingsPathname', { preventScrollTop: true })
  }
})

const sectionsData = {
  settings: {
    label: 'group settings',
    icon: 'cog'
  },
  requests: {
    label: 'requests waiting your approval',
    icon: 'inbox'
  },
  members: {
    label: 'members',
    icon: 'users'
  },
  invite: {
    label: 'invite new members',
    icon: 'plus'
  },
  email: {
    label: 'invite by email',
    icon: 'envelope'
  }
}
