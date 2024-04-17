import app from '#app/app'
import log_ from '#app/lib/loggers'
import applyTransformers from './apply_transformers.ts'
import { metaNodes, possibleFields } from './nodes.ts'

const head = document.querySelector('head')

const previousValue = {}

export default function (key: string, value: string, noCompletion?: boolean) {
  // Early return if the input is the same as previously
  if (previousValue[key] === value) return
  previousValue[key] = value

  if (!possibleFields.includes(key)) {
    return log_.warn([ key, value ], 'invalid metadata data')
  }

  if (value == null) {
    log_.warn(`missing metadata value: ${key}`)
    return
  }

  if (key === 'title') {
    app.execute('track:page:view', value)
  }

  value = applyTransformers(key, value, noCompletion)
  for (const el of metaNodes[key]) {
    updateNodeContent(value, el)
  }
}

const updateNodeContent = function (value, el) {
  let { selector, attribute } = el
  if (!attribute) attribute = 'content'
  if (head.querySelector(selector) != null) {
    head.querySelector(selector)[attribute] = value
  }
}
