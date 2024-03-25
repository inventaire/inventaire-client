import { readable } from 'svelte/store'
import { debounce } from 'underscore'
import { waitingForPolyfills } from '#app/init_polyfills'
import { viewportIsSmallerThan, viewportIsLargerThan, getViewportWidth, getViewportHeight } from '#lib/screen'

const getStoreValue = () => {
  return {
    width: getViewportWidth(),
    height: getViewportHeight(),
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
