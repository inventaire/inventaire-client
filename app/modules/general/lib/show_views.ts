import app from '#app/app'
import { isOpenedOutside } from '#app/lib/utils'
import FullScreenLoader from '#components/full_screen_loader.svelte'

export default {
  showEntity (e) {
    entityAction(e, 'show:entity')
    if (!isOpenedOutside(e)) {
      // Required to close the ItemShowLayout modal if one was open
      app.execute('modal:close')
    }
  },

  showEntityEdit (e) { entityAction(e, 'show:entity:edit') },
  showEntityCleanup (e) { entityAction(e, 'show:entity:cleanup') },
  showEntityHistory (e) { entityAction(e, 'show:entity:history') },
}

const entityAction = function (e, action) {
  const { href } = e.currentTarget
  if (href == null) throw new Error(`couldnt ${action}: href not found`)

  // If the link was Ctrl+clicked or if it was an external link with target='_blank',
  // typically, a link to a Wikidata entity page
  if (!isOpenedOutside(e)) {
    // Any href arriving here should be of the form /entity/:uri(/:label)(/edit)
    const [ uri ] = href.split('/entity/')[1].split('/')
    app.execute(action, uri)
    e.stopPropagation()
  }
}

export function showLoader () {
  app.layout.showChildComponent('main', FullScreenLoader)
}
