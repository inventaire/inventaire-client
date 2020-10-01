import TypedEntityLayout from './typed_entity_layout'
import { startLoading } from 'modules/general/plugins/behaviors'
import EntitiesList from './entities_list'
import screen_ from 'lib/screen'

export default TypedEntityLayout.extend({
  template: require('./templates/author_layout'),
  Infobox: require('./author_infobox'),
  className () {
    // Default to wrapped mode in non standalone mode
    let secondClass = ''
    if (this.options.standalone) {
      secondClass = 'standalone'
    } else if (!this.options.noAuthorWrap) { secondClass = 'wrapped' }
    const prefix = this.model.get('prefix')
    return `authorLayout ${secondClass} entity-prefix-${prefix}`
  },

  attributes () {
    // Used by deduplicate_layout
    return { 'data-uri': this.model.get('uri') }
  },

  behaviors: {
    Loading: {}
  },

  regions: {
    infoboxRegion: '.authorInfobox',
    seriesRegion: '.series',
    worksRegion: '.works',
    articlesRegion: '.articles',
    mergeSuggestionsRegion: '.mergeSuggestions'
  },

  initialize () {
    TypedEntityLayout.prototype.initialize.call(this)
    // Trigger fetchWorks only once the author is in view
    return this.$el.once('inview', this.fetchWorks.bind(this))
  },

  events: {
    'click .unwrap': 'unwrap'
  },

  fetchWorks () {
    this.worksShouldBeShown = true
    // make sure refresh is a Boolean and not an object incidently passed
    const refresh = this.options.refresh === true

    return this.model.initAuthorWorks(refresh)
    .then(this.ifViewIsIntact('showWorks'))
    .catch(_.Error('author_layout fetchWorks err'))
  },

  onRender () {
    TypedEntityLayout.prototype.onRender.call(this)
    if (this.worksShouldBeShown) { return this.showWorks() }
  },

  showWorks () {
    startLoading.call(this, '.works')

    return this.model.waitForWorks
    .then(this._showWorks.bind(this))
  },

  _showWorks () {
    const { works, series, articles } = this.model.works
    const total = works.totalLength + series.totalLength + articles.totalLength

    // Always starting wrapped on small screens
    if (!screen_.isSmall(600) && (total > 0)) { this.unwrap() }

    const initialWorksListLength = this.standalone ? 10 : 5

    this.showWorkCollection('works', initialWorksListLength)

    const seriesCount = this.model.works.series.totalLength
    if ((seriesCount > 0) || this.standalone) {
      this.showWorkCollection('series', initialWorksListLength)
      // If the author has no series, move the series block down
      if (seriesCount === 0) { this.seriesRegion.$el.css('order', 2) }
    }

    if (this.model.works.articles.totalLength > 0) {
      return this.showWorkCollection('articles')
    }
  },

  unwrap () { return this.$el.removeClass('wrapped') },

  showWorkCollection (type, initialLength) {
    return this[`${type}Region`].show(new EntitiesList({
      parentModel: this.model,
      collection: this.model.works[type],
      title: type,
      type: dropThePlural(type),
      initialLength,
      showActions: this.options.showActions,
      wrapWorks: this.options.wrapWorks,
      addButtonLabel: addButtonLabelPerType[type]
    }))
  }
})

const addButtonLabelPerType = {
  works: 'add a work from this author',
  series: 'add a serie from this author'
}

const dropThePlural = type => type.replace(/s$/, '')
