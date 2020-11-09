import { i18n } from 'modules/user/lib/i18n'

// Display a tip when a work label or an edition title contains the label of their serie
// to invite to remove the serie label part
export function initWorkLabelsTip (work) { return setWorkAndSerieData.call(this, work) }

export async function initEditionTitleTip (edition, property) {
  if (property !== 'wdt:P1476') return
  // Only support cases where there is only 1 known work to keep things simple for now
  if (edition.get('claims.wdt:P629')?.length !== 1) return

  await edition.waitForWorks
  const editionLang = this.model.entity.get('originalLang')
  const work = edition.works[0]
  return setWorkAndSerieData.call(this, work, editionLang)
}

export function tipOnKeyup (e) {
  displayTipIfMatch.call(this, e.target.value)
}

export function tipOnRender (e) {
  displayTipIfMatch.call(this, this.ui.input.val())
}

const displayTipIfMatch = function (value) {
  if ((this._serieLabels == null) || !this.editMode) return

  const matchingSerieLabel = findMatchingSerieLabel(value, this._serieLabels)

  if (matchingSerieLabel != null) {
    showSerieLabelTip.call(this, matchingSerieLabel)
  } else {
    hideSerieLabelTip.call(this)
  }
}

const volumePattern = /\s*(v|vol|volume|t|tome)?\.?\s*(\d+)?$/

// Display the tip if the serie label is used in addition to another title.
// If it's just the serie label, plus possibly a volume number, the tip isn't helpful
const findMatchingSerieLabel = function (value, serieLabels) {
  value = value
    .toLowerCase()
    // Ignore volume information to determine if there is a match with the serie label
    .replace(volumePattern, '')
    .trim()

  for (const label of serieLabels) {
    // Start with the serie label, followed by a separator
    // and some title of at least 5 characters
    const re = new RegExp(`^${label}\\s?(:|-|,).{5}`, 'i')
    if (re.test(value)) { return label }
  }
}

const showSerieLabelTip = function (matchingSerieLabel) {
  if (!this.editMode) return
  let tip = i18n('title_matches_serie_label_tip', { pathname: this._serieEditorPathname })
  const serieHref = `href="${this._serieEditorPathname}"`
  tip = tip.replace(serieHref, `${serieHref} title="${matchingSerieLabel}"`)
  this.ui.tip.html(tip)
  this.ui.tip.fadeIn()
}

const hideSerieLabelTip = function () {
  if (this.editMode) this.ui.tip.fadeOut()
}

const setWorkAndSerieData = async function (work, editionLang) {
  const seriesUris = work.get('claims.wdt:P179')
  // Only support cases where there is only 1 known serie to keep things simple for now
  if (seriesUris?.length !== 1) return

  const serie = await app.request('get:entity:model', seriesUris[0])
  const serieLang = serie.get('originalLang')
  const workLang = work.get('originalLang')
  const langs = _.uniq(_.compact([ app.user.lang, editionLang, workLang, serieLang ]))
  this._serieLabels = _.values(_.pick(serie.get('labels'), langs))
  this._serieEditorPathname = serie.get('edit')
}
