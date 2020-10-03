import log_ from 'lib/loggers'
// add name => creates group
// invite friends
// invite by email

import GroupViewsCommons from './group_views_commons'

import forms_ from 'modules/general/lib/forms'
import groups_ from '../lib/groups'
import groupFormData from '../lib/group_form_data'
import GroupUrl from '../lib/group_url'

const {
  GroupLayoutView
} = GroupViewsCommons

const {
  ui: groupUrlUi,
  events: groupUrlEvents,
  LazyUpdateUrl
} = GroupUrl

export default GroupLayoutView.extend({
  id: 'createGroupLayout',
  template: require('./templates/create_group_layout.hbs'),
  tagName: 'form',
  behaviors: {
    AlertBox: {},
    ElasticTextarea: {},
    Toggler: {}
  },

  regions: {
    invite: '#invite'
  },

  ui: _.extend({}, groupUrlUi, {
    nameField: '#nameField',
    description: '#description',
    searchabilityToggler: '#searchabilityToggler',
    searchabilityWarning: '.searchability .warning'
  }),

  initialize () {
    this._lazyUpdateUrl = LazyUpdateUrl(this)
  },

  onShow () { app.execute('modal:open', 'medium') },

  // Allows to define @_lazyUpdateUrl after events binding
  lazyUpdateUrl () { return this._lazyUpdateUrl() },

  events: _.extend({}, groupUrlEvents, {
    'click #createGroup': 'createGroup',
    'change #searchabilityToggler': 'toggleSearchabilityWarning'
  }
  ),
  // Can't be used as the create_group_layout is already in a modal itself
  // 'click #showPositionPicker': 'showPositionPicker'

  // showPositionPicker: ->
  //   app.request 'prompt:group:position:picker'
  //   .then (position)=> @position = position
  //   .catch log_.Error('showPositionPicker')

  serializeData () {
    return {
      description: groupFormData.description(),
      searchability: groupFormData.searchability()
    }
  },

  toggleSearchabilityWarning () {
    this.ui.searchabilityWarning.slideToggle()
  },

  createGroup (e) {
    const name = this.ui.nameField.val()
    const description = this.ui.description.val()

    const data = {
      name,
      description,
      searchable: this.ui.searchabilityToggler[0].checked
    }
    // position: @position

    log_.info(data, 'group data')

    return Promise.try(groups_.validateName.bind(this, name, '#nameField'))
    .then(groups_.validateDescription.bind(this, description, '#description'))
    .then(groups_.createGroup.bind(null, data))
    .then(model => {
      app.execute('show:group:board', model)
      app.execute('modal:close')
    })
    .catch(forms_.catchAlert.bind(null, this))
  }
})
