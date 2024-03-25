import Handlebars from 'handlebars/runtime.js'

const { SafeString, escapeExpression } = Handlebars

// regex inspired by https://gist.github.com/efeminella/2034192
const link = /(\b(https?|ftp):\/\/[-A-Z0-9+&@#/%?=~_|!:,.;]+)/gim
const protocolText = '<a href="$1" class="content-link" target="_blank" rel="nofollow noreferrer">$1</a>'

export function userContent (text) {
  if (text != null) {
    text = escapeExpression(text)
    text = text
      .replace(/\n/g, '<br>')
      .replace(link, protocolText)
    return new SafeString(text)
  }
}
