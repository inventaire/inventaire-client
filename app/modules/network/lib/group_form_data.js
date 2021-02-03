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

  openness (active = false) {
    return {
      id: 'opennessToggler',
      checked: active,
      label: 'open membership'
    }
  }
}
