import endpoint from './endpoint'
import auth from './auth'
import users from './users'
import groups from './groups'
import items from './items'
import entities from './entities'
import search from './search'
import data from './data'
import invitations from './invitations'
import tasks from './tasks'
import shelves from './shelves'
import images from './images'
import img from './img'
import feeds from './feeds'

export default {
  auth,
  users,
  groups,
  items,
  entities,
  search,
  data,
  invitations,
  tasks,
  shelves,
  transactions: endpoint('transactions', true),
  relations: endpoint('relations', true),
  user: endpoint('user', true),
  notifications: endpoint('notifications', true),
  feedback: endpoint('feedback', true),
  tests: endpoint('tests', true),
  i18n: endpoint('i18n', true),
  config: endpoint('config', true),

  // /api/images: API controllers handling images uploading, resizing, etc
  images,

  // /img: endpoint serving images, handled by Nginx in production
  // thus not behing the /api root
  img,

  feeds,
  i18nStrings: lang => `/public/i18n/${lang}.json?DIGEST${getBuster()}`,
  json: filename => `/public/json/${filename}.json?DIGEST${getBuster()}`
}

// Hacky way to never accept cached version in development,
// while, in production, 'git-digest-brunch' will take care of
// replacing DIGEST with the last git commit hash
// (the DIGEST keyword needs to be in a URL to be replaced)
const getBuster = () => {
  if (window.env === 'dev') return Date.now()
  else return ''
}
