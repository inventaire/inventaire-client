import { waitingForPolyfills } from '#app/init_polyfills'
import { viewportIsSmallerThan, viewportIsLargerThan } from '#lib/screen'
import { readable } from 'svelte/store'
import { debounce } from 'underscore'

const getStoreValue = () => {
  return {
    width: window.visualViewport?.width || window.screen.width,
    height: window.visualViewport?.height || window.screen.height,
    isSmallerThan: viewportIsSmallerThan,
    isLargerThan: viewportIsLargerThan,
  }
}

export const screen = readable(getStoreValue(), set => {
  const update = () => set(getStoreValue())
  const lazyUpdate = debounce(update, 100)
  window.addEventListener('resize', lazyUpdate)
  // Update once window.visualViewport becomes available in legacy browsers
  waitingForPolyfills.then(lazyUpdate)
  const stop = () => window.removeEventListener('resize', lazyUpdate)
  return stop
})
