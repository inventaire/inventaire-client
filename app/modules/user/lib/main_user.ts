import cookie_ from 'js-cookie'
import { writable } from 'svelte/store'
import { API } from '#app/api/api'
import { getEndpointBase } from '#app/api/endpoint'
import app from '#app/app'
import type { UserLang } from '#app/lib/active_languages'
import log_ from '#app/lib/loggers'
import preq from '#app/lib/preq'
import { getQuerystringParameter } from '#app/lib/querystring_helpers'
import { parseBooleanString } from '#app/lib/utils'
import { commands } from '#app/radio'
import type { OwnerSafeUser } from '#server/controllers/user/lib/authorized_user_data_pickers'
import type { DeletedUser } from '#server/types/user'
import { notificationsList } from '#settings/lib/notifications_settings_list'
import { serializeUser, type SerializedUser } from '#users/lib/users'
import { initI18n, polyglot } from './i18n'
import { solveLang } from './solve_lang'

const apiUser = getEndpointBase('user')
// the cookie is deleted on logout
const loggedIn = parseBooleanString(cookie_.get('loggedIn'))

interface SerializedMainUserExtras {
  lang: UserLang
  loggedIn: boolean
  hasAdminAccess: boolean
  hasDataadminAccess: boolean
}

export type SerializedLoggedInMainUser = OwnerSafeUser & SerializedUser & SerializedMainUserExtras

export type SerializedNotLoggedInMainUser = {
  loggedIn: false
  hasAdminAccess: false
  hasDataadminAccess: false
  lang: UserLang
  _id: undefined
  username: undefined
  position: undefined
  acct: undefined
}

export let mainUser = {
  loggedIn,
  hasAdminAccess: false,
  hasDataadminAccess: false,
  lang: solveLang(),
} as (SerializedNotLoggedInMainUser | SerializedLoggedInMainUser)

export const mainUserStore = writable(mainUser)

export async function initMainUser () {
  if (loggedIn) {
    try {
      const user = (await preq.get(apiUser)) as (OwnerSafeUser | DeletedUser)
      if (user.type === 'deleted') return commands.execute('logout')
      // Initialize app.user so serializeUser can use it
      // @ts-expect-error
      app.user = user
      // @ts-expect-error
      app.user = mainUser = serializeMainUser(serializeUser(user))
      mainUserStore.set(mainUser)
    } catch (err) {
      // Known cases of session errors:
      // - when the server secret is changed
      // - when the current session user was deleted but the cookies weren't removed
      //   (possibly because the deletion was done from another browser or even another device)
      console.error('resetSession', err)
      commands.execute('logout', '/login')
    }
  }
  // Do not wait for i18n initialization to call 'waiter:resolve', 'user'
  initI18n(mainUser.lang).catch(log_.Error('i18n initialize error'))
  commands.execute('waiter:resolve', 'user')
}

function serializeMainUser (user: OwnerSafeUser & SerializedUser & Partial<SerializedMainUserExtras>) {
  user.loggedIn = loggedIn
  user.settings = setDefaultSettings(user)
  user.summaryPeriodicity = user.summaryPeriodicity || 20
  user.customProperties = user.customProperties || []
  user.lang = solveLang(user.language)
  const { accessLevels } = user
  user.hasAdminAccess = accessLevels.includes('admin')
  user.hasDataadminAccess = accessLevels.includes('dataadmin')
  return user as SerializedLoggedInMainUser
}

function setDefaultSettings (user: OwnerSafeUser & SerializedUser) {
  const { settings } = user
  const { notifications = {} } = settings
  settings.notifications = setDefaultNotificationsSettings(notifications)
  settings.contributions ??= { anonymize: true }
  return settings
}

function setDefaultNotificationsSettings (notifications: OwnerSafeUser['settings']['notifications']) {
  for (const notif of notificationsList) {
    notifications[notif] = notifications[notif] !== false
  }
  return notifications
}

export async function updateUser (attribute: string, value: unknown) {
  const currentValue = mainUser[attribute]
  try {
    mainUser[attribute] = value
    mainUserStore.set(mainUser)
    if (loggedIn) await preq.put(API.user, { attribute, value })
    if (attribute in afterUserUpdateHooks) {
      afterUserUpdateHooks[attribute]()
      mainUserStore.set(mainUser)
    }
  } catch (err) {
    // Rollback
    mainUser[attribute] = currentValue
    mainUserStore.set(mainUser)
    throw err
  }
}

const afterUserUpdateHooks = {
  language: onLanguageChange,
  username: reserialize,
  picture: reserialize,
}

function onLanguageChange () {
  if (polyglot == null) return

  const lang = 'language' in mainUser ? mainUser.language : null
  // @ts-expect-error `currentLocale` is missing in @types/node-polyglot
  if (lang === polyglot.currentLocale) return

  let reloadHref = window.location.href
  if (getQuerystringParameter('lang') != null) {
    // Prevent the querystring to override the language change
    // Can't just pass null to 'querystring:set' due to its limitations
    reloadHref = reloadHref
        .replace(/&?lang=\w+/, '')
        // If all there is left from the querystring is a '?', remove it
        .replace(/\?$/, '')
  }

  // The language setting is persisted as a cookie instead
  if (!loggedIn) cookie_.set('lang', lang)

  location.href = reloadHref
}

function reserialize () {
  // Coupled to serializeUser implementation, which skips serialization when 'pathname' already exists
  if ('pathname' in mainUser) delete mainUser.pathname
  // @ts-expect-error
  mainUser = serializeUser(mainUser)
}

export async function deleteMainUserAccount () {
  await preq.delete(apiUser)
  commands.execute('logout')
}

export function mainUserHasWikidataOauthTokens () {
  if (!('enabledOAuth' in mainUser)) return false
  const { enabledOAuth } = mainUser
  return (enabledOAuth != null) && enabledOAuth.includes('wikidata')
}
