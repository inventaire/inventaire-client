import { host } from 'lib/urls'

const absolutePath = url => {
  if (url?.[0] === '/') {
    return host + url
  } else {
    return url
  }
}

export default function (key, value, noCompletion) {
  if (withTransformers.includes(key)) {
    return transformers[key](value, noCompletion)
  } else {
    return value
  }
}

export const transformers = {
  title: (value, noCompletion) => noCompletion ? value : `${value} - Inventaire`,
  url: canonicalPath => {
    canonicalPath = canonicalPath.replace(/$\//, '')
    let url = `${window.location.origin}/${canonicalPath}`

    // Preserver parameters that make a resource different enough,
    // that the prerendered version returned should be different
    const lang = app.request('querystring:get', 'lang')
    if (lang) url += `?lang=${lang}`

    return url
  },
  image: url => {
    if (url.match(/\d+x\d+/)) {
      return absolutePath(url)
    } else {
      return absolutePath(app.API.img(url))
    }
  }
}

const withTransformers = Object.keys(transformers)
