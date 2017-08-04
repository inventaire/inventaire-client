# A layout that shows entities in sub views according to the input it receives
# and let the user select those entities for merge

mergeEntities = require './editor/lib/merge_entities'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
{ startLoading, stopLoading } = require 'modules/general/plugins/behaviors'
deduplicateAuthors = require './deduplicate_authors'
deduplicateWorks = require './deduplicate_works'

module.exports = Marionette.LayoutView.extend
  id: 'deduplicateLayout'
  template: require './templates/deduplicate_layout'
  regions:
    content: '.content'
  behaviors:
    AlertBox: {}
    Loading: {}

  initialize: ->
    @mergedUris = []

  onShow: ->
    { uris, name } = app.request 'querystring:get:full'
    if uris? then @loadFromUris uris.split('|')
    else @showDeduplicateAuthors name

  loadFromUris: (uris)->
    app.request 'get:entities:models', { uris }
    .then _.Log('entities')
    .then (entities)=>
      # Guess type from first entity
      { type } = entities[0]
      switch type
        when 'human'
          if entities.length is 1 then return @showDeduplicateAuthorWorks entities[0]
        when 'works' then return @showDeduplicateWorks entities

      # If we haven't returned at this point, it is a non handled case
      alert 'case not handled yet'

  showDeduplicateAuthorWorks: (author)->
    author.getWorksData()
    .then (worksData)=>
      # Ignoring series
      uris = worksData.works.map _.property('uri')
      app.request 'get:entities:models', { uris }
      .then @showDeduplicateWorks.bind(@)

  showDeduplicateWorks: (works)-> @content.show new deduplicateWorks { works }
  showDeduplicateAuthors: (name)-> @content.show new deduplicateAuthors { name }

  serializeData: -> { @uris }

  events:
    'click .workLi,.authorLayout': 'select'
    'click .merge': 'mergeSelected'
    'keydown input[name="filter"]': 'filterByText'

  select: (e)->
    # Prevent selecting when the intent was clicking on a link
    if e.target.tagName is 'A' then return

    $target = $(e.currentTarget)
    uri = getTargetUri e
    $currentlySelected = $('.selected-from, .selected-to')

    switch $currentlySelected.length
      when 0 then $target.addClass 'selected-from'
      when 1
        if $target[0] isnt $currentlySelected[0]
          if getElementType($target[0]) is getElementType($currentlySelected[0])
            $target.addClass 'selected-to'
          else
            $currentlySelected.removeClass 'selected-from selected-to'
            $target.addClass 'selected-from'
      else
        $currentlySelected.removeClass 'selected-from selected-to'
        $target.addClass 'selected-from'

    # Prevent a click on a work to also trigger an event on the author
    e.stopPropagation()

  mergeSelected: ->
    fromUri = getElementUri $('.selected-from')[0]
    toUri = getElementUri $('.selected-to')[0]

    unless fromUri? then return alert "no 'from' URI"
    unless toUri? then return alert "no 'to' URI"

    startLoading.call @, '.merge'

    mergeEntities fromUri, toUri
    .then @successfulMerge.bind(@, fromUri)
    .finally stopLoading.bind(@)
    .catch error_.Complete('.buttons-wrapper', false)
    .catch forms_.catchAlert.bind(null, @)

  successfulMerge: (fromUri)->
    hideMergedEntities()
    @mergedUris.push fromUri
    $('.selected-from').removeClass 'selected-from'
    $('.selected-to').removeClass 'selected-to'
    @content.currentView.onMerge?()
    # Make the filter hide already merged entities
    @setSubviewFilter ''

  filterByText: (e)->
    @_lazyFilterByText or= _.debounce @lazyFilterByText.bind(@), 200
    @_lazyFilterByText e

  lazyFilterByText: (e)->
    text = e.target.value
    if text is @_previousText then return
    @_previousText = text
    @setSubviewFilter text

  setSubviewFilter: (text)->
    @content.currentView.setFilter getFilter(text, @mergedUris)

getElementUri = (el)-> el?.attributes['data-uri'].value
getTargetUri = (e)-> getElementUri e.currentTarget
getElementType = (el)-> if $(el).hasClass('authorLayout') then 'author' else 'work'

hideMergedEntities = ->
  $from = $('.selected-from')
  if $from.hasClass 'workLi'
    $author = $from.parents('.authorLayout')
    # If it was the last work, hide the whole author as it should have been turned
    # into a redirection
    if $author.find('.workLi').length is 1 then $author.hide()
    else $from.hide()
  else if $from.hasClass 'authorLayout'
    $from.hide()

getFilter = (text, mergedUris)->
  if _.isNonEmptyString text
    re = new RegExp text, 'i'
    return (model)-> anyLabelMatch(model, re) and model.get('uri') not in mergedUris
  else
    return (model)-> model.get('uri') not in mergedUris

anyLabelMatch = (model, re)->
  labels = _.values(model.get('labels'))
  return _.any labels, (label)-> label.match(re)
