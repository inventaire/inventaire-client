import auth from './auth.js'
import data from './data.js'
import endpoint from './endpoint.js'
import entities from './entities.js'
import feeds from './feeds.js'
import groups from './groups.js'
import images from './images.js'
import img from './img.js'
import invitations from './invitations.js'
import items from './items.js'
import transactions from './transactions.js'
import listings from './listings.js'
import oauth from './oauth.js'
import search from './search.js'
import shelves from './shelves.js'
import tasks from './tasks.js'
import users from './users.js'
import { i18nContentHash } from '#assets/js/build_metadata'

export const API = {
  // /api endpoints
  auth,
  config: endpoint('config', true),
  data,
  entities,
  feedback: endpoint('feedback', true),
  feeds,
  groups,
  i18n: endpoint('i18n', true),
  images,
  invitations,
  items,
  listings,
  notifications: endpoint('notifications', true),
  oauth,
  relations: endpoint('relations', true),
  search,
  shelves,
  tasks,
  tests: endpoint('tests', true),
  transactions,
  user: endpoint('user', true),
  users,

  // /public endpoints
  i18nStrings: lang => `/public/i18n/${lang}.json${getBuster()}`,
  json: filename => `/public/json/${filename}.json${getBuster()}`,

  // /img: endpoint serving images, handled by Nginx in production
  // thus not behing the /api root
  img,
}

const getBuster = () => {
  if (window.env === 'dev') return `?${Date.now()}`
  else return `?${i18nContentHash}`
}
