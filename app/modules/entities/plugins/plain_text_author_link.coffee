# Requirements:
# - the view using this plugin should have the PreventDefault behavior
# - the template is expected to use the {{{joinAuthors}}} handlebars helpers,
#   passing it an array of plain text authors' names

searchAuthor = (e)->
  author = e.target.firstChild.textContent
  unless _.isOpenedOutside(e)
    app.execute 'search:global', author

events =
  'click .searchAuthor': 'searchAuthor'

handlers =
  searchAuthor: searchAuthor

domainsWithPlainTextAuthors = ['isbn' , 'inv']

module.exports = ->
  if @model.get('domain') in domainsWithPlainTextAuthors
    _.extend @events, events
    _.extend @, handlers
    return
