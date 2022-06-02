export const commonVisibilityKeys = [
  'public',
  'friends',
  'groups',
]

export const getGroupVisibilityKey = group => `group:${group._id}`

export const isNotGroupVisibilityKey = key => !key.startsWith('group:')
