export const commonVisibilityKeys = [
  'public',
  'friends',
  'groups',
]

export const getGroupVisibilityKey = group => `group:${group._id}`

export const isGroupVisibilityKey = key => key.startsWith('group:')
export const isNotGroupVisibilityKey = key => !isGroupVisibilityKey(key)
