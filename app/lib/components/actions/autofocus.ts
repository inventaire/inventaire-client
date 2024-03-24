import isMobile from '#lib/mobile_check'

export function autofocus (node, options = {}) {
  // Do not auto focus on mobile as it displays the virtual keyboard
  // which can take pretty much all the screen
  if (isMobile || options.disabled) return

  const { refocusOnVisibilityChange = true } = options

  node.focus()

  function focusOnVisibilityChange () {
    if (document.visibilityState === 'visible') node.focus()
  }

  if (refocusOnVisibilityChange) {
    document.addEventListener('visibilitychange', focusOnVisibilityChange)
  }

  return {
    destroy () {
      if (refocusOnVisibilityChange) {
        document.removeEventListener('visibilitychange', focusOnVisibilityChange)
      }
    }
  }
}
