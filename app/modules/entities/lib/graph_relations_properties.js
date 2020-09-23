properties = require './properties'
graphRelationEditorType = [ 'entity', 'fixed-entity' ]

module.exports = _.values properties
  .filter (prop)-> prop.editorType in graphRelationEditorType
  .map _.property('property')
