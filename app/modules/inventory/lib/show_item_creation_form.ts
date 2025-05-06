import app from '#app/app'
import { appLayout } from '#app/init_app_layout'
import { commands, reqres } from '#app/radio'
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
  if (!reqres.request('require:loggedIn', pathname)) return

  // It is not possible anymore to create items from works
  if (type === 'work') return commands.execute('show:entity', uri)

  // Close the modal in case it was opened by showEditionPicker
  commands.execute('modal:close')

  if (type !== 'edition') throw new Error(`invalid entity type: ${type}`)

  const { default: ItemCreationForm } = await import('#inventory/components/item_creation_form.svelte')
  appLayout.showChildComponent('main', ItemCreationForm, {
    props: {
      entity,
    },
  })
  app.navigate(pathname)
}
