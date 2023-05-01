import { isModel, isUserId } from '#lib/boolean_tests'
import { forceArray } from '#lib/utils'
import error_ from '#lib/error'
import usersData, { getUsersByIds } from './users_data.js'
import initSearch from './lib/search.js'
import { pick } from 'underscore'
import { serializeUser } from '#users/lib/users'

export default function (app) {
  const sync = {
    getUserModelFromUserId (id) {
      if (id === app.user.id) return app.user
      else return app.users.byId(id)
    }
  }

  const async = {
    async getUserModel (id, refresh) {
      if (id === app.user.id) return app.user

      const model = app.users.byId(id)
      if ((model != null) && !refresh) {
        return model
      } else {
        return usersData.get(id, 'collection')
        .then(addUser)
      }
    },

    async getUserData (id) {
      const userModel = await async.getUserModel(id)
      return userModel.toJSON()
    },

    async getUsersModels (ids) {
      const foundUsersModels = []
      const missingUsersIds = []
      for (const id of ids) {
        const userModel = app.request('get:userModel:from:userId', id)
        if (userModel != null) {
          foundUsersModels.push(userModel)
        } else {
          missingUsersIds.push(id)
        }
      }

      if (missingUsersIds.length === 0) {
        return foundUsersModels
      } else {
        return usersData.get(missingUsersIds, 'collection')
        .then(addUsers)
        .then(newUsersModels => foundUsersModels.concat(newUsersModels))
      }
    },

    async resolveToUserModel (user) {
      // 'user' is either the user model, a user id, or a username
      let promise
      if (isModel(user)) {
        if (user.get('username') != null) {
          return user
        } else {
          throw error_.new('not a user model', 500, { user })
        }
      }

      if (isUserId(user)) {
        const userId = user
        promise = app.request('get:user:model', userId)
      } else {
        const username = user
        promise = getUserModelFromUsername(username)
      }

      return promise
      .then(userModel => {
        if (userModel != null) {
          return userModel
        } else {
          throw error_.new('user model not found', 404, user)
        }
      })
    },

    async resolveToUser (user) {
      const userModel = await async.resolveToUserModel(user)
      return userModel.toJSON()
    },

    getUserIdFromUsername (username) {
      return getUserModelFromUsername(username)
      .then(userModel => userModel.get('_id'))
    }
  }

  const getUserModelFromUsername = async username => {
    username = username.toLowerCase()
    if (app.user.loggedIn && (username === app.user.get('username').toLowerCase())) {
      return app.user
    }

    const userModel = app.users.find(model => model.get('username').toLowerCase() === username)

    if (userModel != null) return userModel

    return usersData.byUsername(username)
    .then(addUser)
  }

  const addUsers = function (users) {
    users = forceArray(users).filter(isntMainUser)
    // Do not set { merge: true } as that could overwrite some attributes
    // set at initialization
    // Ex: if picture=null, setting merge=true would reset the default avatar to null
    // The cost is that we might miss some user doc updates
    return app.users.add(users)
  }

  const addUser = users => addUsers(users)[0]

  const { searchByText } = initSearch(app)

  app.reqres.setHandlers({
    'get:user:model': async.getUserModel,
    'get:user:data': async.getUserData,
    'get:users:models': async.getUsersModels,
    'resolve:to:userModel': async.resolveToUserModel,
    'resolve:to:user': async.resolveToUser,
    'get:userModel:from:userId': sync.getUserModelFromUserId,
    'get:userId:from:username': async.getUserIdFromUsername,
    'users:search': searchByText,
    'user:add': addUser
  })

  app.commands.setHandlers({
    'users:add': addUsers
  })
}

const isntMainUser = user => user._id !== app.user.id

// TODO: add mechanism to empty cache after a time of inactivity
// to not leak memory and keep long outdated data on very long sessions
// (i.e. people never closing their tabs)
const cachedSerializedUsers = {}

// TODO: handle special case of main user, for which we might have fresher data
export async function getCachedSerializedUsers (ids) {
  const missingUsersIds = ids.filter(isntCached)
  const foundUsersByIds = await getUsersByIds(missingUsersIds)
  addSerializedUsersToCache(foundUsersByIds)
  return Object.values(pick(cachedSerializedUsers, ids))
}

const isntCached = id => cachedSerializedUsers[id] == null

function addSerializedUsersToCache (usersByIds) {
  for (const user of Object.values(usersByIds)) {
    cachedSerializedUsers[user._id] = serializeUser(user)
  }
}
