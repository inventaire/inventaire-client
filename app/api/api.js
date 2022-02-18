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
import oauth from './oauth.js'
import search from './search.js'
import shelves from './shelves.js'
import tasks from './tasks.js'
import users from './users.js'

export default {
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
  notifications: endpoint('notifications', true),
  oauth,
  relations: endpoint('relations', true),
  search,
  shelves,
  tasks,
  tests: endpoint('tests', true),
  transactions: endpoint('transactions', true),
  user: endpoint('user', true),
  users,

  // /public endpoints
  i18nStrings: lang => `/public/i18n/${lang}.json${getBuster()}`,
  json: filename => `/public/json/${filename}.json${getBuster()}`,

  // /img: endpoint serving images, handled by Nginx in production
  // thus not behing the /api root
  img,
}

// Hacky way to never accept cached version in development,
// while, in production, 'git-digest-brunch' will take care of
// replacing DIGEST with the last git commit hash
// (the DIGEST keyword needs to be in a URL to be replaced)
const getBuster = () => {
  if (window.env === 'dev') return `?${Date.now()}`
  else return ''
}
