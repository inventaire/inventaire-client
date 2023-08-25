import _autosize from 'autosize'

export function autosize (node) {
  // Automatically detects changes resulting from user input
  // but it fails to detect changes triggered by JS setting the textarea value
  _autosize(node)
  // Callin the update function doesn't seem to work
  // node.addEventListener('change', () => _autosize.update(node))
}
