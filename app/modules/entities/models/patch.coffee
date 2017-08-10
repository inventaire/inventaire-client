{ unprefixify } = require 'lib/wikimedia/wikidata'

module.exports = Backbone.NestedModel.extend
  initialize: (attrs)->
    entityId = attrs._id.split(':')[0]
    @set 'entityId', entityId
    invEntityUri = "inv:#{entityId}"
    @set 'invEntityUri', invEntityUri

    @reqGrab 'get:entity:model', invEntityUri, 'entity'
    @reqGrab 'get:user:model', attrs.user, 'user'

    dbVersionNumber = parseInt @id.split(':')[1]
    # The first version is an empty document with only the basic attributes:
    # doesn't really count as a version
    @set 'versionNumber', dbVersionNumber-1

    @mergeTestAndRemoveOperations()
    @setOperationsData()
    @set 'patchType', @findPatchType()
    @setOperationsSummaryData()

  mergeTestAndRemoveOperations: ->
    operations = @get 'patch'

    operations.forEach (operation, index)->
      if operation.op is 'remove'
        prevOperation = operations[index - 1]
        if prevOperation.op is 'test' and prevOperation.path is operation.path
          operation.value = prevOperation.value

    # Filter-out test operations, as it's not a useful information
    operations = operations.filter (operation)-> operation.op isnt 'test'
    @set 'operations', operations

  setOperationsData: ->
    operations = @get 'operations'

    for op in operations
      if op.path.startsWith '/claims/'
        op.property = op.path
          .replace /^\/claims\//, ''
          .replace /\/\d+$/, ''
        op.propertyLabel = _.i18n unprefixify(op.property)
      if op.path.startsWith '/labels/'
        lang = _.last op.path.split('/')
        op.propertyLabel = "label #{lang}"

    @set 'operations', operations

  findPatchType: ->
    if @get('versionNumber') is 1 then return 'creation'

    operations = @get 'operations'
    firstOp = operations[0]
    if firstOp.path is '/redirect' then return 'redirect'
    if firstOp.path is '/type'
      if firstOp.value is 'removed:placeholder' then return 'deletion'

    operationsTypes = operations.map _.property('op')
    if _.all(operationsTypes, isOpType('add')) then return 'add'
    else if _.all(operationsTypes, isOpType('replace')) then return 'add'
    else if _.all(operationsTypes, isOpType('remove')) then return 'remove'
    else return 'update'

  setOperationsSummaryData: ->
    patchType = @get 'patchType'
    operations = @get 'operations'

    switch patchType
      when 'add'
        operation = operations[0]
        { property, value, propertyLabel } = operation
        propertyLabel or= getPropertyLabel property
        @set 'summary', { property, propertyLabel, added: value }
      when 'remove'
        operation = operations[0]
        { property, value, propertyLabel } = operation
        propertyLabel or= getPropertyLabel property
        @set 'summary', { property, propertyLabel, removed: value }
      when 'update'
        addOperation = operations[0]
        { property, value:added, propertyLabel } = addOperation
        removeOperation = operations[1]
        { value:removed } = removeOperation
        propertyLabel or= getPropertyLabel property
        @set 'summary', { property, propertyLabel, added, removed }

  serializeData: ->
    attrs = @toJSON()
    # Grabed models might not have came back yet
    attrs.user = @user?.serializeData()
    attrs.entity = @entity?.toJSON()
    return attrs

isOpType = (type)-> (opType)-> opType is type

getPropertyLabel = (property)->
  _.i18n unprefixify(property)
