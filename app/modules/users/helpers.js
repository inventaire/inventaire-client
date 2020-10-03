import { isModel, isUserId } from 'lib/boolean_tests'

import { forceArray } from 'lib/utils'
import error_ from 'lib/error'
import usersData from './users_data'

export default function (app) {
  const sync = {
    getUserModelFromUserId (id) {
      if (id === app.user.id) { return app.user }

      const userModel = app.users.byId(id)
      if (userModel != null) {
        return userModel
      } else { }
    }
  }

  const async = {
    getUserModel (id, refresh) {
      if (id === app.user.id) { return Promise.resolve(app.user) }

      const model = app.users.byId(id)
      if ((model != null) && !refresh) {
        return Promise.resolve(model)
      } else {
        return usersData.get(id, 'collection')
        .then(addUser)
      }
    },

    getUsersModels (ids) {
      const foundUsersModels = []
      const missingUsersIds = []
      for (const id of ids) {
        const userModel = app.request('get:userModel:from:userId', id)
        if (userModel != null) {
          foundUsersModels.push(userModel)
        } else { missingUsersIds.push(id) }
      }

      if (missingUsersIds.length === 0) {
        return Promise.resolve(foundUsersModels)
      } else {
        return usersData.get(missingUsersIds, 'collection')
        .then(addUsers)
        .then(newUsersModels => foundUsersModels.concat(newUsersModels))
      }
    },

    resolveToUserModel (user) {
      // 'user' is either the user model, a user id, or a username
      let promise
      if (isModel(user)) {
        if (user.get('username') != null) {
          return Promise.resolve(user)
        } else { throw error_.new('not a user model', 500, { user }) }
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
        } else { throw error_.new('user model not found', 404, user) }
      })
    },

    getUserIdFromUsername (username) {
      return getUserModelFromUsername(username)
      .then(userModel => userModel.get('_id'))
    }
  }

  const getUserModelFromUsername = function (username) {
    username = username.toLowerCase()
    if (app.user.loggedIn && (username === app.user.get('username').toLowerCase())) {
      return Promise.resolve(app.user)
    }

    const userModel = app.users.find(model => model.get('username').toLowerCase() === username.toLowerCase())

    if (userModel != null) { return Promise.resolve(userModel) }

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

  const { searchByText } = require('./lib/search')(app)

  app.reqres.setHandlers({
    'get:user:model': async.getUserModel,
    'get:users:models': async.getUsersModels,
    'resolve:to:userModel': async.resolveToUserModel,
    'get:userModel:from:userId': sync.getUserModelFromUserId,
    'get:userId:from:username': async.getUserIdFromUsername,
    'users:search': searchByText,
    'user:add': addUser
  })

  app.commands.setHandlers({ 'users:add': addUsers })
};

const isntMainUser = user => user._id !== app.user.id
