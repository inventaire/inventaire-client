module.exports =
  description: (description)->
    id: 'description'
    placeholder: 'help other users to understand what this group is about'
    value: description

  searchability: (active = true)->
    id: 'searchabilityToggler'
    checked: active
    label: 'appear in search results'
