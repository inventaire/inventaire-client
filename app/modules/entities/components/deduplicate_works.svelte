<script>
  import Spinner from 'modules/general/components/spinner.svelte'
  import MergeCandidate from './merge_candidate.svelte'
  import DeduplicateControls from './deduplicate_controls.svelte'
  import getWorksMergeCandidates from '../lib/get_works_merge_candidates'
  import mergeEntities from 'modules/entities/views/editor/lib/merge_entities'
  import { getSelectionStore, getFilterPattern, getEntityFilter, getAuthorWorksWithImagesAndCoauthors, spreadByPrefix, sortAlphabetically } from './lib/deduplicate_helpers'
  import { tick } from 'svelte'

  export let author

  let wdWorks = []
  let invWorks = []
  let index = -1
  let candidates, allWorksByPrefix, allCandidateWorksByPrefix, error, filterPattern
  let merging = false

  const waitForWorks = getAuthorWorksWithImagesAndCoauthors(author)
    .then(works => {
      allWorksByPrefix = spreadByPrefix(works)
      candidates = getWorksMergeCandidates(allWorksByPrefix.inv, allWorksByPrefix.wd)
      showNextProbableDuplicates()
    })

  const selection = getSelectionStore()

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
    selection.setAttribute('from', invWork)
    selection.setAttribute('to', mostProbableDuplicate)
  }

  function showFullLists () {
    wdWorks = allWorksByPrefix.wd.sort(sortAlphabetically)
    invWorks = allWorksByPrefix.inv.filter(notMerged).sort(sortAlphabetically)
  }

  const notMerged = entity => !entity._merged

  function next () {
    selection.reset()
    if (candidates[index]) {
      showNextProbableDuplicates()
    } else {
      showFullLists()
    }
  }

  function merge () {
    const { from, to } = selection.get()
    if (!(from && to)) return
    merging = true
    mergeEntities(from.uri, to.uri)
    .then(() => {
      from._merged = true
      invWorks = invWorks.filter(notMerged)
      next()
    })
    .catch(err => {
      error = err
    })
    .finally(() => merging = false)
  }

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
      selection.setAttribute('from', invWorks[0])
      selection.setAttribute('to', wdWorks[0])
    }
    window.scrollTo(0, 0)
  }

  async function skipCandidates () {
    candidates = null
    selection.reset()
    // Let controls update before the possibly expensive operations block the thread
    await tick()
    showFullLists()
  }
</script>

{#await waitForWorks}
  <p class="loading">Loading works... <Spinner/></p>
{:then}
  <div class="deduplicateWorks">
    <div class="wdWorks">
      <div class="header">
        <h3>Wikidata</h3>
        <span class="count">{wdWorks.length}</span>
      </div>
      <ul>
        {#each wdWorks as work (work.uri)}
          <li class="work">
            <MergeCandidate entity={work} {selection} {filterPattern}/>
          </li>
        {/each}
      </ul>
    </div>
    <div class="invWorks">
      <div class="header">
        <h3>Inventaire</h3>
        <span class="count">{invWorks.length}</span>
      </div>
      <ul>
        {#each invWorks as work (work.uri)}
          <li class="work">
            <MergeCandidate entity={work} {selection} {filterPattern}/>
          </li>
        {/each}
      </ul>
    </div>
  </div>
{/await}

<DeduplicateControls
  entity={author}
  {selection}
  {error}
  {candidates}
  {index}
  on:merge={merge}
  on:next={next}
  on:filter={filter}
  on:skip={skipCandidates}
  {merging}
/>

<style lang="scss">
  @import 'app/modules/general/scss/utils';

  .loading{
    display: flex;
  }

  .deduplicateWorks{
    display: flex;
    flex-direction: row;
    align-items: stretch;
    justify-content: center;
    /* Let room for the controls */
    min-height: calc(100vh - 7em);
    margin-bottom: 6em;
  }
  .wdWorks, .invWorks{
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
  .wdWorks{
    background-color: $grey;
    h3{
      color: white;
    }
  }
  .invWorks{
    background-color: $light-grey;
  }
  .work{
    flex-direction: column;
    margin-top: 0.5em;
  }
  ul:not(:empty){
    display: flex;
    align-items: stretch;
    justify-content: flex-start;
    flex-direction: column;
    flex-wrap: wrap;
    flex: 1 0 0;
    min-width: 15em;
  }
  /*Large screens*/
  @media screen and (min-width: 1400px) {
    ul:not(:empty){
      flex-direction: row;
      align-items: stretch;
      li{
        flex: 1 0 45%;
        margin: 0.2em;
        max-width: 48%;
        display: flex;
        flex-direction: row;
        align-items: stretch;
      }
    }
  }
</style>
