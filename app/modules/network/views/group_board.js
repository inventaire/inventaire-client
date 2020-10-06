import GroupViewsCommons from './group_views_commons'
import GroupBoardHeader from './group_board_header'
import GroupSettings from './group_settings'
import UsersSearchLayout from '../views/users_search_layout'
import UsersList from 'modules/users/views/users_list'
import InviteByEmail from './invite_by_email'
import screen_ from 'lib/screen'

const {
  GroupLayoutView
} = GroupViewsCommons

export default GroupLayoutView.extend({
  template: require('./templates/group_board.hbs'),
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
    PreventDefault: {}
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

  events: _.extend({}, GroupLayoutView.prototype.events,
    { 'click .section-toggler': 'toggleSection' }),

  onShow () {
    if (this.openedSection != null) this.toggleUi(this.openedSection)
  },

  showHeader () {
    return this.header.show(new GroupBoardHeader({ model: this.model }))
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

  onRender () {
    return this.model.beforeShow()
    .then(this.ifViewIsIntact('_showBoard'))
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
    return this.groupSettings.show(new GroupSettings({ model: this.model }))
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
    return this.groupRequests.show(new UsersList({
      collection: this.model.requested,
      groupContext: true,
      group: this.model,
      emptyViewMessage: 'no more pending requests'
    })
    )
  },

  showMembers () {
    return this.groupMembers.show(new UsersList({
      collection: this.model.members,
      groupContext: true,
      group: this.model
    })
    )
  },

  showMembersInvitor () {
    const group = this.model
    // TODO: replace UsersSearchLayout by a user list fed with search results
    // that aren't added to the deprecated global users collections
    return this.groupInvite.show(new UsersSearchLayout({
      stretch: false,
      updateRoute: false,
      groupContext: true,
      group,
      emptyViewMessage: 'no user found',
      filter (user, index, collection) {
        return group.userStatus(user) !== 'member'
      }
    })
    )
  },

  onLeave () { app.execute('show:inventory:group', this.model, true) },

  showMembersEmailInvitor () {
    return this.groupEmailInvite.show(new InviteByEmail({ group: this.model }))
  },

  updateRoute () {
    app.navigateFromModel(this.model, 'boardPathname', { preventScrollTop: true })
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
