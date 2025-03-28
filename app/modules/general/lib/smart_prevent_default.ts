import { isOpenedOutside } from '#app/lib/utils'

const { origin } = location

// Prevent default click event behavior selectively
export function preventAnchorDefault (e) {
  // largely inspired by
  // https://github.com/jmeas/backbone.intercept/blob/master/src/backbone.intercept.js

  // Only intercept left-clicks
  if (e.which !== 1) return

  const anchorEl = e.target.closest('a')
  if (!anchorEl) return

  const { href } = anchorEl
  if (!href) return

  if (isOpenedOutside(e, true)) return

  // Return if the URL is absolute (thus with ://)
  // or if the protocol is mailto or javascript
  if (/^#|javascript:|mailto:|(?:\w+:)?\/\//.test(href) && !href.startsWith(origin)) return

  // Return if the URL is an API call
  // Ex: Wikidata Oauth, data export, etc.
  if (href.startsWith(`${origin}/api/`)) return

  // If we haven't been stopped yet, then we prevent the default action
  e.preventDefault()
}
