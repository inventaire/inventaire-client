<script lang="ts">
  import { tick } from 'svelte'
  import { mergeEntities } from '#entities/lib/editor/merge_entities'
  import Spinner from '#general/components/spinner.svelte'
  import { i18n } from '#user/lib/i18n'
  import getWorksMergeCandidates from '../lib/get_works_merge_candidates.ts'
  import DeduplicateControls from './deduplicate_controls.svelte'
  import { select, getFilterPattern, getEntityFilter, getAuthorWorksWithImagesAndCoauthors, spreadByPrefix, sortAlphabetically } from './lib/deduplicate_helpers.ts'
  import SelectableEntity from './selectable_entity.svelte'

  export let author

  let wdWorks = []
  let invWorks = []
  let candidates = []
  let index = -1
  let wdDisplayLimit = 10
  let invDisplayLimit = 10
  let allWorksByPrefix, allCandidateWorksByPrefix, flash, filterPattern, displayedWdWorks, displayedInvWorks, windowScrollY, wdBottomEl, invBottomEl, from, to
  let loading

  const waitForWorks = assignCandidates()

  async function assignCandidates () {
    return getAuthorWorksWithImagesAndCoauthors(author)
      .then(works => {
        allWorksByPrefix = spreadByPrefix(works)
        candidates = getWorksMergeCandidates(allWorksByPrefix.inv, allWorksByPrefix.wd)
        showNextProbableDuplicates()
      })
  }

  function showNextProbableDuplicates () {
    index += 1
    const nextCandidate = candidates[index]
    if (nextCandidate == null) return next()
    let { invWork, possibleDuplicateOf } = nextCandidate

    if (invWork._merged) return next()

    possibleDuplicateOf = possibleDuplicateOf.filter(notMerged)

    const mostProbableDuplicate = possibleDuplicateOf[0]
    if (mostProbableDuplicate == null) return next()

    allCandidateWorksByPrefix = spreadByPrefix([ invWork ].concat(possibleDuplicateOf))
    wdWorks = allCandidateWorksByPrefix.wd
    invWorks = allCandidateWorksByPrefix.inv
    from = invWork
    to = mostProbableDuplicate
  }

  let showingFullLists = false
  function showFullLists () {
    wdWorks = allWorksByPrefix.wd.sort(sortAlphabetically)
    invWorks = allWorksByPrefix.inv.filter(notMerged).sort(sortAlphabetically)
    showingFullLists = true
  }

  $: displayedWdWorks = wdWorks.slice(0, wdDisplayLimit)
  $: displayedInvWorks = invWorks.slice(0, invDisplayLimit)

  $: {
    if (wdBottomEl != null) {
      const screenBottom = windowScrollY + window.screen.height
      if (screenBottom + 100 > wdBottomEl.offsetTop) wdDisplayLimit += 10
    }
  }

  $: {
    if (invBottomEl != null) {
      const screenBottom = windowScrollY + window.screen.height
      if (screenBottom + 100 > invBottomEl.offsetTop) invDisplayLimit += 10
    }
  }

  const notMerged = entity => !entity._merged

  function next () {
    from = null
    to = null
    if (candidates[index]) {
      showNextProbableDuplicates()
    } else if (!showingFullLists) {
      showFullLists()
    }
  }

  async function merge () {
    if (!(from && to)) return
    const mergedEntity = from
    mergedEntity._merged = true
    const fromUri = from.uri
    const toUri = to.uri
    // Optimistic UI: go to the next candidates without waiting for the merge confirmation
    next()
    try {
      await mergeEntities(fromUri, toUri)
    } catch (err) {
      mergedEntity._merged = false
      flash = err
    }
  }

  let fromSelectedByFilter, toSelectedByFilter

  function filter (event) {
    const filterText = event.detail.trim().toLowerCase()
    const pattern = getFilterPattern(event.detail)
    filterPattern = filterText !== '' ? pattern : null
    const filterFn = getEntityFilter(filterText, pattern)
    if (candidates[index]) {
      wdWorks = allCandidateWorksByPrefix.wd.filter(filterFn)
      invWorks = allCandidateWorksByPrefix.inv.filter(filterFn)
    } else {
      wdWorks = allWorksByPrefix.wd.filter(filterFn)
      invWorks = allWorksByPrefix.inv.filter(filterFn)
    }
    if (wdWorks.length === 1 && invWorks.length === 1) {
      from = invWorks[0]
      to = wdWorks[0]
      fromSelectedByFilter = from
      toSelectedByFilter = to
    } else {
      if (fromSelectedByFilter === from) from = fromSelectedByFilter = null
      if (toSelectedByFilter === to) to = toSelectedByFilter = null
    }
    window.scrollTo(0, 0)
  }

  async function skipCandidates () {
    candidates = []
    from = null
    to = null
    // Let controls update before the possibly expensive operations block the thread
    await tick()
    showFullLists()
  }

  async function resetCandidates () {
    loading = true
    wdWorks = []
    invWorks = []
    await assignCandidates()
    index = -1
    showNextProbableDuplicates()
    loading = false
  }

  const onEntitySelect = ({ detail: entity }) => {
    ({ from, to } = select(entity, from, to))
  }
</script>

<svelte:window bind:scrollY={windowScrollY} />
{#await waitForWorks}
  <p class="loading">{i18n('Loading works...')}<Spinner /></p>
{:then}
  <div class="deduplicate-works">
    <div class="wd-works">
      <div class="header">
        <h3>Wikidata</h3>
        <span class="count">{wdWorks.length}</span>
      </div>
      <ul>
        {#each displayedWdWorks as work (work.uri)}
          <li class="work">
            <SelectableEntity
              entity={work}
              bind:from
              bind:to
              {filterPattern}
              on:select={onEntitySelect}
            />
          </li>
        {:else}
          {#if loading}
            <p class="loading">{i18n('Loading works...')}<Spinner /></p>
          {/if}
        {/each}
      </ul>
      {#if displayedWdWorks.length < wdWorks.length}
        <p class="more" bind:this={wdBottomEl}>Loading more...</p>
      {/if}
    </div>
    <div class="inv-works">
      <div class="header">
        <h3>Inventaire</h3>
        <span class="count">{invWorks.length}</span>
      </div>
      <ul>
        {#each displayedInvWorks as work (work.uri)}
          {#if !work._merged}
            <li class="work">
              <SelectableEntity
                entity={work}
                bind:from
                bind:to
                {filterPattern}
                on:select={onEntitySelect}
              />
            </li>
          {/if}
        {:else}
          {#if loading}
            <p class="loading">{i18n('Loading works...')}<Spinner /></p>
          {/if}
        {/each}
        {#if displayedInvWorks.length < invWorks.length}
          <p class="more" bind:this={invBottomEl}>Loading more...</p>
        {/if}
      </ul>
    </div>
  </div>
{/await}

<DeduplicateControls
  entity={author}
  bind:from
  bind:to
  {flash}
  {candidates}
  {index}
  on:merge={merge}
  on:next={next}
  on:filter={filter}
  on:skip={skipCandidates}
  on:reset={resetCandidates}
/>

<style lang="scss">
  @import "#general/scss/utils";

  .loading{
    display: flex;
    margin: 4em;
  }

  .deduplicate-works{
    display: flex;
    flex-direction: row;
    align-items: stretch;
    justify-content: center;
    /* Let room for the controls */
    min-block-size: calc(100vh - 7em);
    margin-block-end: 6em;
  }
  .wd-works, .inv-works{
    padding: 0.5em;
    flex: 1 0 0;
  }
  .header{
    display: flex;
    flex-direction: row;
    align-items: flex-start;
    justify-content: center;
  }
  h3{
    font-size: 1.2rem;
    opacity: 0.8;
    text-align: center;
  }
  .count{
    background-color: white;
    padding: 0.1em 0.4em;
    margin: 0.4em 0.5em;
    line-height: 1em;
    border-radius: 3px;
    opacity: 0.8;
  }
  .wd-works{
    background-color: $grey;
    h3{
      color: white;
    }
  }
  .inv-works{
    background-color: $light-grey;
  }
  .work{
    flex-direction: column;
    margin-block-start: 0.5em;
  }
  ul:not(:empty){
    display: flex;
    align-items: stretch;
    justify-content: flex-start;
    flex-direction: column;
    flex-wrap: wrap;
    flex: 1 0 0;
    min-inline-size: 15em;
    margin-block-end: 5rem;
  }
  .more{
    text-align: center;
  }
  /* Large screens */
  @media screen and (width >= 1800px){
    ul:not(:empty){
      flex-direction: row;
      align-items: stretch;
      li{
        flex: 1 0 45%;
        margin: 0.2em;
        max-inline-size: 48%;
        display: flex;
        flex-direction: row;
        align-items: stretch;
      }
    }
  }
</style>
