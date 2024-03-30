import Handlebars from 'handlebars/runtime.js'
import blocks from './blocks.ts'
import claims from './claims.ts'
import * as icons from './icons.ts'
import images from './images.ts'
import linkify from './linkify.ts'
import misc from './misc.ts'
import { userContent } from './user_content.ts'
import utils from './utils.ts'

const API = Object.assign({ linkify, userContent }, blocks, misc, utils, claims, icons, images)

for (const name in API) {
  const fn = API[name]
  // Registering partials using the code here
  // https://github.com/brunch/handlebars-brunch/issues/10#issuecomment-38155730
  // @ts-expect-error
  Handlebars.registerHelper(name, fn.bind(API))
}
