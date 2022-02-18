export default async params => {
  const { entity } = params
  if (entity == null) throw new Error('missing entity')

  const { type } = entity
  if (type == null) throw new Error('missing entity type')

  const pathname = entity.get('pathname') + '/add'
  if (!app.request('require:loggedIn', pathname)) return

  // It is not possible anymore to create items from works
  if (type === 'work') return showEditionPicker(entity)

  // Close the modal in case it was opened by showEditionPicker
  app.execute('modal:close')

  if (type !== 'edition') throw new Error(`invalid entity type: ${type}`)

  const { default: ItemCreationForm } = await import('../views/form/item_creation')
  app.layout.showChildView('main', new ItemCreationForm(params))
  app.navigate(pathname)
}

const showEditionPicker = async work => {
  const [ { default: EditionsList } ] = await Promise.all([
    import('#modules/entities/views/editions_list'),
    work.fetchSubEntities()
  ])
  app.layout.showChildView('modal', new EditionsList({
    collection: work.editions,
    work,
    header: 'select an edition'
  }))
  app.execute('modal:open', 'large')
}
