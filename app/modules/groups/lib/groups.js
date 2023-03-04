import log_ from '#lib/loggers'
import preq from '#lib/preq'
import forms_ from '#general/lib/forms'
import error_ from '#lib/error'
import { pluck } from 'underscore'
import { getColorSquareDataUriFromModelId } from '#lib/images'

export default {
  createGroup (data) {
    const { name, description, searchable, open, position } = data
    const { groups } = app

    return preq.post(app.API.groups.base, {
      action: 'create',
      name,
      description,
      searchable,
      open,
      position
    })
    .then(groups.add.bind(groups))
    .then(log_.Info('group'))
    .catch(error_.Complete('#createGroup'))
  },

  validateName (name, selector) {
    forms_.pass({
      value: name,
      tests: groupNameTests,
      selector
    })
  },

  validateDescription (description, selector) {
    forms_.pass({
      value: description,
      tests: groupDescriptionTests,
      selector
    })
  }
}

const groupNameTests = {
  'The group name can not be longer than 80 characters' (name) {
    return name.length > 80
  }
}

const groupDescriptionTests = {
  'The group description can not be longer than 5000 characters' (description) {
    return description.length > 5000
  }
}

export function getAllGroupMembersIds (group) {
  const { admins, members } = group
  return pluck([ ...admins, ...members ], 'user')
}

export function getGroupMembersCount (group) {
  return group.admins.length + group.members.length
}

export function getGroupPicture (group) {
  return group.picture || getColorSquareDataUriFromModelId(group._id)
}

export function getGroupPathname (group) {
  return `/groups/${group.slug}`
}
