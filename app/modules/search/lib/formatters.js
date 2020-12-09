import error_ from 'lib/error'

// Pre-formatting is required to set the type
// Taking the opportunity to omit all non-required data
export const formatSubject = result => ({
  id: result.id,
  label: result.label,
  description: result.description,
  uri: `wd:${result.id}`,
  type: 'subjects'
})

export const formatEntity = function (entity) {
  if (entity?.toJSON == null) {
    error_.report('cant format invalid entity', { entity })
    return
  }

  const data = entity.toJSON()
  data.image = data.image?.url
  // Return a model to prevent having it re-formatted
  // as a Result model, which works from a result object, not an entity
  return new Backbone.Model(data)
}
