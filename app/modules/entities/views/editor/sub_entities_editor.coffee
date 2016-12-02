entityDraftModel = require '../../lib/entity_draft_model'
createEntities = require '../../lib/create_entities'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'

module.exports = Marionette.CompositeView.extend
  className: 'sub-entities-editor'
  template: require './templates/sub_entities_editor'
  getChildView: -> require './entity_edit'
  childViewContainer: 'ul'
  childViewOptions:
    subeditor: true

  behaviors:
    AlertBox: {}

  initialize: ->
    { @parent } = @options
    @parentType = @parent.type
    capitalizedParentType = _.capitaliseFirstLetter @parentType
    @parentTypeFlag = getParentTypeFlab @parentType
    @[@parentTypeFlag] = true

  serializeData: ->
    data = {}
    data[@parentTypeFlag] = true
    return _.extend data,
      propertyLabel: propertyLabels[@options.property]
      addByIsbn: if @parentTypeIsWork then @addByIsbnData()

  addByIsbnData: ->
    nameBase: 'isbn'
    field:
      placeholder: _.i18n('ex:') + ' 978-2-07-036822-8'
      dotdotdot: ''
    button:
      icon: 'plus'
      text: 'add'
      classes: 'soft-grey postfix'

  events:
    'click .addValue': 'addSubEntity'
    'click #isbnButton': 'addWorkEditionSubEntity'

  addSubEntity: ->
    model = entityDraftModel.create()
    @collection.add model

  addWorkEditionSubEntity: ->
    isbn = @$el.find('#isbnField').val()
    createEntities.workEdition @parent, isbn
    .catch error_.Complete('#isbnField')
    .catch forms_.catchAlert.bind(null, @)

# build a flag name for the template to do {{#if}} blocks on
getParentTypeFlab = (parentType)->
  capitalizedParentType = _.capitaliseFirstLetter parentType
  return "parentTypeIs#{capitalizedParentType}"

propertyLabels =
  'wdt:P629': 'editions'
