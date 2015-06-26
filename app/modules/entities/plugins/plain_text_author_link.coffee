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

# apply to allDomains when the entity model is not accessible
# at the view initialization:
# better having this extrat event on irrelevant entities that not having it
# on relevant ones
module.exports = (allDomains)->
  if @model.get('domain') in domainsWithPlainTextAuthors or allDomains
    _.basicPlugin.call @, events, handlers
