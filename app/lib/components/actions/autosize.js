import _autosize from 'autosize'

export function autosize (node) {
  _autosize(node)
  node.addEventListener('keyup', () => _autosize.update(node))
}
