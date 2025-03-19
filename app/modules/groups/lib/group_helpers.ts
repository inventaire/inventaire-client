import FilteredCollection from 'backbone-filtered-collection'
import { API } from '#app/api/api'
import app from '#app/app'
import { isModel, isGroupId } from '#app/lib/boolean_tests'
import { newError } from '#app/lib/error'
import { Updater } from '#app/lib/model_update'
import preq from '#app/lib/preq'
import type { Group, GroupId, GroupSlug } from '#server/types/group'
import { getGroupById, getGroupBySlug } from './groups'

export default function () {
  const { groups } = app

  function getGroupModelById (id) {
    const group = groups.byId(id)
    if (group == null) return getGroupPublicData(id)

    // the group model might have arrived from a simple search
    // thus without fetching its users
    if (group.usersFetched) {
      return Promise.resolve(group)
    } else {
      return getGroupPublicData(null, group)
    }
  }

  function getGroupPublicData (id, groupModel?) {
    if (groupModel != null) ({ id } = groupModel)
    return preq.get(API.groups.byId(id))
    .then(res => addGroupData(res, groupModel))
  }

  function getGroupModelFromSlug (slug) {
    return preq.get(API.groups.bySlug(slug))
    .then(addGroupData)
  }

  function addGroupData (res, groupModel?) {
    const { group, users } = res
    app.execute('users:add', users)
    if (groupModel == null) groupModel = groups.add(group)
    groupModel.usersFetched = true
    return groupModel
  }

  const groupSettingsUpdater = Updater({
    endpoint: API.groups.base,
    action: 'update-settings',
    modelIdLabel: 'group',
  })

  function getGroupModel (id) {
    if (isGroupId(id)) {
      return getGroupModelById(id)
    } else {
      return getGroupModelFromSlug(id)
    }
  }

  const resolveToGroupModel = async function (group) {
  }

  async function resolveToGroup (group: Group | GroupId | GroupSlug) {
    if (typeof group === 'string') {
      if (isGroupId(group)) {
        return getGroupById(group)
      } else {
        return getGroupBySlug(group)
      }
    } else {
      return group
    }
  }

  app.reqres.setHandlers({
    'resolve:to:group': resolveToGroup,
  })

  initGroupFilteredCollection(groups, 'mainUserMember')
  initGroupFilteredCollection(groups, 'mainUserInvited')
}

function initGroupFilteredCollection (groups, name) {
  const filtered = (groups[name] = new FilteredCollection(groups))
  filtered.filterBy(name, filters[name])
  return filtered.listenTo(app.vent, 'group:main:user:move', filtered.refilter.bind(filtered))
}

const filters = {
  mainUserMember: group => group.mainUserIsMember(),
  mainUserInvited: group => group.mainUserIsInvited(),
}
