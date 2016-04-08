jsFolder = '/public/js'

GetEnvPath = (pathBase)->
  getEnvPath = ->
    if window.env is 'dev' then "#{jsFolder}/#{pathBase}.js"
    else "#{jsFolder}/#{pathBase}.min.js"

module.exports =
  # keep versions in sync with scripts/install_external_js_modules
  quagga: GetEnvPath 'quagga-0.10.2'
  memdown: GetEnvPath 'memdown-1.1.2'
  moment: (lang)-> "#{jsFolder}/moment/#{lang}.js?DIGEST"
