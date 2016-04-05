jsFolder = '/public/js'

GetEnvPath = (pathBase)->
  getEnvPath = ->
    if window.env is 'dev' then "#{jsFolder}/#{pathBase}.js"
    else "#{jsFolder}/#{pathBase}.min.js"

module.exports =
  quagga: GetEnvPath 'quagga-0.9.2'
  memdown: GetEnvPath 'memdown-1.1.2'
  moment: (lang)-> "#{jsFolder}/moment/#{lang}.js?DIGEST"
