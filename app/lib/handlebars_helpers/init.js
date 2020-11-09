import Handlebars from 'handlebars/runtime'
import blocks from './blocks'
import misc from './misc'
import utils from './utils'
import claims from './claims'
import userContent from './user_content'
import * as icons from './icons'
import images from './images'
import input from './input'
import linkify from './linkify'

const API = _.extend({ linkify }, blocks, misc, utils, claims, userContent, icons, images, input)

for (const name in API) {
  const fn = API[name]
  // Registering partials using the code here
  // https://github.com/brunch/handlebars-brunch/issues/10#issuecomment-38155730
  Handlebars.registerHelper(name, fn.bind(API))

  // Partials are registered by https://github.com/inventaire/parcel-plugin-handlebars-precompile/blob/master/handlebars-asset.js
  // allowing to create new partials without having to explictly register them here
}
