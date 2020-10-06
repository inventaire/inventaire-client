import BrowserSelectorLi from './browser_selector_li'

export default Marionette.CollectionView.extend({
  tagName: 'ul',
  childView: BrowserSelectorLi
})
