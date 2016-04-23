jsFolder = '/public/js'

GetEnvPath = (pathBase)->
  getEnvPath = ->
    path = "#{jsFolder}/#{pathBase}"
    if window.env isnt 'dev' then path += '.min'
    return "#{path}.js"

module.exports =
  moment: (lang)-> "#{jsFolder}/moment/#{lang}.js?DIGEST"
  # keep versions in sync with scripts/install_external_js_modules
  memdown: GetEnvPath 'memdown-1.1.2'
  quagga: GetEnvPath 'quagga-0.10.2'
  cropper: GetEnvPath 'cropper-2.3.0'
