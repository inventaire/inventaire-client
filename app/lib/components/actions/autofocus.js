import isMobile from '#lib/mobile_check'

export function autofocus (node, options = {}) {
  // Do not auto focus on mobile as it displays the virtual keyboard
  // which can take pretty much all the screen
  if (isMobile) return

  node.focus()

  function focusOnVisibilityChange () {
    if (document.visibilityState === 'visible') node.focus()
  }

  document.addEventListener('visibilitychange', focusOnVisibilityChange)

  return {
    destroy () {
      document.removeEventListener('visibilitychange', focusOnVisibilityChange)
    }
  }
}
