module.exports = Marionette.Behavior.extend
  events:
    'click a.showWikipediaPreview': 'toggleWikiIframe'

  toggleWikiIframe: ->
    $wpiframe = @$el.find('.wiki-bar')
    $iframe = $wpiframe.find('iframe')
    $carets = @$el.find('.wiki-bar').find('.fa')

    $iframe.toggle()
    $carets.toggle()

    hasIframe = $iframe.length > 0
    unless hasIframe
      appendWikipediaFrame @view.model, $wpiframe
      $wpiframe.find('iframe').show()

    _.scrollTop $wpiframe

appendWikipediaFrame = (model, $el)->
  url = model.get 'wikipedia.url'
  src = "#{url}?useskin=mobil&mobileaction=toggle_view_mobile"
  $el.append "<iframe src=\"#{src}\" frameborder='0'></iframe>"
