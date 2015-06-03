module.exports = Marionette.Behavior.extend
  ui:
    wpiframe: '.wikipedia-iframe'

  events:
    'toggleWikiIframe': (e, ctx)-> toggleWikiIframe.call ctx

toggleWikiIframe = ->
  $wpiframe = @$el.find('.wikipedia-iframe')
  $iframe = $wpiframe.find('iframe')
  $carets = @$el.find('.wikipedia-iframe').find('.fa')

  $iframe.toggle()
  $carets.toggle()

  hasIframe = $iframe.length > 0
  unless hasIframe
    appendWikipediaFrame.call @, $wpiframe
    $wpiframe.find('iframe').show()
    scrollToIframeTop($wpiframe)

appendWikipediaFrame = ($el)->
  url = @model.get('wikipedia.url')
  src = "#{url}?useskin=mobil&mobileaction=toggle_view_mobile"
  $el.append "<iframe src=\"#{src}\" frameborder='0'></iframe>"

scrollToIframeTop = ($el)->
  height = $el.offset().top
  $('body').animate({scrollTop: height}, 500)
