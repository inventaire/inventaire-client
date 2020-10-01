import entityDraftModel from 'modules/entities/lib/entity_draft_model'

export default function () {
  const existingOrdinals = this.worksWithOrdinal.map(model => model.get('ordinal'))
  if (this.partsNumber == null) { this.partsNumber = 0 }
  const lastOrdinal = _.last(existingOrdinals)
  const end = _.max([ this.partsNumber, lastOrdinal ])
  if (end < 1) { return }
  const newPlaceholders = []
  for (let i = 1, end1 = end, asc = end1 >= 1; asc ? i <= end1 : i >= end1; asc ? i++ : i--) {
    if (!existingOrdinals.includes(i)) { newPlaceholders.push(getPlaceholder.call(this, i)) }
  }
  return this.worksWithOrdinal.add(newPlaceholders)
};

const getPlaceholder = function (index) {
  const serieUri = this.model.get('uri')
  const label = getPlaceholderTitle.call(this, index)
  const claims = {
    'wdt:P179': [ serieUri ],
    'wdt:P1545': [ `${index}` ]
  }
  const model = entityDraftModel.create({ type: 'work', label, claims })
  model.set('ordinal', index)
  model.set('isPlaceholder', true)
  return model
}

const getPlaceholderTitle = function (index) {
  const serieLabel = this.model.get('label')
  return this.titlePattern
  .replace(this.titleKey, serieLabel)
  .replace(this.numberKey, index)
}
