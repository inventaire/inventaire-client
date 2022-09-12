import app from '#app/app'
import { getListWithSelectionsById } from './lib/lists.js'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'lists(/)': 'showMainUserLists',
        'lists/(:id)(/)': 'showList',
        'users/:username/lists(/)': 'showUserLists',
      }
    })

    new Router({ controller: API })
  },
}

async function showList (id) {
  const { default: ListLayout } = await import('./components/list_layout.svelte')
  try {
    const { list, selections } = await getListWithSelectionsById(id)
    app.layout.showChildComponent('main', ListLayout, {
      props: { list, selections }
    })
  } catch (err) {
    app.execute('show:error', err)
  }
}

async function showUserLists (user) {
  try {
    const [ { default: UserLists }, userModel ] = await Promise.all([
      await import('./components/user_lists.svelte'),
      app.request('resolve:to:userModel', user),
    ])
    const username = userModel.get('username')
    app.layout.showChildComponent('main', UserLists, {
      props: {
        user: userModel.toJSON()
      }
    })
    app.navigate(`users/${username}/lists`)
  } catch (err) {
    app.execute('show:error', err)
  }
}

const showMainUserLists = () => showUserLists(app.user)

const API = {
  showList,
  showUserLists,
  showMainUserLists
}
