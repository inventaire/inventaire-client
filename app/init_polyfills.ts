// Most polyfills are handled by babel/core-js (see bundle/rules/babel.cjs)
// but some could not be handled this way

export async function initPolyfills () {
  if (window.visualViewport == null) {
    await import('#vendor/visual_viewport_polyfill')
  }
}

export const waitingForPolyfills = initPolyfills()
