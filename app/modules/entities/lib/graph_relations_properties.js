import properties from './properties';
const graphRelationEditorType = [ 'entity', 'fixed-entity' ];

export default _.values(properties)
  .filter(prop => graphRelationEditorType.includes(prop.editorType))
  .map(_.property('property'));
