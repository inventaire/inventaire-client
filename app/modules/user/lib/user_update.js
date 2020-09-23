/* eslint-disable
    import/no-duplicates,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import { Updater } from 'lib/model_update'

export default function (app) {
  const userUpdater = Updater({
    endpoint: app.API.user,
    uniqueModel: app.user
  })

  return app.reqres.setHandlers({ 'user:update': userUpdater })
};
