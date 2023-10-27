import Handlebars from 'handlebars/runtime'
import blocks from './blocks.js'
import misc from './misc.js'
import utils from './utils.js'
import claims from './claims.js'
import { userContent } from './user_content.js'
import * as icons from './icons.js'
import images from './images.js'
import linkify from './linkify.js'

const API = Object.assign({ linkify, userContent }, blocks, misc, utils, claims, icons, images)

for (const name in API) {
  const fn = API[name]
  // Registering partials using the code here
  // https://github.com/brunch/handlebars-brunch/issues/10#issuecomment-38155730
  Handlebars.registerHelper(name, fn.bind(API))

  // Partials are registered by https://github.com/inventaire/parcel-plugin-handlebars-precompile/blob/master/handlebars-asset.js
  // allowing to create new partials without having to explictly register them here
}
