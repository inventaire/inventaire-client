import endpoint from './endpoint.js'
const { action } = endpoint('data')

export default {
  wikipediaExtract (lang, title) {
    return action('wp-extract', { lang, title })
  },
  isbn (isbn) {
    return action('isbn', { isbn })
  },
  summaries: ({ uri, langs, refresh }) => {
    return action('summaries', { uri, langs, refresh })
  },
}
