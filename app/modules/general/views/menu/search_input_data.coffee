module.exports = (nameBase='search', postfix)->
  extraClasses = if postfix then 'postfix' else ''
  return data =
    nameBase: nameBase
    field:
      type: 'search'
      name: 'search'
      placeholder: _.i18n 'search a book by title, author or ISBN'
    button:
      icon: 'search'
      classes: "secondary #{extraClasses}"
