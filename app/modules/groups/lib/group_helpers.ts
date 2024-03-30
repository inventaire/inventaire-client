import FilteredCollection from 'backbone-filtered-collection'
import app from '#app/app'
import { isModel, isGroupId } from '#lib/boolean_tests'
import error_ from '#lib/error'
import { Updater } from '#lib/model_update'
import preq from '#lib/preq'

export default function () {
  const { groups } = app

  const getGroupModelById = function (id) {
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

  const getGroupPublicData = function (id, groupModel?) {
    if (groupModel != null) ({ id } = groupModel)
    return preq.get(app.API.groups.byId(id))
    .then(res => addGroupData(res, groupModel))
  }

  const getGroupModelFromSlug = slug => {
    return preq.get(app.API.groups.bySlug(slug))
    .then(addGroupData)
  }

  const addGroupData = function (res, groupModel?) {
    const { group, users } = res
    app.execute('users:add', users)
    if (groupModel == null) groupModel = groups.add(group)
    groupModel.usersFetched = true
    return groupModel
  }

  const groupSettingsUpdater = Updater({
    endpoint: app.API.groups.base,
    action: 'update-settings',
    modelIdLabel: 'group',
  })

  const getGroupModel = function (id) {
    if (isGroupId(id)) {
      return getGroupModelById(id)
    } else {
      return getGroupModelFromSlug(id)
    }
  }

  const resolveToGroupModel = async function (group) {
    // 'group' is either the group model, a group id, or a group slug
    if (isModel(group)) return group
    const groupModel = await getGroupModel(group)
    if (groupModel != null) {
      return groupModel
    } else {
      throw error_.new('group model not found', 404, { group })
    }
  }

  const resolveToGroup = async function (group) {
    const groupModel = await resolveToGroupModel(group)
    return groupModel.toJSON()
  }

  app.reqres.setHandlers({
    'get:group:model': getGroupModel,
    'group:update:settings': groupSettingsUpdater,
    'resolve:to:groupModel': resolveToGroupModel,
    'resolve:to:group': resolveToGroup,
  })

  initGroupFilteredCollection(groups, 'mainUserMember')
  initGroupFilteredCollection(groups, 'mainUserInvited')
}

const initGroupFilteredCollection = function (groups, name) {
  const filtered = (groups[name] = new FilteredCollection(groups))
  filtered.filterBy(name, filters[name])
  return filtered.listenTo(app.vent, 'group:main:user:move', filtered.refilter.bind(filtered))
}

const filters = {
  mainUserMember: group => group.mainUserIsMember(),
  mainUserInvited: group => group.mainUserIsInvited(),
}
