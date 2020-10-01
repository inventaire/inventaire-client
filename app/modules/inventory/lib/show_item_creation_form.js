import ItemCreationForm from '../views/form/item_creation'
import EditionsList from 'modules/entities/views/editions_list'

export default function (params) {
  const { entity } = params
  if (entity == null) { throw new Error('missing entity') }

  const { type } = entity
  if (type == null) { throw new Error('missing entity type') }

  const pathname = entity.get('pathname') + '/add'
  if (!app.request('require:loggedIn', pathname)) return

  // It is not possible anymore to create items from works
  if (type === 'work') { return showEditionPicker(entity) }

  // Close the modal in case it was opened by showEditionPicker
  app.execute('modal:close')

  if (type !== 'edition') { throw new Error(`invalid entity type: ${type}`) }

  app.layout.main.show(new ItemCreationForm(params))
  return app.navigate(pathname)
};

const showEditionPicker = work => work.fetchSubEntities()
.then(() => {
  app.layout.modal.show(new EditionsList({
    collection: work.editions,
    work,
    header: 'select an edition'
  })
  )
  app.execute('modal:open', 'large')
})
