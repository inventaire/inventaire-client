import { i18nContentHash } from '#assets/js/build_metadata'
import auth from './auth.ts'
import data from './data.ts'
import endpoint from './endpoint.ts'
import entities from './entities.ts'
import feeds from './feeds.ts'
import groups from './groups.ts'
import images from './images.ts'
import img from './img.ts'
import invitations from './invitations.ts'
import items from './items.ts'
import listings from './listings.ts'
import oauth from './oauth.ts'
import search from './search.ts'
import shelves from './shelves.ts'
import tasks from './tasks.ts'
import transactions from './transactions.ts'
import users from './users.ts'

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
  // @ts-expect-error TS2339: Property 'env' does not exist on type 'Window & typeof globalThis'.
  if (window.env === 'dev') return `?${Date.now()}`
  else return `?${i18nContentHash}`
}
