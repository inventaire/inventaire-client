# Requirements:
# - the view using this behavior should have the PreventDefault behavior
# - the template is expected to use the {{{joinAuthors}}} handlebars helpers,
#   passing it an array of plain text authors' names

module.exports = Marionette.Behavior.extend
  events:
    'click .searchAuthor': 'searchAuthor'

  searchAuthor: (e)->
    author = e.target.firstChild.textContent
    unless _.isOpenedOutside(e)
      app.execute 'search:global', author
