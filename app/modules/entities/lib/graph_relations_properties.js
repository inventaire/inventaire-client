/* eslint-disable
    import/no-duplicates,
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import properties from './properties'
const graphRelationEditorType = [ 'entity', 'fixed-entity' ]

export default _.values(properties)
  .filter(prop => graphRelationEditorType.includes(prop.editorType))
  .map(_.property('property'))
