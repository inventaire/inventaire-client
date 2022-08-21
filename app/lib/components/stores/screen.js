import { wellknownWidths } from '#lib/screen'
import { readable } from 'svelte/store'
import { debounce } from 'underscore'

const getStoreValue = () => {
  return {
    width: window.visualViewport.width,
    height: window.visualViewport.height,
    isSmallerThan,
    isLargerThan,
  }
}

const resolveWidth = width => wellknownWidths[width] ? wellknownWidths[width] : width
const isSmallerThan = maxWidth => window.visualViewport.width < resolveWidth(maxWidth)
const isLargerThan = maxWidth => window.visualViewport.width > resolveWidth(maxWidth)

export const screen = readable(getStoreValue(), set => {
  const update = () => set(getStoreValue())
  const lazyUpdate = debounce(update, 100)
  window.addEventListener('resize', lazyUpdate)
  const stop = () => window.removeEventListener('resize', lazyUpdate)
  return stop
})
