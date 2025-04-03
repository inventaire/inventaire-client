import escape from 'escape-html'

export const escapeHtml = escape

// regex inspired by https://gist.github.com/efeminella/2034192
const link = /(\b(https?|ftp):\/\/[-A-Z0-9+&@#/%?=~_|!:,.;]+)/gim
const protocolText = '<a href="$1" class="content-link" target="_blank" rel="nofollow noreferrer">$1</a>'

export function userContent (text: string) {
  if (typeof text === 'string') {
    // Escape potential HTML markup to prevent XSS
    text = escapeHtml(text)
    const html = text
      .replace(/\n/g, '<br>')
    // Display URLs in the provided text as links
      .replace(link, protocolText)
    return html
  }
}
