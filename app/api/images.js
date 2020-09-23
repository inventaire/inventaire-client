import endpoint from './endpoint'
const { action } = endpoint('images')

export default {
  upload (container, hash) { return action('upload', { container, hash }) },
  convertUrl: action('convert-url'),
  dataUrl (url) { return action('data-url', { url: encodeURIComponent(url) }) },
  gravatar: action('gravatar')
}
