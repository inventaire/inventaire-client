folders =
  js: '/public/js'
  css: '/public/css'

# Return a function as that's what lib/get_assets expects
getEnvPath = (type, pathBase)-> ()->
  path = "#{folders[type]}/#{pathBase}"
  if window.env isnt 'dev' then path += '.min'
  return "#{path}.#{type}"

# Keep versions in sync with scripts/install_external_js_modules
quaggaIsbnBaseName = 'quagga-0.11.5-isbn-0.1.8-bundle'
cropperBaseName = 'cropper-2.3.0'
leafletBaseName = 'leaflet-bundle-1.3.1'
papaparseBaseName = 'papaparse-4.1.2'
piwikBaseName = 'piwik-3.0.1'

module.exports =
  scripts:
    moment: (lang)-> "#{folders.js}/moment/#{lang}.js?DIGEST"
    quaggaIsbn: getEnvPath 'js', quaggaIsbnBaseName
    cropper: getEnvPath 'js', cropperBaseName
    leaflet: getEnvPath 'js', leafletBaseName
    papaparse: getEnvPath 'js', papaparseBaseName
    piwik: getEnvPath 'js', piwikBaseName
  stylesheets:
    cropper: getEnvPath 'css', cropperBaseName
    leaflet: getEnvPath 'css', leafletBaseName
