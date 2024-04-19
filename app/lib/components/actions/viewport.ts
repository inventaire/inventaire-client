// Inspired by https://www.youtube.com/watch?v=1SKKzdHVvcI
// https://svelte.dev/repl/c6a402704224403f96a3db56c2f48dfc

let intersectionObserver

function ensureIntersectionObserverExists () {
  if (intersectionObserver) return

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
    },
  }
}
