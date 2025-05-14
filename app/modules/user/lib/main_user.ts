import cookie_ from 'js-cookie'
import { writable } from 'svelte/store'
import { API } from '#app/api/api'
import { getEndpointBase } from '#app/api/endpoint'
import type { UserLang } from '#app/lib/active_languages'
import log_ from '#app/lib/loggers'
import preq from '#app/lib/preq'
import { getQuerystringParameter } from '#app/lib/querystring_helpers'
import { parseBooleanString, setDeepAttribute } from '#app/lib/utils'
import { commands } from '#app/radio'
import type { OwnerSafeUser } from '#server/controllers/user/lib/authorized_user_data_pickers'
import type { DeletedUser } from '#server/types/user'
import { notificationsList } from '#settings/lib/notifications_settings_list'
import { serializeUser, type SerializedUser } from '#users/lib/users'
import { initI18n, polyglot } from './i18n'
import { solveLang } from './solve_lang'

const apiUser = getEndpointBase('user')
// the cookie is deleted on logout
export const loggedIn = parseBooleanString(cookie_.get('loggedIn'))

interface SerializedMainUserExtras {
  lang: UserLang
  loggedIn: boolean
  hasAdminAccess: boolean
  hasDataadminAccess: boolean
}

export type SerializedMainUser = (OwnerSafeUser & SerializedUser & SerializedMainUserExtras)

export let mainUser: SerializedMainUser

if (loggedIn) {
  try {
    const user = (await preq.get(apiUser)) as (OwnerSafeUser | DeletedUser)
    if (user.type === 'deleted') {
      commands.execute('logout')
    } else {
      // @ts-expect-error
      mainUser = serializeMainUser(serializeUser(user)) as SerializedMainUser
      setTimeout(() => {
        // Reserialize as serializeUser will not have been able to access mainUser?._id on the call above
        // @ts-expect-error
        mainUser = serializeMainUser(serializeUser(user)) as SerializedMainUser
      }, 0)
    }
  } catch (err) {
    // Known cases of session errors:
    // - when the server secret is changed
    // - when the current session user was deleted but the cookies weren't removed
    //   (possibly because the deletion was done from another browser or even another device)
    console.error('resetSession', err)
    commands.execute('logout', '/login')
  }
}

initI18n(mainUser?.lang || solveLang()).catch(log_.Error('i18n initialize error'))

export const mainUserStore = writable(mainUser)

function serializeMainUser (user: OwnerSafeUser & SerializedUser & Partial<SerializedMainUserExtras>) {
  user.settings = setDefaultSettings(user)
  user.summaryPeriodicity = user.summaryPeriodicity || 20
  user.customProperties = user.customProperties || []
  user.lang = solveLang(user.language)
  const { accessLevels } = user
  user.hasAdminAccess = accessLevels.includes('admin')
  user.hasDataadminAccess = accessLevels.includes('dataadmin')
  return user
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
    mainUser = setDeepAttribute(mainUser, attribute, value)
    mainUserStore.set(mainUser)
    if (mainUser) await preq.put(API.user, { attribute, value })
    if (attribute in afterUserUpdateHooks) {
      afterUserUpdateHooks[attribute]()
      mainUserStore.set(mainUser)
    }
  } catch (err) {
    if (err.message !== 'already up-to-date') {
      // Rollback
      mainUser = setDeepAttribute(mainUser, attribute, currentValue)
      mainUserStore.set(mainUser)
      throw err
    }
  }
}

const afterUserUpdateHooks = {
  language: onLanguageChange,
  username: reserialize,
  picture: reserialize,
}

function onLanguageChange () {
  if (polyglot == null) return

  const lang = (mainUser && 'language' in mainUser) ? mainUser.language : null
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
  if (!mainUser) cookie_.set('lang', lang)

  location.href = reloadHref
}

function reserialize () {
  // Coupled to serializeUser implementation, which skips serialization when 'isMainUser' didn't change
  delete mainUser.isMainUser
  // @ts-expect-error
  mainUser = serializeMainUser(serializeUser(mainUser))
}

export async function deleteMainUserAccount () {
  await preq.delete(apiUser)
  commands.execute('logout')
}

export function mainUserHasWikidataOauthTokens () {
  if (!(mainUser && 'enabledOAuth' in mainUser)) return false
  const { enabledOAuth } = mainUser
  return (enabledOAuth != null) && enabledOAuth.includes('wikidata')
}

export function mainUserHasAdminAccess () {
  return mainUser?.hasAdminAccess === true
}

export function mainUserHasDataadminAccess () {
  return mainUser?.hasDataadminAccess === true
}

export function updateMainUserListingsCount (num: number) {
  mainUser.listingsCount += num
  mainUserStore.set(mainUser)
}

export function updateMainUserShelvesCount (num: number) {
  mainUser.shelvesCount += num
  mainUserStore.set(mainUser)
}
