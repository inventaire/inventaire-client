// A layout that shows entities in sub views according to the input it receives
// and let the user select those entities for merge

import mergeEntities from './editor/lib/merge_entities'

import forms_ from 'modules/general/lib/forms'
import error_ from 'lib/error'
import DeduplicateAuthors from './deduplicate_authors'
import DeduplicateWorks from './deduplicate_works'

export default Marionette.LayoutView.extend({
  id: 'deduplicateLayout',
  attributes: {
    // Allow the view to be focused by clicking on it, thus being able to listen
    // for keydown events
    tabindex: '0'
  },
  template: require('./templates/deduplicate_layout'),
  regions: {
    content: '.content'
  },

  ui: {
    nextButton: '.next'
  },

  behaviors: {
    AlertBox: {}
  },

  initialize () {
    this.mergedUris = []
    return this._lastMergeTimestamp = 0
  },

  onShow () {
    // Give focus to controls so that we can listen for keydown events
    // and that hitting tab gives focus to the filter input
    this.$el.find('.controls').focus()

    let { uris } = this.options
    if (!_.isNonEmptyArray(uris)) {
      uris = app.request('querystring:get', 'uris')?.split('|')
    }

    if (_.isNonEmptyArray(uris)) {
      return this.loadFromUris(uris)
    } else { return this.showDeduplicateAuthors(app.request('querystring:get', 'name')) }
  },

  loadFromUris (uris) {
    return app.request('get:entities:models', { uris })
    .then(_.Log('entities'))
    .then(entities => {
      // Guess type from first entity
      const { type } = entities[0]
      switch (type) {
      case 'human':
        if (entities.length === 1) { return this.showDeduplicateAuthorWorks(entities[0]) }
        break
      case 'work': return this.showDeduplicateWorks(entities); break
      }

      // If we haven't returned at this point, it is a non handled case
      return alert('case not handled yet')
    })
  },

  showDeduplicateAuthorWorks (author) {
    return author.fetchWorksData()
    .then(worksData => {
      // Ignoring series
      const uris = worksData.works.map(_.property('uri'))
      return app.request('get:entities:models', { uris })
      .then(this.showDeduplicateWorks.bind(this))
    })
  },

  showDeduplicateWorks (works) {
    works = works.filter(entity => entity.type === 'work')
    return this.content.show(new DeduplicateWorks({ works, mergedUris: this.mergedUris }))
  },

  showDeduplicateAuthors (name) {
    return this.content.show(new DeduplicateAuthors({ name, mergedUris: this.mergedUris }))
  },

  serializeData () { return { uris: this.uris } },

  events: {
    'click .workLi,.authorLayout': 'select',
    'click .merge': 'mergeSelected',
    'click .next': 'next',
    'keydown input[name="filter"]': 'lazyFilterByText',
    keydown: 'triggerActionByKey',
    'next:button:hide' () { return this.ui.nextButton.hide() },
    'next:button:show' () { return this.ui.nextButton.show() },
    'entity:select': 'selectFromUri'
  },

  select (e) {
    // Prevent selecting when the intent was clicking on a link
    if (e.target.tagName === 'A') { return }

    const $target = $(e.currentTarget)
    const uri = getTargetUri(e)
    const $currentlySelected = $('.selected-from, .selected-to')

    switch ($currentlySelected.length) {
    case 0: $target.addClass('selected-from'); break
    case 1:
      if ($target[0] !== $currentlySelected[0]) {
        if (getElementType($target[0]) === getElementType($currentlySelected[0])) {
          $target.addClass('selected-to')
        } else {
          $currentlySelected.removeClass('selected-from selected-to')
          $target.addClass('selected-from')
        }
      }
      break
    default:
      $currentlySelected.removeClass('selected-from selected-to')
      $target.addClass('selected-from')
    }

    // Prevent a click on a work to also trigger an event on the author
    return e.stopPropagation()
  },

  selectFromUri (e, data, bla) {
    const { uri, direction } = data
    const selectorClassName = `selected-${direction}`
    $(`.${selectorClassName}`).removeClass(selectorClassName)
    return $(`[data-uri='${uri}']`).addClass(selectorClassName)
  },

  mergeSelected () {
    // Prevent merging several times within half a second: it is probably a mistake
    // like the merge key being inadvertedly pressed several times
    if ((Date.now() - this._lastMergeTimestamp) < 500) { return }
    this._lastMergeTimestamp = Date.now()

    const fromUri = getElementUri($('.selected-from')[0])
    const toUri = getElementUri($('.selected-to')[0])

    if (fromUri == null) { return alert("no 'from' URI") }
    if (toUri == null) { return alert("no 'to' URI") }

    mergeEntities(fromUri, toUri)
    .catch(error_.Complete('.buttons-wrapper', false))
    .catch(forms_.catchAlert.bind(null, this))

    // Optimistic UI: do not wait for the server response to move on
    return this.afterMerge(fromUri)
  },

  afterMerge (fromUri) {
    hideMergedEntities()
    this.mergedUris.push(fromUri)
    $('.selected-from').removeClass('selected-from')
    $('.selected-to').removeClass('selected-to')
    this.content.currentView.onMerge?.()
    // If @_previousText was set, re-filter using it and the updated mergeUris list
    // otherwise just filter with the updated mergeUris list
    return this.setSubviewFilter(this._previousText)
  },

  lazyFilterByText (e) {
    if (!this._lazyFilterByText) { this._lazyFilterByText = _.debounce(this.filterByText.bind(this), 200) }
    this._lazyFilterByText(e)
    // Prevent the event to be propagated to the general 'keydown' event
    return e.stopPropagation()
  },

  filterByText (e) {
    const text = e.target.value
    if (text === this._previousText) { return }
    this._previousText = text
    return this.setSubviewFilter(text)
  },

  setSubviewFilter (text) {
    return this.content.currentView.setFilter(getFilter(text, this.mergedUris))
  },

  next () { return this.content.currentView.next?.() },

  triggerActionByKey (e) {
    switch (e.key) {
    case 'm': return this.mergeSelected()
    case 'n': return this.next()
    }
  }
})

const getElementUri = el => el?.attributes['data-uri'].value
const getTargetUri = e => getElementUri(e.currentTarget)
const getElementType = function (el) { if ($(el).hasClass('authorLayout')) { return 'author' } else { return 'work' } }

const hideMergedEntities = function () {
  const $from = $('.selected-from')
  if ($from.hasClass('workLi')) {
    const $author = $from.parents('.authorLayout')
    // If it was the last work, hide the whole author as it should have been turned
    // into a redirection
    if ($author.find('.workLi').length === 1) {
      return $author.hide()
    } else { return $from.hide() }
  } else if ($from.hasClass('authorLayout')) {
    return $from.hide()
  }
}

const getFilter = function (text, mergedUris) {
  if (_.isNonEmptyString(text)) {
    const re = new RegExp(text, 'i')
    return function (model) {
      let needle
      return anyLabelMatch(model, re) && (needle = model.get('uri'), !mergedUris.includes(needle))
    }
  } else {
    return function (model) {
      let needle
      return (needle = model.get('uri'), !mergedUris.includes(needle))
    }
  }
}

const anyLabelMatch = function (model, re) {
  const labels = _.values(model.get('labels'))
  return _.any(labels, label => label.match(re))
}
