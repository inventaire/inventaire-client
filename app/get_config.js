/* eslint-disable
    no-return-assign,
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
// Request configuration to the server and make it accessible at app.config
export default () => _.preq.get(app.API.config)
.then(config => app.config = config)
