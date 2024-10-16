import { config } from '#app/config'
import { isNonEmptyArray } from '#app/lib/boolean_tests'
import { i18n } from '#app/modules/user/lib/i18n'
import { newError, serverReportError } from './error'

let initialized = false
let suspectKeywordsPattern

async function initSuspectKeywordsPattern () {
  if (!initialized) {
    if (isNonEmptyArray(config.spam?.suspectKeywords)) {
      const { suspectKeywords } = config.spam
      suspectKeywordsPattern = new RegExp(`(${suspectKeywords.join('|')})`, 'i')
    }
  }
  initialized = true
}

async function looksLikeSpam (text: string) {
  await initSuspectKeywordsPattern()
  return suspectKeywordsPattern?.test(text) && urlPattern.test(text)
}

const urlPattern = /(http|www\.|\w+\.\w+\/)/i

export async function checkSpamContent (text: string) {
  if (await looksLikeSpam(text)) {
    serverReportError('possible spam attempt', { type: 'spam', text }, 598)
    throw newError(i18n('This looks like spam'))
  }
}
