import SearchResultsHistory from './collections/search_results_history'
import findUri from './lib/find_uri'
import { parseQuery } from 'lib/location'
import { setPrerenderStatusCode } from 'lib/metadata/update'

export default {
  define (module, app, Backbone, Marionette, $, _) {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'search(/)': 'searchFromQueryString'
      }
    })

    app.addInitializer(() => new Router({ controller: API }))
  },

  initialize () {
    app.searchResultsHistory = new SearchResultsHistory()

    app.commands.setHandlers({
      'search:global': API.search,
      'show:users:search' () { return API.search('', 'user') },
      'show:groups:search' () { return API.search('', 'group') }
    })

    app.reqres.setHandlers({
      'search:entities': API.searchEntities,
      'search:history:add' (data) { return app.searchResultsHistory.addNonExisting(data) }
    })
  }
}

const API = {}
API.search = function (search, section, showFallbackLayout) {
  // Prevent indexation of search pages, by making them appear as duplicates of the home
  setPrerenderStatusCode(302, '')
  return app.vent.trigger('live:search:query', { search, section, showFallbackLayout })
}

API.searchFromQueryString = function (querystring) {
  let section
  let { q, type, refresh } = parseQuery(querystring)
  refresh = _.parseBooleanString(refresh)
  if (q == null) { q = '' }
  // Replacing "+" added that the browser search might have added
  q = q.replace(/\+/g, ' ')

  if (showEntityPageIfUri(q, refresh)) return

  if (type != null) {
    section = type
  } else { [ q, section ] = Array.from(findSearchSection(q)) }

  // Show the add layout at its search tab in the background, so that clicking
  // out of the live search doesn't result in a blank page
  const showFallbackLayout = app.Execute('show:add:layout:search')

  return API.search(q, section, showFallbackLayout)
}

const showEntityPageIfUri = function (query, refresh) {
  // If the query text is a URI, show the associated entity page
  // as it doesn't make sense to search for an entity we have already found
  const uri = findUri(query)
  if (uri != null) {
    app.execute('show:entity', uri, { refresh })
    return true
  } else {
    return false
  }
}

const sectionSearchPattern = /^!([a-z])\s+/

const findSearchSection = function (q) {
  const sectionMatch = q.match(sectionSearchPattern)?.[1]
  if (sectionMatch == null) { return [ q, 'all' ] }

  q = q.replace(sectionSearchPattern, '').trim()

  const firstLetter = sectionMatch[0]
  const section = sections[firstLetter] || 'all'
  console.log('section', section)
  return [ q, section ]
}

const sections = {
  a: 'author',
  b: 'book',
  c: 'collection',
  g: 'group',
  h: 'author', // 'h' for human
  l: 'book', // 'l' for livre, libro, liber
  p: 'publisher',
  s: 'serie',
  t: 'subject', // 't' for topic (as series already use the 's')
  u: 'user',
  w: 'book' // 'w' for work
}
