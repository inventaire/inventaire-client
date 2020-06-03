metaNodes =
  title: [
    { selector: 'title', attribute: 'text' }
    { selector: '[property="og:title"]' }
    { selector: '[name="twitter:title"]' }
  ]
  description: [
    { selector: '[property="og:description"]' }
    { selector: '[name="twitter:description"]' }
  ]
  image: [
    { selector: '[property="og:image"]' }
    { selector: '[name="twitter:image"]' }
  ]
  url: [
    { selector: '[property="og:url"]' }
    { selector: '[rel="canonical"]', attribute: 'href' }
  ]
  rss: [
    { selector: '[type="application/rss+xml"]', attribute: 'href' }
  ]
  'prerender-status-code': [
    { selector: '[name="prerender-status-code"]' }
  ]
  'og:type': [
    { selector: '[property="og:type"]' }
  ]
  'twitter:card': [
    { selector: '[name="twitter:card"]' }
  ]

possibleFields = Object.keys metaNodes
module.exports = { metaNodes, possibleFields }
