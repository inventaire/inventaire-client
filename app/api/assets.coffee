folders =
  js: '/public/js'
  css: '/public/css'

# Return a function as that's what lib/get_assets expects
getEnvPath = (type, pathBase)-> ()->
  path = "#{folders[type]}/#{pathBase}"
  if window.env isnt 'dev' then path += '.min'
  return "#{path}.#{type}"

# Keep versions in sync with scripts/install_external_modules
quaggaBase = 'quagga-0.11.5-bust-1'
isbn2Base = 'isbn2-0.1.8-bust-1'
papaparseBase = 'papaparse-4.1.2-bust-1'
cropperBase = 'cropper-2.3.0-bust-1'
leafletBase = 'leaflet-bundle-1.3.1-bust-1'
piwikBase = 'piwik-3.0.1-bust-1'

module.exports =
  scripts:
    quagga: getEnvPath 'js', quaggaBase
    isbn2: getEnvPath 'js', isbn2Base
    papaparse: getEnvPath 'js', papaparseBase
    cropper: getEnvPath 'js', cropperBase
    leaflet: getEnvPath 'js', leafletBase
    piwik: getEnvPath 'js', piwikBase
  stylesheets:
    cropper: getEnvPath 'css', cropperBase
    leaflet: getEnvPath 'css', leafletBase
