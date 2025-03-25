import { pick } from 'underscore'
import app from '#app/app'
import { isModel, isUserId } from '#app/lib/boolean_tests'
import { newError } from '#app/lib/error'
import { forceArray, objectEntries, objectValues } from '#app/lib/utils'
import type { UserId } from '#server/types/user'
import { serializeUser, type ServerUser } from '#users/lib/users'
import usersData, { getUserByUsername, getUsersByIds } from './users_data.ts'

export default function (app) {
  const sync = {
    getUserModelFromUserId (id) {
      if (id === app.user.id) return app.user
      else return app.users.byId(id)
    },
  }

  const async = {
    async getUserModel (id, refresh?: boolean) {
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
          throw newError('not a user model', 500, { user })
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
          throw newError('user model not found', 404, user)
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
    },
  }

  const getUserModelFromUsername = async username => {
    username = username.toLowerCase()
    if (app.user.loggedIn && (username === app.user.username.toLowerCase())) {
      return app.user
    }

    const userModel = app.users.find(model => model.get('username').toLowerCase() === username)

    if (userModel != null) return userModel

    return getUserByUsername(username)
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

  app.reqres.setHandlers({
    'get:user:model': async.getUserModel,
    'get:users:models': async.getUsersModels,
    'resolve:to:user': async.resolveToUser,
    'get:userModel:from:userId': sync.getUserModelFromUserId,
    'get:userId:from:username': async.getUserIdFromUsername,
  })

  app.commands.setHandlers({
    'users:add': addUsers,
  })
}

const isntMainUser = user => user._id !== app.user.id

// TODO: add mechanism to empty cache after a time of inactivity
// to not leak memory and keep long outdated data on very long sessions
// (i.e. people never closing their tabs)
const cachedSerializedUsers = {}

// TODO: handle special case of main user, for which we might have fresher data
export async function getCachedSerializedUsers (ids: UserId[]) {
  const missingUsersIds = ids.filter(isntCached)
  // TODO: cache promises instead, to prevent fetching several times the same user in parallel
  const foundUsersByIds = await getUsersByIds(missingUsersIds)
  addSerializedUsersToCache(foundUsersByIds)
  return objectValues(pick(cachedSerializedUsers, ids))
}

const isntCached = id => cachedSerializedUsers[id] == null

function addSerializedUsersToCache (usersByIds: Record<UserId, ServerUser>) {
  for (const [ userId, user ] of objectEntries(usersByIds)) {
    cachedSerializedUsers[userId] = serializeUser(user)
  }
}

export async function getCachedSerializedUser (id: UserId) {
  const [ user ] = await getCachedSerializedUsers([ id ])
  return user
}
