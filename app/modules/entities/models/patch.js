import { unprefixify } from 'lib/wikimedia/wikidata';

export default Backbone.NestedModel.extend({
  initialize(attrs){
    const entityId = attrs._id.split(':')[0];
    this.set('entityId', entityId);
    const invEntityUri = `inv:${entityId}`;
    this.set('invEntityUri', invEntityUri);

    this.reqGrab('get:entity:model', invEntityUri, 'entity');
    this.reqGrab('get:user:model', attrs.user, 'user');

    const dbVersionNumber = parseInt(this.id.split(':')[1]);
    // The first version is an empty document with only the basic attributes:
    // doesn't really count as a version
    this.set('versionNumber', dbVersionNumber - 1);

    this.mergeTestAndRemoveOperations();
    this.setOperationsData();
    this.set('patchType', this.findPatchType());
    return this.setOperationsSummaryData();
  },

  mergeTestAndRemoveOperations() {
    let operations = this.get('patch');

    operations.forEach(function(operation, index){
      if (operation.op === 'remove') {
        const prevOperation = operations[index - 1];
        if ((prevOperation.op === 'test') && (prevOperation.path === operation.path)) {
          return operation.value = prevOperation.value;
        }
      }
    });

    // Filter-out test operations, as it's not a useful information
    operations = operations.filter(operation => operation.op !== 'test');
    return this.set('operations', operations);
  },

  setOperationsData() {
    const operations = this.get('operations');

    for (let op of operations) {
      if (op.path === '/claims') {
        op.propertyLabel = 'claims';

      } else if (op.path === '/labels') {
        op.propertyLabel = 'labels';

      } else if (op.path.startsWith('/claims/')) {
        op.property = op.path
          .replace(/^\/claims\//, '')
          .replace(/\/\d+$/, '');
        op.propertyLabel = getPropertyLabel(op.property);

      } else if (op.path.startsWith('/labels/')) {
        const lang = _.last(op.path.split('/'));
        op.propertyLabel = `label ${lang}`;

      } else if (op.path.startsWith('/redirect')) {
        op.propertyLabel = 'redirect';
      }
    }

    return this.set('operations', operations);
  },

  findPatchType() {
    if (this.get('versionNumber') === 1) { return 'creation'; }

    const operations = this.get('operations');
    const firstOp = operations[0];
    if (firstOp.path === '/redirect') { return 'redirect'; }
    if (firstOp.path === '/type') {
      if (firstOp.value === 'removed:placeholder') { return 'deletion'; }
    }

    const operationsTypes = operations.map(_.property('op'));
    if (_.all(operationsTypes, isOpType('add'))) { return 'add';
    } else if (_.all(operationsTypes, isOpType('replace'))) { return 'add';
    } else if (_.all(operationsTypes, isOpType('remove'))) { return 'remove';
    } else { return 'update'; }
  },

  setOperationsSummaryData() {
    let added;
    const patchType = this.get('patchType');
    const operations = this.get('operations');

    switch (patchType) {
      case 'add':
        var operation = operations[0];
        var { property, value, propertyLabel } = operation;
        if (!propertyLabel) { propertyLabel = getPropertyLabel(property); }
        return this.set('summary', { property, propertyLabel, added: value });
      case 'remove':
        operation = operations[0];
        ({ property, value, propertyLabel } = operation);
        if (!propertyLabel) { propertyLabel = getPropertyLabel(property); }
        return this.set('summary', { property, propertyLabel, removed: value });
      case 'update':
        var addOperation = operations[0];
        ({ property, value:added, propertyLabel } = addOperation);
        var removeOperation = operations[1];
        var { value:removed } = removeOperation;
        if (!propertyLabel) { propertyLabel = getPropertyLabel(property); }
        return this.set('summary', { property, propertyLabel, added, removed });
    }
  },

  serializeData() {
    const attrs = this.toJSON();
    // Grabed models might not have came back yet
    attrs.user = this.user?.serializeData();
    attrs.entity = this.entity?.toJSON();
    return attrs;
  }
});

var isOpType = type => opType => opType === type;

var getPropertyLabel = property => _.i18n(unprefixify(property));
