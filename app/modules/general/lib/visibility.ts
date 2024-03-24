export const commonVisibilityKeys = [
  'public',
  'friends',
  'groups',
]

export const getGroupVisibilityKey = group => `group:${group._id}`

export const isGroupVisibilityKey = key => key.startsWith('group:')
export const isNotGroupVisibilityKey = key => !isGroupVisibilityKey(key)

export const getVisibilitySummary = visibility => {
  if (visibility.length === 0) return 'private'
  if (visibility.includes('public')) return 'public'
  return 'network'
}

export const iconByVisibilitySummary = {
  private: 'lock',
  network: 'users',
  public: 'globe',
}

export const getVisibilitySummaryLabel = visibility => {
  if (visibility.length === 0) return 'private'
  if (visibility.includes('public')) return 'public'

  const groupKeyCount = visibility.filter(isGroupVisibilityKey).length
  if (visibility.includes('friends') && visibility.includes('groups')) {
    return 'friends and groups'
  } else if (groupKeyCount > 0) {
    if (visibility.includes('friends')) return 'friends and some groups'
    else return 'some groups'
  } else if (visibility.includes('groups')) {
    return 'groups'
  } else {
    return 'friends'
  }
}

export const visibilitySummariesData = {
  private: {
    id: 'private',
    icon: 'lock',
    unicodeIcon: '&#xf023;',
    label: 'private'
  },

  network: {
    id: 'network',
    icon: 'users',
    unicodeIcon: '&#xf0c0;',
    label: 'friends and groups'
  },

  public: {
    id: 'public',
    icon: 'globe',
    unicodeIcon: '&#xf0ac;',
    label: 'public'
  }
}
