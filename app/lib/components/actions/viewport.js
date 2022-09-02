// Inspired by https://www.youtube.com/watch?v=1SKKzdHVvcI
// https://svelte.dev/repl/c6a402704224403f96a3db56c2f48dfc

let intersectionObserver

function ensureIntersectionObserverExists () {
  if (intersectionObserver) return

  // This will not work on "UC Browser for Android" (a.k.a. and_uc) 12.12
  // as "isIntersecting property of IntersectionObserverEntry was not implemented"
  // See https://caniuse.com/intersectionobserver
  // Core-js does not offer a polyfill for it
  // See https://github.com/zloirock/core-js/issues/386
  // eslint-disable-next-line compat/compat
  intersectionObserver = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      const eventName = entry.isIntersecting ? 'enterViewport' : 'leaveViewport'
      entry.target.dispatchEvent(new CustomEvent(eventName))
    })
  })
}

export default function viewport (element) {
  ensureIntersectionObserverExists()

  intersectionObserver.observe(element)

  return {
    destroy () {
      intersectionObserver.unobserve(element)
    }
  }
}
