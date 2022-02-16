import { bubbleUpChildViewEvent } from '#lib/utils'
import BrowserSelectorLi from './browser_selector_li'

export default Marionette.CollectionView.extend({
  tagName: 'ul',
  childView: BrowserSelectorLi,
  childViewEvents: {
    selectOption: bubbleUpChildViewEvent('selectOption')
  },
})
