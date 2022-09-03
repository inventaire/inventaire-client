import { readable } from 'svelte/store'

const getStoreValue = () => {
  return {
    width: window.visualViewport.width,
    height: window.visualViewport.height,
    isSmallerThan,
    isLargerThan,
  }
}

const isSmallerThan = maxWidth => window.visualViewport.width < maxWidth
const isLargerThan = maxWidth => window.visualViewport.width > maxWidth

export const screen = readable(getStoreValue(), set => {
  const update = () => set(getStoreValue())

  update()
  window.addEventListener('resize', update)

  return () => {
    window.removeEventListener('resize', update)
  }
})
