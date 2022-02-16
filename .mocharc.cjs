// Use Mocha config file https://mochajs.org/#configuring-mocha-nodejs
// to mock global variables required to run the tests

global.window = {}
global._ = require('underscore')
