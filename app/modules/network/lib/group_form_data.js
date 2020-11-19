export default {
  description (description) {
    return {
      id: 'description',
      placeholder: 'help other users to understand what this group is about',
      value: description
    }
  },

  searchability (active = true) {
    return {
      id: 'searchabilityToggler',
      checked: active,
      label: 'appear in search results'
    }
  },

  openess (active = true) {
    return {
      id: 'openessToggler',
      checked: active,
      label: 'open membership'
    }
  }
}
