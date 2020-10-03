import Handlebars from 'handlebars'
import blocks from './blocks'
import misc from './misc'
import utils from './utils'
import partials from './partials'
import claims from './claims'
import userContent from './user_content'
import icons from './icons'
import images from './images'
import input from './input'
import linkify from './linkify'

const API = _.extend({ linkify }, blocks, misc, utils, partials, claims, userContent, icons, images, input)

for (const name in API) {
  const fn = API[name]
  // Registering partials using the code here
  // https://github.com/brunch/handlebars-brunch/issues/10#issuecomment-38155730
  Handlebars.registerHelper(name, fn.bind(API))
}
