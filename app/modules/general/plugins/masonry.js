// dependencies: behaviorsPlugin, paginationPlugin

import { isView } from 'lib/boolean_tests'
import Masonry from 'masonry-layout'
import screen_ from 'lib/screen'
import 'imagesloaded'

// To keep in sync with _items_list.scss $itemCardBaseWidth variable
const itemWidth = 230

export default function (containerSelector, itemSelector, minWidth = 500) {
  // MUST be called with the View it extends as context
  if (!isView(this)) {
    throw new Error('should be called with a view as context')
  }

  const initMasonry = function () {
    const $itemsCascade = $('.itemsCascade')

    // It often happen that after triggering a masonry view
    // the user triggered an other view so that when images are ready
    // there is no more masonry to do, thus this check
    if ($itemsCascade.length === 0) return

    const itemsPerLine = $itemsCascade.width() / itemWidth
    const tooFewItems = this.collection.length < itemsPerLine

    if (!screen_.isSmall(minWidth) && !tooFewItems) {
      const positionBefore = window.scrollY
      const container = document.querySelector(containerSelector)
      $(containerSelector).css('opacity', 0)
      // eslint-disable-next-line no-new
      new Masonry(container, {
        itemSelector,
        isFitWidth: true,
        isResizable: true,
        isAnimated: true,
        gutter: 5
      })

      screen_.scrollHeight(positionBefore, 0)
      return $(containerSelector).css('opacity', 1)
    }
  }

  const refresh = async () => {
    // Wait for images to be loaded
    $(containerSelector).imagesLoaded()
      // Use always to trigger the callback even if some images failed to load
      .always(initMasonry.bind(this))
      .fail(err => {
        // Ignore jQuery imagesLoaded errors for broken images
        if (err.hasAnyBroken) return
        console.error('imagesloaded error', err)
      })
  }

  this._lazyMasonryRefresh = _.debounce(refresh.bind(this), 200)
}
