import { API } from '#app/api/api'
import { Updater } from '#app/lib/model_update'

export default function (app) {
  const userUpdater = Updater({
    endpoint: API.user,
    uniqueModel: app.user,
  })

  app.reqres.setHandlers({ 'user:update': userUpdater })
}
