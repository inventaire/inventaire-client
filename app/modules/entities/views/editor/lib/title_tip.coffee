# Display a tip when a work label or an edition title contains the label of their serie
# to invite to remove the serie label part
module.exports =
  initWorkLabelsTip: (work)-> setWorkAndSerieData.call @, work

  initEditionTitleTip: (edition)->
    # Only support cases where there is only 1 known work to keep things simple for now
    unless edition.get('claims.wdt:P629')?.length is 1 then return

    edition.waitForWorks
    .then =>
      editionLang = @model.entity.get('originalLang')
      work = editions.works[0]
      setWorkAndSerieData.call @, work, editionLang

  tipOnKeyup: (e)->
    displayTipIfMatch.call @, e.target.value

  tipOnRender: (e)->
    displayTipIfMatch.call @, @ui.input.val()

displayTipIfMatch = (value)->
  unless @_serieLabels? and @editMode then return

  matchingSerieLabel = findMatchingSerieLabel value, @_serieLabels


  if matchingSerieLabel?
    showSerieLabelTip.call @, matchingSerieLabel
  else
    hideSerieLabelTip.call @

volumePattern = /\s*(v|vol|volume|t|tome)?\.?\s*(\d+)?$/

# Display the tip if the serie label is used in addition to another title.
# If it's just the serie label, plus possibly a volume number, the tip isn't helpful
findMatchingSerieLabel = (value, serieLabels)->
  value = value
    .toLowerCase()
    # Ignore volume information to determine if there is a match with the serie label
    .replace volumePattern, ''
    .trim()

  for label in serieLabels
    # Start with the serie label, followed by a separator
    # and some title of at least 5 characters
    re = new RegExp "^#{label}\\s?(:|-|,).{5}", 'i'
    if re.test(value) then return label

  return

showSerieLabelTip = (matchingSerieLabel)->
  unless @editMode then return
  tip = _.i18n 'title_matches_serie_label_tip', { pathname: @_serieEditorPathname }
  serieHref = "href=\"#{@_serieEditorPathname}\""
  tip = tip.replace serieHref, "#{serieHref} title=\"#{matchingSerieLabel}\""
  @ui.tip.html tip
  @ui.tip.fadeIn()

hideSerieLabelTip = ->
  unless @editMode then return
  @ui.tip.fadeOut()

setWorkAndSerieData = (work, editionLang)->
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
