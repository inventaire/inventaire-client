import app from '#app/app'
import { parseQuery } from '#app/lib/location'
import { setPrerenderStatusCode } from '#app/lib/metadata/update'
import { parseBooleanString } from '#app/lib/utils'
import SearchResultsHistory from './collections/search_results_history.ts'
import findUri from './lib/find_uri.ts'
import type { SearchSection } from './lib/search_sections.ts'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'search(/)': 'searchFromQueryString',
      },
    })

    new Router({ controller })

    app.searchResultsHistory = new SearchResultsHistory()

    app.commands.setHandlers({
      'search:global': controller.search,
      'show:users:search' () { return controller.search('', 'user') },
      'show:groups:search' () { return controller.search('', 'group') },
    })

    app.reqres.setHandlers({
      'search:history:add' (data) { return app.searchResultsHistory.addNonExisting(data) },
    })
  },
}

const controller = {
  async search (search: string, section: SearchSection, showFallbackLayout?: () => void) {
  // Prevent indexation of search pages, by making them appear as duplicates of the home
    setPrerenderStatusCode(302, '')
    // Wait for the global search bar to have been initialized
    await app.request('wait:for', 'topbar')
    app.vent.trigger('live:search:query', { search, section, showFallbackLayout })
  },

  searchFromQueryString (querystring) {
    let section
    let { q, type, refresh } = parseQuery(querystring)
    refresh = parseBooleanString(refresh)
    if (q == null || typeof q !== 'string') q = ''
    let searchString = q
      .toString()
      // Replacing "+" added that the browser search might have added
      .replace(/\+/g, ' ')

    if (showEntityPageIfUri(searchString, refresh)) return

    if (type != null) {
      section = type
    } else {
      ;[ searchString, section ] = findSearchSection(searchString)
    }

    // Show the add layout at its search tab in the background, so that clicking
    // out of the live search doesn't result in a blank page
    const showFallbackLayout = app.Execute('show:add:layout:search') as (() => void)
    return controller.search(searchString, section, showFallbackLayout)
  },
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

const sectionSearchPattern = /^!([a-z]+)\s+/

function findSearchSection (searchString: string) {
  const sectionMatch = searchString.match(sectionSearchPattern)?.[1]
  if (sectionMatch == null) return [ searchString, 'all' ]

  searchString = searchString.replace(sectionSearchPattern, '').trim()

  const section: string | undefined = sections[sectionMatch] || 'all'
  console.log('section', section)
  return [ searchString, section ]
}

const sections = {
  a: 'author',
  b: 'work', // 'b' for book
  c: 'collection',
  g: 'group',
  h: 'author', // 'h' for human
  l: 'work', // 'l' for livre, libro, liber
  p: 'publisher',
  s: 'serie',
  t: 'subject', // 't' for topic (as series already use the 's')
  u: 'user',
  w: 'work',
  shelf: 'shelf',
  list: 'list',
}
