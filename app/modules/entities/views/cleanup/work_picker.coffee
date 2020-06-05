getActionKey = require 'lib/get_action_key'
mergeEntities = require 'modules/entities/views/editor/lib/merge_entities'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'

module.exports = Marionette.ItemView.extend
  template: require './templates/work_picker'

  ui:
    workPickerSelect: '.workPickerSelect'
    workPickerValidate: '.validate'

  initialize: ->
    if @workPickerDisabled then return
    { @worksWithOrdinal, @worksWithoutOrdinal, @_showWorkPicker } = @options
    @workUri ?= @options.workUri
    @afterMerge ?= @options.afterMerge
    @_showWorkPicker ?= false

  onRender: ->
    if @workPickerDisabled then return
    if @_showWorkPicker
      @setTimeout @ui.workPickerSelect.focus.bind(@ui.workPickerSelect), 100
      @startListingForChanges()

  startListingForChanges: ->
    if @_listingForChanges then return
    @_listingForChanges = true
    @listenTo @worksWithOrdinal, 'update', @lazyRender.bind(@)
    @listenTo @worksWithoutOrdinal, 'update', @lazyRender.bind(@)

  behaviors:
    AlertBox: {}

  events:
    'click .showWorkPicker': 'showWorkPicker'
    'change .workPickerSelect': 'onSelectChange'
    'click .validate': 'selectWork'
    'keydown .workPickerSelect': 'onKeyDown'

  onKeyDown: (e)->
    key = getActionKey e
    switch key
      when 'esc' then @hideWorkPicker()
      when 'enter' then @selectWork()

  selectWork: ->
    uri = @ui.workPickerSelect.val()
    unless _.isEntityUri(uri) then return
    work = @findWorkByUri uri
    unless work? then return
    @onWorkSelected work

  showWorkPicker: ->
    @_showWorkPicker = true
    @lazyRender()

  hideWorkPicker: ->
    @_showWorkPicker = false
    @lazyRender()

  onSelectChange: ->
    uri = @ui.workPickerSelect.val()
    if _.isEntityUri uri then @ui.workPickerValidate.removeClass 'hidden'
    else @ui.workPickerValidate.addClass 'hidden'

  getWorksList: ->
    @worksWithOrdinal.serializeNonPlaceholderWorks()
    .concat @worksWithoutOrdinal.serializeNonPlaceholderWorks()
    .filter (work)=> work.uri isnt @workUri

  findWorkByUri: (uri)->
    work = @worksWithOrdinal.findWhere { uri }
    if work? then return work
    work = @worksWithoutOrdinal.findWhere { uri }
    if work? then return work

  # Defaults: assume it as a work model that needs to be merged
  # Override the following methods for different behaviors
  serializeData: ->
    worksList: @getWorksList()
    workPicker:
      buttonIcon: 'compress'
      buttonLabel: 'merge'
      validateLabel: 'merge'

  onWorkSelected: (work)->
    fromUri = @model.get 'uri'
    toUri = work.get 'uri'

    @model.fetchSubEntities()
    .then -> mergeEntities fromUri, toUri
    .then @afterMerge.bind(@, work)
    .catch error_.Complete('.workPicker', false)
    .catch forms_.catchAlert.bind(null, @)
