import __ from '../root'
import 'should'

global.location =
    { hostname: 'localhost' }
const _ = (global._ = require('./utils_builder'))
global.Handlebars = require('handlebars')

const helpers = __.require('lib', 'handlebars_helpers/misc')

describe('Handlebars helpers', () => {})
