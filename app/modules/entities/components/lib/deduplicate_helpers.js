import objectStore from 'lib/components/object_store'

export function getSelectionStore () {
  const selection = objectStore({})

  selection.select = entity => {
    selection.update(data => {
      if (!data.from) {
        if (data.to === entity) data.to = null
        if (entity.prefix === 'wd') data.to = entity
        else data.from = entity
      } else if (!data.to) {
        if (data.from === entity) data.from = null
        data.to = entity
      } else {
        if (entity.prefix === 'wd') {
          data.from = null
          data.to = entity
        } else {
          data.from = entity
          data.to = null
        }
      }
      return data
    })
  }

  selection.reset = () => selection.assign({ from: null, to: null })

  return selection
}

export const getEntityFilter = text => {
  if (!text || text.trim().length === 0) return () => true

  // Using a regex allows to accept
  const re = new RegExp(text, 'i')
  return entity => anyLabelOrAliasMatch(entity, re)
}

const anyLabelOrAliasMatch = function (entity, re) {
  entity._matchable = entity._matchable || getEntityLabelsAndAliases(entity)
  return entity._matchable.some(term => term.match(re))
}

const getEntityLabelsAndAliases = entity => {
  const labels = Object.values(entity.labels)
  const aliases = Object.values(entity.aliases || [])
  return labels.concat(...aliases)
}
