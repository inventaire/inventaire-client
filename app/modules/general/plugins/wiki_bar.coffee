events =
  'click a.showWikipediaPreview': 'toggleWikiIframe'

handlers =
  toggleWikiIframe: ->
    $wpiframe = @$el.find('.wikipedia-iframe')
    $iframe = $wpiframe.find('iframe')
    $carets = @$el.find('.wikipedia-iframe').find('.fa')

    $iframe.toggle()
    $carets.toggle()

    hasIframe = $iframe.length > 0
    unless hasIframe
      appendWikipediaFrame.call @, $wpiframe
      $wpiframe.find('iframe').show()
      _.scrollTop $wpiframe

appendWikipediaFrame = ($el)->
  url = @model.get('wikipedia.url')
  src = "#{url}?useskin=mobil&mobileaction=toggle_view_mobile"
  $el.append "<iframe src=\"#{src}\" frameborder='0'></iframe>"

scrollToIframeTop = ($el)->
  height = $el.offset().top
  $('body').animate({scrollTop: height}, 500)

module.exports = _.BasicPlugin events, handlers
