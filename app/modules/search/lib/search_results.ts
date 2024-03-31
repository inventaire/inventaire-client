import { pluralize } from '#entities/lib/types/entities_types'
import { isImageHash } from '#lib/boolean_tests'
import { serverReportError } from '#lib/error'
import { getUserBasePathname } from '#users/lib/users'

export function serializeResult (result) {
  try {
    if (result.image instanceof Array) {
      result.image = result.image[0]
    }
    result.image = urlifyImageHash(result.type, result.image)
    const pluralizedType = pluralize(result.type)
    const formatter = typeFormatters[pluralizedType] || entityFormatter
    return formatter(result)
  } catch (err) {
    err.context = { result }
    throw err
  }
}

const entityFormatter = typeAlias => result => {
  result.typeAlias = typeAlias
  result.pathname = `/entity/${result.uri}`
  return result
}

const typeFormatters = {
  editions: entityFormatter('edition'),
  works: entityFormatter('work'),
  humans: entityFormatter('author'),
  series: entityFormatter('serie'),
  collections: entityFormatter('collection'),
  publishers: entityFormatter('publisher'),
  users (result) {
    result.typeAlias = 'user'
    // label is the username
    result.pathname = getUserBasePathname(result.label)
    return result
  },

  groups (result) {
    result.typeAlias = 'group'
    result.pathname = `/groups/${result.id}`
    return result
  },

  shelves (result) {
    result.typeAlias = 'shelf'
    result.pathname = `/shelves/${result.id}`
    return result
  },

  lists (result) {
    result.typeAlias = 'list'
    result.pathname = `/lists/${result.id}`
    return result
  },

  subjects (result) {
    result.typeAlias = 'subject'
    result.pathname = `/entity/wdt:P921-${result.uri}`
    // Let app/lib/shared/api/img.js request to be redirected
    // to the associated entity image
    result.image = result.uri
    return result
  },
}

export const urlifyImageHash = function (type, hash) {
  const nonEntityContainer = nonEntityContainersPerType[type]
  const container = nonEntityContainer || 'entities'
  if (isImageHash(hash)) {
    return `/img/${container}/${hash}`
  } else {
    return hash
  }
}

const nonEntityContainersPerType = {
  users: 'users',
  groups: 'users',
}

// Pre-formatting is required to set the type
// Taking the opportunity to omit all non-required data
export const serializeSubject = result => ({
  id: result.id,
  label: result.label,
  description: result.description,
  uri: `wd:${result.id}`,
  type: 'subjects',
})

export const serializeEntityModel = function (entity) {
  if (entity?.toJSON == null) {
    serverReportError('cant format invalid entity', { entity })
    return
  }

  const data = entity.toJSON()
  data.image = data.image?.url
  return serializeResult(data)
}
