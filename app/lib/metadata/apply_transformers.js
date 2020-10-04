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

const transformers = {
  title: (value, noCompletion) => noCompletion ? value : `${value} - Inventaire`,
  url: canonical => host + canonical,
  image: url => {
    if (url.match(/\d+x\d+/)) {
      return absolutePath(url)
    } else {
      return absolutePath(app.API.img(url))
    }
  }
}

const withTransformers = Object.keys(transformers)
