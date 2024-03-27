import { getEndpointPathBuilders } from './endpoint.ts'

const { action } = getEndpointPathBuilders('images')

export default {
  upload (container, hash) { return action('upload', { container, hash }) },
  convertUrl: action('convert-url'),
  dataUrl (url) { return action('data-url', { url: encodeURIComponent(url) }) },
  gravatar: action('gravatar'),
}
