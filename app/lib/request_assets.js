# Adding assets by creating new assets node in the DOM,
# rather than by doing something like $('head').append("<style>#{cssText}</style")
# as recommanded by http://deano.me/2012/09/jquery-load-css-with-ajax-all-browsers
# Allows to not rely on the CSP 'unsafe-inline'
# Inspired by: https://jeremenichelli.github.io/2016/04/patterns-for-a-promise-based-initialization/

requestAsset = (type, url)->
  return new Promise (resolve, reject)->
    if type is 'css'
      node = document.createElement 'link'
      node.type = 'text/css'
      node.rel = 'stylesheet'
      node.href = url
    else
      node = document.createElement 'script'
      node.src = url
      node.async = true

    node.onload = resolve
    node.onerror = normalizeError reject, url

    document.head.appendChild node

module.exports =
  getCss: requestAsset.bind null, 'css'
  getScript: requestAsset.bind null, 'js'

normalizeError = (reject, url)-> (errEvent)->
  err = new Error('request asset failed')
  err.context = { url }
  reject err
