import { readable } from 'svelte/store'

const getStoreValue = () => {
  return {
    width: window.screen.width,
    height: window.screen.height,
    isSmallerThan,
    isLargerThan,
  }
}

const isSmallerThan = maxWidth => window.screen.width < maxWidth
const isLargerThan = maxWidth => window.screen.width > maxWidth

export const screen = readable(getStoreValue(), set => {
  const update = () => set(getStoreValue())

  update()
  window.addEventListener('resize', update)

  return () => {
    window.removeEventListener('resize', update)
  }
})
