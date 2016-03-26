quagga = '/public/javascripts/quagga-0.9.2.min.js'

module.exports =
  quagga: ->
    if window.env is 'dev' then quagga.replace '.min', ''
    else quagga
