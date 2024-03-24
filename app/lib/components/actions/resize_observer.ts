import assert_ from '#lib/assert_types'

export function resizeObserver (node, options) {
  const { onElementResize } = options
  assert_.function(onElementResize)

  const resizeObserver = new ResizeObserver(entries => {
    // console.log('height changed:', entries[0].target.clientHeight)
    onElementResize()
  })

  resizeObserver.observe(node)

  return {
    destroy () {
      resizeObserver.disconnect()
    },
  }
}
