import { readable } from 'svelte/store'

export const screen = readable({}, set => {
  const update = () => {
    set({
      width: window.screen.width,
      height: window.screen.height,
      isSmallerThan,
    })
  }

  update()
  window.addEventListener('resize', update)

  return () => {
    window.removeEventListener('resize', update)
  }
})

const isSmallerThan = maxWidth => window.screen.width < maxWidth
