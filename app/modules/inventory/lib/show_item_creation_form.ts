import app from '#app/app'
import type { SerializedEntity } from '#entities/lib/entities'

interface ShowItemCreationFormParams {
  entity: SerializedEntity
}

export async function showItemCreationForm (params: ShowItemCreationFormParams) {
  const { entity } = params
  if (entity == null) throw new Error('missing entity')

  const { type } = entity
  const { uri } = entity
  if (type == null) throw new Error('missing entity type')

  const pathname = entity.pathname + '/add'
  if (!app.request('require:loggedIn', pathname)) return

  // It is not possible anymore to create items from works
  if (type === 'work') return app.execute('show:entity', uri)

  // Close the modal in case it was opened by showEditionPicker
  app.execute('modal:close')

  if (type !== 'edition') throw new Error(`invalid entity type: ${type}`)

  const { default: ItemCreationForm } = await import('#inventory/components/item_creation_form.svelte')
  app.layout.showChildComponent('main', ItemCreationForm, {
    props: {
      entity,
    },
  })
  app.navigate(pathname)
}
