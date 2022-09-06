<script>
  // TODO:
  // - hint to input ISBNs directly, maybe in the alternatives sections
  // - add 'help': indexed wiki.inventaire.io entries to give results
  //   to searches such as 'FAQ' or 'help creating group'
  // - add 'place': search Wikidata for entities with coordinates (wdt:P625)
  //   and display a layout with users & groups nearby, as well as books with
  //   narrative location (wdt:P840), or authors born (wdt:P19)
  //   or dead (wdt:P20) nearby

  import { i18n, I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import getActionKey from '#lib/get_action_key'
  import SearchShortcuts from '#search/components/search_shortcuts.svelte'
  import SearchControls from '#search/components/search_controls.svelte'
  import SearchAlternatives from '#search/components/search_alternatives.svelte'
  import { getNextSection, getPrevSection, typesBySection } from '#search/lib/search_sections'
  import { debounce } from 'underscore'
  import findUri from '#search/lib/find_uri'
  import WikidataSearch from '#entities/lib/search/wikidata_search'
  import preq from '#lib/preq'
  import Spinner from '#components/spinner.svelte'
  import SearchResult from '#search/components/search_result.svelte'
  import Flash from '#lib/components/flash.svelte'
  import { onChange } from '#lib/svelte/svelte'
  import { serializeEntityModel, serializeSubject } from '#search/lib/search_results'
  import { screen } from '#lib/components/stores/screen'
  import { onDestroy } from 'svelte'
  import viewport from '#lib/components/actions/viewport'

  const wikidataSearch = WikidataSearch(false)

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

  async function search () {
    const searchKey = `${selectedCategory}:${selectedSection}:${searchText}`
    hasMore = false
    flash = null
    if (searchKey === lastSearchKey) return
    lastSearchKey = searchKey
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
  const getSearchResults = async searchText => {
    uri = findUri(searchText)
    if (uri != null) {
      return getResultFromUri(uri)
    } else {
      return _search(searchText)
    }
  }

  async function _search (searchText) {
    const types = typesBySection[selectedCategory][selectedSection]
    // Subjects aren't indexed in the server ElasticSearch
    // as it's not a subset of Wikidata anymore: pretty much anything
    // on Wikidata can be considered a subject
    if (types === 'subjects') {
      const res = await wikidataSearch(searchText, searchBatchLength, searchOffset)
      hasMore = res.continue != null
      return res.results.map(serializeSubject)
    } else {
      // Increasing search limit instead of offset, as search pages aren't stable:
      // results popularity might have change the results order between two requests,
      // thus the need to re-fetch from offset 0 but increasing the page length, and adding only
      // the results that weren't returned in the previous query, whatever there place
      // in the newly returned results
      const searchLimit = searchBatchLength + searchOffset
      const res = await preq.get(app.API.search({
        types,
        search: searchText,
        limit: searchLimit,
      }))
      hasMore = res.continue != null
      return res.results
    }
  }

  const lazySearch = debounce(search, 400)

  async function getResultFromUri (uri) {
    waiting = app.request('get:entity:model', uri)
    const entity = await waiting
    const result = serializeEntityModel(entity)
    return [ result ]
  }

  function onKeyDown (e) {
    const key = getActionKey(e)
    if (key === 'up') highlightPreviousResult()
    else if (key === 'down') highlightNextResult()
  }

  function onKeyUp (e) {
    const key = getActionKey(e)
    if (key === 'esc') hideLiveSearch()
    else if (key === 'enter') showCurrentlyHighlightedResult(e)
    else if (key === 'pageup') selectPrevSection()
    else if (key === 'pagedown') selectNextSection()
    else lazySearch()
    if (neutralizedKeys.has(key)) e.preventDefault()
  }

  const neutralizedKeys = new Set([ 'up', 'down', 'pageup', 'pagedown' ])

  const showLiveSearch = () => {
    showSearchDropdown = true
  }
  const hideLiveSearch = () => {
    showSearchDropdown = false
    if (showFallbackLayout) showFallbackLayout()
  }
  const hideAndResetLiveSearch = () => {
    searchText = ''
    hideLiveSearch()
  }

  const highlightPreviousResult = () => highlightedResultIndex = Math.max(highlightedResultIndex - 1, 0)
  const highlightNextResult = () => highlightedResultIndex = Math.min(highlightedResultIndex + 1, results.length - 1)
  const showCurrentlyHighlightedResult = () => {
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
  const selectPrevSection = () => {
    ;({ selectedCategory, selectedSection } = getPrevSection({ selectedCategory, selectedSection }))
  }
  const selectNextSection = () => {
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
    selectedCategory = (section === 'user' || section === 'group') ? 'social' : 'entity'
    selectedSection = section
    showFallbackLayout = fallback
  }

  app.vent.on('live:search:query', onSearchQuery)
  onDestroy(() => {
    app.vent.off('live:search:query', onSearchQuery)
  })
</script>

<svelte:body on:click={onOutsideClick} />

<div id="searchGroup" bind:this={searchGroupEl} >
  <input
    type="search"
    name="search"
    placeholder="{I18n('search_verb')}"
    autocomplete="off"
    autocorrect="off"
    autocapitalize="off"
    aria-label="search"
    aria-autocomplete="list"
    aria-controls="liveSearch"
    bind:value={searchText}
    bind:this={searchFieldEl}
    on:focus={showLiveSearch}
    on:keydown={onKeyDown}
    on:keyup={onKeyUp}
    >
  {#if showSearchDropdown}
    <button
      id="closeSearch"
      title={I18n('close')}
      on:click={hideAndResetLiveSearch}
      >
      {@html icon('close')}
    </button>
    <div id="liveSearch">
      <SearchControls
        bind:showSearchControls
        bind:selectedCategory
        bind:selectedSection
        {results}
      />
      {#if showResults}
        {#if results.length > 0}
          <div class="results">
            <ul id="searchResults" on:click={hideLiveSearch} bind:this={searchResultsEl}>
              {#each results as result, index (result.id)}
                <SearchResult {result} highlighted={index === highlightedResultIndex} />
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
          <p class="no-result">{i18n('no result')}</p>
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
    <div id="overlay" on:click={hideLiveSearch}></div>
  {/if}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  #liveSearch{
    @include position(absolute, 100%, 0, null, 0);
    z-index: 1;
    flex: 1 0 auto;
    @include display-flex(column, stretch);
  }
  #searchGroup{
    margin: 0;
    position: relative;
  }
  input{
    @include radius;
    margin: 0;
    // Let room for #closeSearch
    padding-right: 2em;
  }
  #closeSearch{
    position: absolute;
    right: 0;
    top: 0;
    padding: 0;
    height: 100%;
    font-size: 1.5rem;
    @include display-flex(row, center, center);
    @include text-hover($grey, $dark-grey);
  }
  #overlay{
    background: rgba(black, 0.55);
    @include position(fixed, 0, 0, 0, 0);
    // The #topBar gives it a positive z-index, and it sould be displayed just below
    z-index: -1;
  }
  .loader, .results, .no-result{
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

  /*Medium to Large screens*/
  @media screen and (min-width: $smaller-screen) {
    .results{
      max-height: 60vh;
      overflow: auto;
    }
  }

  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    #searchGroup, input{
      height: 2rem;
    }
    #searchGroup{
      flex: 1 1 auto;
      flex-direction: row;
      flex-wrap: nowrap;
      margin-left: auto;
      margin-top: -0.3em;
    }
    #liveSearch{
      @include position(fixed, $topbar-height, 0, 0, 0);
      @include display-flex(column);
    }
  }

  /*Smaller screens*/
  @media screen and (max-width: $smaller-screen) {
    #liveSearch{
      height: calc(100% - $topbar-height);
      @include display-flex(column);
      overflow: hidden;
    }
    .results, .no-result, .loader{
      order: -1;
      flex: 1 0 0;
      overflow: auto;
      margin-bottom: 0.5em;
    }
  }
</style>
