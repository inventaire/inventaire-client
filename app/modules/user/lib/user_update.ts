import { Updater } from '#lib/model_update'

export default function (app) {
  const userUpdater = Updater({
    endpoint: app.API.user,
    uniqueModel: app.user,
  })

  app.reqres.setHandlers({ 'user:update': userUpdater })
}
