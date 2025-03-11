<script lang="ts">
  // TODO:
  // - hint to input ISBNs directly, maybe in the alternatives sections
  // - add 'help': indexed wiki.inventaire.io entries to give results
  //   to searches such as 'FAQ' or 'help creating group'
  // - add 'place': search Wikidata for entities with coordinates (wdt:P625)
  //   and display a layout with users & groups nearby, as well as books with
  //   narrative location (wdt:P840), or authors born (wdt:P19)
  //   or dead (wdt:P20) nearby
  import { onDestroy } from 'svelte'
  import { debounce } from 'underscore'
  import app from '#app/app'
  import viewport from '#app/lib/components/actions/viewport'
  import Flash from '#app/lib/components/flash.svelte'
  import { screen } from '#app/lib/components/stores/screen'
  import { icon } from '#app/lib/icons'
  import { getActionKey } from '#app/lib/key_events'
  import { currentRoute } from '#app/lib/location'
  import { onChange } from '#app/lib/svelte/svelte'
  import { getEntityByUri } from '#app/modules/entities/lib/entities'
  import Spinner from '#components/spinner.svelte'
  import { searchByTypes } from '#entities/lib/search/search_by_types'
  import { wikidataSearch } from '#entities/lib/search/wikidata_search'
  import SearchAlternatives from '#search/components/search_alternatives.svelte'
  import SearchControls from '#search/components/search_controls.svelte'
  import SearchResult from '#search/components/search_result.svelte'
  import SearchShortcuts from '#search/components/search_shortcuts.svelte'
  import findUri from '#search/lib/find_uri'
  import { serializeResult, serializeSubject } from '#search/lib/search_results'
  import { getNextSection, getPrevSection, sectionsNames, typesBySection } from '#search/lib/search_sections'
  import type { EntityUri } from '#server/types/entity'
  import { i18n, I18n } from '#user/lib/i18n'

  let searchText = '', searchGroupEl, searchFieldEl, searchResultsEl, waiting, flash
  let results = []
  let searchOffset = 0
  let showSearchDropdown = false
  const searchBatchLength = 15
  let highlightedResultIndex = 0
  let showResults = false
  let lastSearchKey
  let showSearchControls
  let hasMore = false

  // In sync with limit parameter in `server/controllers/search/search.js`
  const resultsMaxLength = 100

  async function search () {
    const searchKey = `${selectedCategory}:${selectedSection}:${searchText}`
    hasMore = false
    flash = null
    if (searchKey === lastSearchKey) return
    lastSearchKey = searchKey
    results = []
    if (searchText.trim().length === 0) return

    showLiveSearch()

    try {
      waiting = getSearchResults(searchText)
      const res = await waiting
      if (searchKey === lastSearchKey) {
        results = res
        showResults = true
        highlightedResultIndex = 0
        searchOffset = 0
      }
    } catch (err) {
      flash = err
    }
  }

  $: if (searchText.trim().length === 0) showResults = false

  let uri
  async function getSearchResults (searchText: string) {
    uri = findUri(searchText)
    if (uri != null) {
      return getResultFromUri(uri)
    } else {
      return _search(searchText)
    }
  }

  async function _search (searchText: string) {
    const types = typesBySection[selectedCategory][selectedSection]
    // Subjects aren't indexed in the server ElasticSearch
    // as it's not a subset of Wikidata anymore: pretty much anything
    // on Wikidata can be considered a subject
    if (types === 'subjects') {
      const res = await wikidataSearch({
        search: searchText,
        limit: searchBatchLength,
        offset: searchOffset,
      })
      hasMore = res.continue != null && res.continue < resultsMaxLength

      return res.results.map(serializeSubject)
    } else {
      // Increasing search limit instead of offset, as search pages aren't stable:
      // results popularity might have change the results order between two requests,
      // thus the need to re-fetch from offset 0 but increasing the page length, and adding only
      // the results that weren't returned in the previous query, whatever there place
      // in the newly returned results
      const searchLimit = searchBatchLength + searchOffset
      const res = await searchByTypes({
        types,
        search: searchText,
        limit: searchLimit,
      })
      hasMore = res.continue != null && res.continue < resultsMaxLength

      return res.results
    }
  }

  // Use a large debounce delay to reduce queries to Elasticsearch
  const lazySearch = debounce(search, 1000)

  async function getResultFromUri (uri: EntityUri) {
    try {
      const entity = await getEntityByUri({ uri, autocreate: true })
      const result = serializeResult(entity)
      return [ result ]
    } catch (err) {
      if (err.message === 'entity_not_found') {
        return []
      } else {
        throw err
      }
    }
  }

  function onKeyDown (e) {
    const key = getActionKey(e)
    if (key === 'up') highlightPreviousResult()
    else if (key === 'down') highlightNextResult()
    if (neutralizedKeys.has(key)) e.preventDefault()
  }

  function onKeyUp (e) {
    const key = getActionKey(e)
    if (key === 'esc') hideLiveSearch()
    else if (key === 'enter') showCurrentlyHighlightedResult()
    else if (key === 'pageup') selectPrevSection()
    else if (key === 'pagedown') selectNextSection()
    else lazySearch()
    if (neutralizedKeys.has(key)) e.preventDefault()
  }

  function hideOnEsc (e) {
    const key = getActionKey(e)
    if (key === 'esc') hideLiveSearch()
  }

  const neutralizedKeys = new Set([ 'up', 'down', 'pageup', 'pagedown' ])

  function showLiveSearch () {
    showSearchDropdown = true
  }

  const initialRoute = currentRoute()
  function hideLiveSearch () {
    showSearchDropdown = false
    if (showFallbackLayout && initialRoute === currentRoute()) {
      showFallbackLayout()
    }
  }
  function hideAndResetLiveSearch () {
    searchText = ''
    hideLiveSearch()
  }

  const highlightPreviousResult = () => highlightedResultIndex = Math.max(highlightedResultIndex - 1, 0)
  const highlightNextResult = () => highlightedResultIndex = Math.min(highlightedResultIndex + 1, results.length - 1)
  function showCurrentlyHighlightedResult () {
    if (!searchResultsEl) return
    const highlightedResultEl = searchResultsEl.children[highlightedResultIndex]
    highlightedResultEl.querySelector('a').click()
  }

  function scrollDropdownIfNeeded () {
    if (!searchResultsEl) return
    const highlightedResultEl = searchResultsEl.children[highlightedResultIndex]
    highlightedResultEl.scrollIntoView({ block: 'end', inline: 'nearest', behavior: 'smooth' })
  }

  $: onChange(highlightedResultIndex, scrollDropdownIfNeeded)

  function onOutsideClick (e) {
    if (!searchGroupEl.contains(e.target)) {
      hideLiveSearch()
    }
  }

  let selectedCategory, selectedSection
  function selectPrevSection () {
    ;({ selectedCategory, selectedSection } = getPrevSection({ selectedCategory, selectedSection }))
  }
  function selectNextSection () {
    ;({ selectedCategory, selectedSection } = getNextSection({ selectedCategory, selectedSection }))
  }

  function onSectionChange () {
    if (!searchFieldEl) return
    searchFieldEl.focus()
    lazySearch()
  }

  async function searchMore () {
    try {
      searchOffset += searchBatchLength
      waiting = getSearchResults(searchText)
      const res = await waiting
      results = res
    } catch (err) {
      flash = err
    }
  }

  const lazySearchMore = debounce(searchMore, 500, true)

  let canSearchMore = true

  function resultsBottomEnteredViewport () {
    if (canSearchMore) {
      canSearchMore = false
      lazySearchMore()
    }
  }

  function resultsBottomLeftViewport () {
    canSearchMore = true
  }

  $: onChange(selectedCategory, selectedSection, onSectionChange)

  let showFallbackLayout
  function onSearchQuery ({ search: text, section, showFallbackLayout: fallback }) {
    searchText = text
    // Checking on sectionsNames.entity so that 'all' default to 'entity:all'
    // rather than 'social:all'
    selectedCategory = sectionsNames.entity.includes(section) ? 'entity' : 'social'
    selectedSection = section
    showFallbackLayout = fallback
    lazySearch()
  }

  app.vent.on('live:search:query', onSearchQuery)
  onDestroy(() => {
    app.vent.off('live:search:query', onSearchQuery)
  })
</script>

<svelte:body on:click={onOutsideClick} />

<div id="search-group" bind:this={searchGroupEl}>
  <input
    type="search"
    name="search"
    placeholder={i18n('Search by title, author, ISBN, series, publisher, collection…')}
    autocomplete="off"
    autocorrect="off"
    autocapitalize="off"
    aria-label="search"
    aria-autocomplete="list"
    aria-controls="live-search"
    bind:value={searchText}
    bind:this={searchFieldEl}
    on:focus={showLiveSearch}
    on:keydown={onKeyDown}
    on:keyup={onKeyUp}
  />

  {#if showSearchDropdown}
    <button
      id="close-search"
      title={I18n('close')}
      on:click={hideAndResetLiveSearch}
    >
      {@html icon('close')}
    </button>
    <div id="live-search">
      <SearchControls
        bind:showSearchControls
        bind:selectedCategory
        bind:selectedSection
        {uri}
        {results}
      />
      {#if showResults}
        {#if results.length > 0}
          <div class="search-results">
            <ul bind:this={searchResultsEl}>
              {#each results as result, index (result.id)}
                <SearchResult
                  {result}
                  highlighted={index === highlightedResultIndex}
                  on:resultSelected={hideLiveSearch}
                />
              {/each}
            </ul>
            {#if hasMore}
              <div
                class="loader"
                use:viewport
                on:enterViewport={resultsBottomEnteredViewport}
                on:leaveViewport={resultsBottomLeftViewport}
              >
                <Spinner center={true} />
              </div>
            {/if}
          </div>
        {:else if searchText.length > 0}
          {#await waiting}
            <div class="loader">
              <Spinner center={true} />
            </div>
          {:then}
            <p class="no-result">{i18n('no result')}</p>
          {/await}
        {/if}
      {:else}
        {#await waiting}
          <div class="loader">
            <Spinner center={true} />
          </div>
        {/await}
      {/if}
      {#if showSearchControls && uri == null}
        <SearchAlternatives
          {selectedCategory}
          {selectedSection}
          {searchText}
          on:closeLiveSearch={hideLiveSearch}
        />
      {/if}
      {#if $screen.isLargerThan('$small-screen')}
        <SearchShortcuts />
      {/if}
      <Flash state={flash} />
    </div>
    <div
      id="overlay"
      on:click={hideLiveSearch}
      on:keydown={hideOnEsc}
      role="button"
      tabindex="-1"
    />
  {:else}
    <div class="search-icon">
      {@html icon('search')}
    </div>
  {/if}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  #search-group{
    align-self: center;
    flex: 1 0 0;
    // 7 = max number of search section on a row
    max-width: 7 * $search-section-width;
    margin: 0 auto;
    margin-block-end: 0;
    // margin: 0;
    position: relative;
    background-color: white;
    @include radius;
  }
  #live-search{
    @include position(absolute, 100%, 0, null, 0);
    z-index: 1;
    flex: 1 0 auto;
    @include display-flex(column, stretch);
  }
  input{
    position: relative;
    @include radius;
    margin: 0;
    // Let room for .search-icon and #close-search
    padding-inline-end: 2em;
    // Appear above .search-icon, so that click on .search-icon gives focus to the input
    z-index: 1;
    background-color: transparent;
  }
  #close-search, .search-icon{
    position: absolute;
    inset-inline-end: 0;
    inset-block-start: 0;
    padding: 0;
    height: 100%;
    @include display-flex(row, center, center);
    @include text-hover($grey, $dark-grey);
  }
  .search-icon{
    font-size: 1.2rem;
    margin-inline-end: 0.3rem;
  }
  #close-search{
    font-size: 1.5rem;
    z-index: 1;
    background-color: transparent;
  }
  #overlay{
    background: rgba(black, 0.55);
    @include position(fixed, 0, 0, 0, 0);
    // The #topBar gives it a positive z-index, and it sould be displayed just below
    z-index: -1;
  }
  .loader, .search-results, .no-result{
    background-color: #eee;
  }
  .loader, .no-result{
    padding: 1em;
  }
  .loader{
    @include display-flex(column, center, center);
  }
  .no-result{
    text-align: center;
    color: $grey;
  }

  /* Medium to Large screens */
  @media screen and (width >= $small-screen){
    .search-results{
      max-height: 60vh;
      overflow: auto;
    }
  }

  /* Small screens */
  @media screen and (width < $small-screen){
    #search-group, input{
      height: 2rem;
    }
    #search-group{
      flex: 1 1 auto;
      flex-direction: row;
      flex-wrap: nowrap;
      margin-inline-start: auto;
      margin-block-start: -0.3em;
    }
    #live-search{
      @include position(fixed, $topbar-height, 0, 0, 0);
      height: calc(100% - $topbar-height);
      @include display-flex(column);
      overflow: hidden;
    }
    .search-results, .no-result, .loader{
      order: -1;
      flex: 1 0 0;
      overflow: auto;
      margin-block-end: 0.5em;
    }
  }
</style>
