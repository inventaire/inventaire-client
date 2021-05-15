import auth from './auth'
import data from './data'
import endpoint from './endpoint'
import entities from './entities'
import feeds from './feeds'
import groups from './groups'
import images from './images'
import img from './img'
import invitations from './invitations'
import items from './items'
import search from './search'
import shelves from './shelves'
import tasks from './tasks'
import users from './users'

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
