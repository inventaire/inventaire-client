const folders = {
  js: '/public/js',
  css: '/public/css'
}

// Return a function as that's what lib/get_assets expects
const getEnvPath = (type, pathBase) => function () {
  let path = `${folders[type]}/${pathBase}`
  if (window.env !== 'dev') { path += '.min' }
  return `${path}.${type}`
}

// Keep versions in sync with scripts/install_external_modules
const quaggaBase = 'quagga-0.11.5-bust-1'
const isbn2Base = 'isbn2-0.1.8-bust-1'
const papaparseBase = 'papaparse-4.1.2-bust-1'
const cropperBase = 'cropper-2.3.0-bust-1'
const leafletBase = 'leaflet-bundle-1.3.1-bust-1'
const piwikBase = 'piwik-3.13.5'

export const scripts = {
  quagga: getEnvPath('js', quaggaBase),
  isbn2: getEnvPath('js', isbn2Base),
  papaparse: getEnvPath('js', papaparseBase),
  cropper: getEnvPath('js', cropperBase),
  leaflet: getEnvPath('js', leafletBase),
  piwik: getEnvPath('js', piwikBase)
}

export const stylesheets = {
  cropper: getEnvPath('css', cropperBase),
  leaflet: getEnvPath('css', leafletBase)
}
