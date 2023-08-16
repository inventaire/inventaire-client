import preq from '#lib/preq'
import { unprefixify } from '#lib/wikimedia/wikidata'
import { i18n } from '#user/lib/i18n'
import { serializeUser } from '#users/lib/users'
import { getUsersByIds } from '#users/users_data'
import { pluck } from 'underscore'

export async function getEntityPatches (entityId) {
  const { patches } = await preq.get(app.API.entities.history(entityId))
  // Reversing to get the last patches first
  patches.reverse()
  return serializePatches(patches)
}

export async function serializePatches (patches) {
  const usersIds = pluck(patches, 'user')
  let usersByIds = await getUsersByIds(usersIds)
  Object.values(usersByIds).forEach(serializeUser)
  for (const patch of patches) {
    // TODO: remove once db migration is done
    patch.operations = patch.operations || patch.patch
    serializePatch(patch, usersByIds[patch.user])
  }
  return patches
}

function serializePatch (patch, user) {
  const { _id: patchId } = patch
  const entityId = patchId.split(':')[0]
  // The first version is an empty document with only the basic attributes:
  // doesn't really count as a version
  const versionNumber = parseInt(patchId.split(':')[1]) - 1
  Object.assign(patch, {
    entityId,
    invEntityUri: `inv:${entityId}`,
    versionNumber,
  })
  if (patch.user) {
    patch.user = user
  } else {
    patch.anonymized = true
  }
  mergeTestAndRemoveOperations(patch)
  setOperationsData(patch)
  patch.patchType = findPatchType(patch)
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

  for (const op of operations) {
    if (op.path === '/claims') {
      op.propertyLabel = 'claims'
    } else if (op.path === '/labels') {
      op.propertyLabel = 'labels'
    } else if (op.path.startsWith('/claims/')) {
      op.property = op.path
        .replace(/^\/claims\//, '')
        .replace(/\/\d+$/, '')
      op.propertyLabel = getPropertyLabel(op.property)
      op.filter = op.property
    } else if (op.path.startsWith('/labels/')) {
      const lang = _.last(op.path.split('/'))
      op.propertyLabel = `label ${lang}`
      op.filter = lang
    } else if (op.path.startsWith('/redirect')) {
      op.propertyLabel = 'redirect'
    }
    if (op.filter) {
      const { _id: userId } = user
      op.filterPathname = `/users/${userId}/contributions?filter=${op.filter}`
    }
  }
}

function findPatchType (patch) {
  const { versionNumber, operations } = patch
  if (versionNumber === 1) return 'creation'

  const firstOp = operations[0]
  if (firstOp.path === '/redirect') return 'redirect'
  if (firstOp.path === '/type') {
    if (firstOp.value === 'removed:placeholder') return 'deletion'
  }

  const operationsTypes = operations.map(_.property('op'))
  if (_.all(operationsTypes, isOpType('add'))) {
    return 'add'
  } else if (_.all(operationsTypes, isOpType('replace'))) {
    return 'add'
  } else if (_.all(operationsTypes, isOpType('remove'))) {
    return 'remove'
  } else {
    return 'update'
  }
}

function setOperationsSummaryData (patch) {
  const { patchType, operations } = patch

  if (patchType === 'add') {
    const operation = operations[0]
    let { property, value, propertyLabel } = operation
    if (!propertyLabel) propertyLabel = getPropertyLabel(property)
    patch.summary = { property, propertyLabel, added: value }
  } else if (patchType === 'remove') {
    const operation = operations[0]
    let { property, value, propertyLabel } = operation
    if (!propertyLabel) propertyLabel = getPropertyLabel(property)
    patch.summary = { property, propertyLabel, removed: value }
  } else if (patchType === 'update') {
    const addOperation = operations[0]
    let { property, value: added, propertyLabel } = addOperation
    const removeOperation = operations[1]
    const { value: removed } = removeOperation
    if (!propertyLabel) propertyLabel = getPropertyLabel(property)
    patch.summary = { property, propertyLabel, added, removed }
  }
}

const isOpType = type => opType => opType === type

const getPropertyLabel = property => i18n(unprefixify(property))
