import { i18n } from 'modules/user/lib/i18n'
import { unprefixify } from 'lib/wikimedia/wikidata'

export default Backbone.NestedModel.extend({
  initialize (attrs) {
    const entityId = attrs._id.split(':')[0]
    this.set('entityId', entityId)
    const invEntityUri = `inv:${entityId}`
    this.set('invEntityUri', invEntityUri)

    this.reqGrab('get:entity:model', invEntityUri, 'entity')
    if (attrs.user) this.reqGrab('get:user:model', attrs.user, 'user')
    else this.set('anonymized', true)

    const dbVersionNumber = parseInt(this.id.split(':')[1])
    // The first version is an empty document with only the basic attributes:
    // doesn't really count as a version
    this.set('versionNumber', dbVersionNumber - 1)

    this.mergeTestAndRemoveOperations()
    this.setOperationsData()
    this.set('patchType', this.findPatchType())
    this.setOperationsSummaryData()
  },

  mergeTestAndRemoveOperations () {
    let operations = this.get('patch')

    operations.forEach((operation, index) => {
      if (operation.op === 'remove') {
        const prevOperation = operations[index - 1]
        if ((prevOperation.op === 'test') && (prevOperation.path === operation.path)) {
          operation.value = prevOperation.value
        }
      }
    })

    // Filter-out test operations, as it's not a useful information
    operations = operations.filter(operation => operation.op !== 'test')
    this.set('operations', operations)
  },

  setOperationsData () {
    const operations = this.get('operations')

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
      } else if (op.path.startsWith('/labels/')) {
        const lang = _.last(op.path.split('/'))
        op.propertyLabel = `label ${lang}`
      } else if (op.path.startsWith('/redirect')) {
        op.propertyLabel = 'redirect'
      }
    }

    this.set('operations', operations)
  },

  findPatchType () {
    if (this.get('versionNumber') === 1) return 'creation'

    const operations = this.get('operations')
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
  },

  setOperationsSummaryData () {
    const patchType = this.get('patchType')
    const operations = this.get('operations')

    if (patchType === 'add') {
      const operation = operations[0]
      let { property, value, propertyLabel } = operation
      if (!propertyLabel) propertyLabel = getPropertyLabel(property)
      this.set('summary', { property, propertyLabel, added: value })
    } else if (patchType === 'remove') {
      const operation = operations[0]
      let { property, value, propertyLabel } = operation
      if (!propertyLabel) propertyLabel = getPropertyLabel(property)
      this.set('summary', { property, propertyLabel, removed: value })
    } else if (patchType === 'update') {
      const addOperation = operations[0]
      let { property, value: added, propertyLabel } = addOperation
      const removeOperation = operations[1]
      const { value: removed } = removeOperation
      if (!propertyLabel) propertyLabel = getPropertyLabel(property)
      this.set('summary', { property, propertyLabel, added, removed })
    }
  },

  serializeData () {
    const attrs = this.toJSON()
    // Grabed models might not have came back yet
    attrs.user = this.user?.serializeData()
    attrs.entity = this.entity?.toJSON()
    return attrs
  }
})

const isOpType = type => opType => opType === type

const getPropertyLabel = property => i18n(unprefixify(property))
