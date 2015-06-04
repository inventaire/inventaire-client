module.exports = ->
  nameBase: 'search'
  field:
    type: 'search'
    placeholder: _.i18n 'add or search a book'
  button:
    icon: 'search'
    classes: 'secondary'