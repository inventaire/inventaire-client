import { config } from '#app/config'
import { isNonEmptyArray } from '#app/lib/boolean_tests'

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

export async function looksLikeSpam (str) {
  await initSuspectKeywordsPattern()
  return suspectKeywordsPattern?.test(str) && urlPattern.test(str)
}

const urlPattern = /(http|www\.|\w+\.\w+\/)/i
