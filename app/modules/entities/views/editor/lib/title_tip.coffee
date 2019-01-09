# Display a tip when a work label or an edition title contains the label of their serie
# to invite to remove the serie label part
module.exports =
  initWorkLabelsTip: (work)-> setSerieData.call @, work

  initEditionTitleTip: (edition)->
    # Only support cases where there is only 1 known work to keep things simple for now
    unless edition.get('claims.wdt:P629')?.length is 1 then return

    edition.waitForWorks
    .then =>
      editionLang = @model.entity.get('originalLang')
      work = editions.works[0]
      setSerieData.call @, work, editionLang

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

setSerieData = (work, editionLang)->
  seriesUris = work.get 'claims.wdt:P179'
  # Only support cases where there is only 1 known serie to keep things simple for now
  unless seriesUris?.length is 1 then return

  app.request 'get:entity:model', seriesUris[0]
  .then (serie)=>
    serieLang = serie.get 'originalLang'
    workLang = work.get 'originalLang'
    langs = _.uniq _.compact([ app.user.lang, editionLang, workLang, serieLang ])
    @_serieLabels = _.values _.pick(serie.get('labels'), langs)
    @_serieEditorPathname = serie.get 'edit'
