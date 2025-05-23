import { all, property, last, compact, pluck, uniq } from 'underscore'
import { API } from '#app/api/api'
import preq from '#app/lib/preq'
import { unprefixify } from '#app/lib/wikimedia/wikidata'
import { getEntitiesBasicInfoByUris, type SerializedEntity } from '#entities/lib/entities'
import type { RelativeUrl } from '#server/types/common'
import type { EntityUri, InvEntityId, InvEntityUri } from '#server/types/entity'
import type { Patch, PatchId } from '#server/types/patch'
import { i18n } from '#user/lib/i18n'
import type { SerializedContributor } from '#users/lib/users'
import { getUsersByAccts } from '#users/users_data'

export async function getEntityPatches (uri: EntityUri) {
  const { patches } = await preq.get(API.entities.history(uri))
  // Reversing to get the last patches first
  patches.reverse()
  return serializePatches(patches)
}

export interface SerializedPatchExtras {
  entityId: InvEntityId
  invEntityUri: InvEntityUri
  invEntityHistoryPathname: RelativeUrl
  versionNumber: number
  patchType: ReturnType<typeof findPatchType>
  contributor: SerializedContributor
  entity: SerializedEntity
}

export type SerializedPatch = Patch & SerializedPatchExtras

export async function serializePatches (patches: (Patch & Partial<SerializedPatchExtras>)[]) {
  const [ usersByAccts, entitiesByUris ] = await Promise.all([
    getPatchesUsers(patches),
    getPatchesEntities(patches),
  ])
  for (const patch of patches) {
    if (patch.user) {
      patch.contributor = usersByAccts[patch.user]
    }
    const uri = getPatchEntityUri(patch)
    patch.entity = entitiesByUris[uri]
    serializePatchSync(patch)
  }
  return patches as SerializedPatch[]
}

async function getPatchesUsers (patches) {
  const usersAccts = compact(pluck(patches, 'user'))
  return getUsersByAccts(usersAccts)
}

async function getPatchesEntities (patches) {
  const entitiesUris = uniq(pluck(patches, '_id').map(getEntityIdFromPatchId)).map(id => `inv:${id}` as InvEntityUri)
  return getEntitiesBasicInfoByUris(entitiesUris)
}

export const getPatchEntityUri = patch => {
  const id = getEntityIdFromPatchId(patch._id)
  return `inv:${id}`
}
const getEntityIdFromPatchId = (patchId: PatchId) => patchId.split(':')[0] as InvEntityId

function serializePatchSync (patch: Patch & Partial<SerializedPatchExtras>) {
  const { _id: patchId } = patch
  const entityId = getEntityIdFromPatchId(patchId)
  // The first version is an empty document with only the basic attributes:
  // doesn't really count as a version
  const versionNumber = parseInt(patchId.split(':')[1]) - 1
  const invEntityUri = `inv:${entityId}`
  Object.assign(patch, {
    entityId,
    invEntityUri,
    invEntityHistoryPathname: `/entity/${invEntityUri}/history`,
    versionNumber,
  })
  mergeTestAndRemoveOperations(patch)
  setOperationsData(patch)
  patch.patchType = findPatchType(patch as SerializedPatch)
  setOperationsSummaryData(patch)
  return patch
}

function mergeTestAndRemoveOperations (patch) {
  const { operations } = patch

  operations.forEach((operation, index) => {
    if (operation.op === 'remove') {
      const prevOperation = operations[index - 1]
      if ((prevOperation.op === 'test') && (prevOperation.path === operation.path)) {
        operation.value = prevOperation.value
      }
    }
  })

  // Filter-out test operations, as it's not a useful information
  patch.operations = operations.filter(operation => operation.op !== 'test')
}

function setOperationsData (patch) {
  const { operations, user } = patch
  for (const operation of operations) {
    setOperationData(operation, user)
  }
}

function setOperationData (operation, user) {
  const { path } = operation
  if (path === '/labels') {
    operation.propertyLabel = 'labels'
  } else if (path.startsWith('/labels/')) {
    const lang = last(path.split('/'))
    operation.propertyLabel = `label ${lang}`
    operation.filter = lang
  } else if (path === '/claims') {
    operation.propertyLabel = 'claims'
  } else if (path.startsWith('/claims/')) {
    operation.property = path
        .replace(/^\/claims\//, '')
        .replace(/\/\d+$/, '')
    operation.propertyLabel = getPropertyLabel(operation.property)
    operation.filter = operation.property
  } else if (path.startsWith('/redirect')) {
    operation.propertyLabel = 'redirect'
  } else if (path === '/type') {
    operation.propertyLabel = 'type'
  }

  if (operation.filter && user) {
    const { acct } = user
    operation.filterPathname = `/users/${acct}/contributions?filter=${operation.filter}`
  }
}

function findPatchType (patch: SerializedPatch) {
  const { versionNumber, operations } = patch
  if (versionNumber === 1) return 'creation'

  const firstOp = operations[0]
  if (firstOp.path === '/redirect') return 'redirect'
  if (firstOp.path === '/type') {
    if ('value' in firstOp && firstOp.value === 'removed:placeholder') return 'deletion'
  }

  const operationsTypes = operations.map(property('op'))
  if (all(operationsTypes, isOpType('add'))) {
    return 'add'
  } else if (all(operationsTypes, isOpType('replace'))) {
    return 'add'
  } else if (all(operationsTypes, isOpType('remove'))) {
    return 'remove'
  } else {
    return 'update'
  }
}

function setOperationsSummaryData (patch) {
  const { patchType, operations } = patch
  const nonTestOps = operations.filter(op => op.type !== 'test')

  if (nonTestOps.length === 1) {
    if (patchType === 'add') {
      const operation = nonTestOps[0]
      let { property, value, propertyLabel } = operation
      if (!propertyLabel) propertyLabel = getPropertyLabel(property)
      patch.summary = { property, propertyLabel, added: value }
    } else if (patchType === 'remove') {
      const operation = nonTestOps[0]
      let { property, value, propertyLabel } = operation
      if (!propertyLabel) propertyLabel = getPropertyLabel(property)
      patch.summary = { property, propertyLabel, removed: value }
    } else if (patchType === 'update') {
      const addOperation = nonTestOps[0]
      let { property, value: added, propertyLabel } = addOperation
      const removeOperation = operations[1]
      const { value: removed } = removeOperation
      if (!propertyLabel) propertyLabel = getPropertyLabel(property)
      patch.summary = { property, propertyLabel, added, removed }
    }
  } else {
    const touchedProperties = uniq(compact(pluck(nonTestOps, 'property')))
      .map(property => `${getPropertyLabel(property)} (${property})`)
      .join('\n')
    patch.summary = { touchedProperties }
  }

  if (patch.summary) patch.summary.operationsCount = nonTestOps.length
}

const isOpType = type => opType => opType === type

const getPropertyLabel = property => i18n(unprefixify(property))
