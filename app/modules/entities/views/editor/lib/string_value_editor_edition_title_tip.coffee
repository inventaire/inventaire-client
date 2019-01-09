module.exports =
  initEditionTitleTip: ->
    unless @model.get('property') is 'wdt:P1476' then return
    unless @model.entity.get('type') is 'edition' then return
    @model.entity.waitForWorks?.then _initStep2.bind(@)

  tipOnKeyup: (e)->
    displayTipIfMatch.call @, e.target.value

  tipOnRender: (e)->
    displayTipIfMatch.call @, @ui.input.val()

displayTipIfMatch = (value)->
  unless @_serieLabels? and @editMode then return

  if matchesSerieLabels value, @_serieLabels
    showSerieLabelTip.call @
  else
    hideSerieLabelTip.call @

matchesSerieLabels = (value, serieLabels)->
  value = value.toLowerCase().trim()
  for label in serieLabels
    if value.match label.toLowerCase()
      # Display the tip if the serie label is used in addition to another title.
      # If it's just the serie label, plus possibly a volume number, the tip isn't helpful
      if value.length > label.length + 5 then return true
  return false

showSerieLabelTip = ->
  unless @editMode then return
  html = _.i18n 'title_matches_serie_label_tip', { pathname: @_serieEditorPathname }
  @ui.tip.html html
  @ui.tip.fadeIn()

hideSerieLabelTip = ->
  unless @editMode then return
  @ui.tip.fadeOut()

_initStep2 = ->
  # Only support cases where there is only 1 known work to keep things simple for now
  unless @model.entity.get('claims.wdt:P629')?.length is 1 then return
  # Series claims copied from work by the model
  # Only support cases where there is only 1 known serie to keep things simple for now
  unless @model.entity.get('claims.wdt:P179')?.length is 1 then return

  seriesUri = @model.entity.get 'claims.wdt:P179.0'
  app.request 'get:entity:model', seriesUri
  .then (serie)=>
    serieLang = serie.get 'originalLang'
    langs = getLangsOfInterest.call @, serieLang
    @_serieLabels = _.values _.pick(serie.get('labels'), langs)
    @_serieEditorPathname = serie.get 'edit'

getLangsOfInterest = (serieLang)->
  editionLang = @model.entity.get('originalLang')
  workLang = @model.entity.works[0].get('originalLang')
  return _.uniq _.compact([ app.user.lang, editionLang, workLang, serieLang ])
