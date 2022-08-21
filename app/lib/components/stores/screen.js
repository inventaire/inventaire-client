import { viewportIsSmallerThan, viewportIsLargerThan } from '#lib/screen'
import { readable } from 'svelte/store'
import { debounce } from 'underscore'

const getStoreValue = () => {
  return {
    width: window.visualViewport.width,
    height: window.visualViewport.height,
    isSmallerThan: viewportIsSmallerThan,
    isLargerThan: viewportIsLargerThan,
  }
}

export const screen = readable(getStoreValue(), set => {
  const update = () => set(getStoreValue())
  const lazyUpdate = debounce(update, 100)
  window.addEventListener('resize', lazyUpdate)
  const stop = () => window.removeEventListener('resize', lazyUpdate)
  return stop
})
