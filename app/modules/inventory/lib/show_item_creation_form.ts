export default async params => {
  const { entity } = params
  if (entity == null) throw new Error('missing entity')

  const { type } = entity
  const uri = entity.get('uri')
  if (type == null) throw new Error('missing entity type')

  const pathname = entity.get('pathname') + '/add'
  if (!app.request('require:loggedIn', pathname)) return

  // It is not possible anymore to create items from works
  if (type === 'work') return app.execute('show:entity', uri)

  // Close the modal in case it was opened by showEditionPicker
  app.execute('modal:close')

  if (type !== 'edition') throw new Error(`invalid entity type: ${type}`)

  const { default: ItemCreationForm } = await import('#inventory/components/item_creation_form.svelte')
  app.layout.showChildComponent('main', ItemCreationForm, {
    props: {
      entity: entity.toJSON(),
    },
  })
  app.navigate(pathname)
}
