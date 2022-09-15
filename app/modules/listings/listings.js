import app from '#app/app'
import { getListingWithElementsById } from './lib/listings.js'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'lists(/)': 'showMainUserListings',
        'lists/(:id)(/)': 'showListing',
        'users/:username/lists(/)': 'showUserListings',
      }
    })

    new Router({ controller: API })

    app.commands.setHandlers({
      'show:main:user:listings': showMainUserListings,
    })
  },
}

async function showListing (id) {
  const { default: ListingLayout } = await import('./components/listing_layout.svelte')
  try {
    const { listing } = await getListingWithElementsById(id)
    app.layout.showChildComponent('main', ListingLayout, {
      props: { listing }
    })
  } catch (err) {
    app.execute('show:error', err)
  }
}

async function showUserListings (user) {
  try {
    const [ { default: UserListings }, userModel ] = await Promise.all([
      await import('./components/user_listings.svelte'),
      app.request('resolve:to:userModel', user),
    ])
    const username = userModel.get('username')
    app.layout.showChildComponent('main', UserListings, {
      props: {
        user: userModel.toJSON()
      }
    })
    app.navigate(`users/${username}/lists`)
  } catch (err) {
    app.execute('show:error', err)
  }
}

const showMainUserListings = () => showUserListings(app.user)

const API = {
  showListing,
  showUserListings,
  showMainUserListings
}
