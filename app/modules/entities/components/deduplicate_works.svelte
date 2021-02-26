<script>
  import Spinner from 'modules/general/components/spinner.svelte'
  import MergeCandidate from './merge_candidate.svelte'
  import DeduplicateControls from './deduplicate_controls.svelte'
  import { fade } from 'svelte/transition'
  import getWorksMergeCandidates from '../lib/get_works_merge_candidates'
  import mergeEntities from 'modules/entities/views/editor/lib/merge_entities'
  import { getSelectionStore, getFilterPattern, getEntityFilter } from './lib/deduplicate_helpers'
  export let worksPromise, author

  let wdWorks = []
  let invWorks = []
  let index = -1
  let candidates, allWorksByPrefix, allCandidateWorksByPrefix, error, filterPattern

  const waitForWorks = worksPromise.then(works => {
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

  function spreadByPrefix (works) {
    const worksByPrefix = { wd: [], inv: [] }
    works.forEach(work => {
      worksByPrefix[work.prefix].push(work)
    })
    return worksByPrefix
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
    mergeEntities(from.uri, to.uri)
    .then(() => {
      from._merged = true
      invWorks = invWorks.filter(notMerged)
      next()
    })
    .catch(err => {
      error = err
    })
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
  }

  function sortAlphabetically (a, b) {
    if (a.label.toLowerCase() > b.label.toLowerCase()) return 1
    else return -1
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
          <li class="work" in:fade={{ duration: 200 }}>
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
          <li class="work" in:fade={{ duration: 200 }}>
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
    margin-bottom: 4em;
  }
  .wdWorks, .invWorks{
    padding: 0.5em;
    flex: 1 0 0;
  }
  ul:not(:empty){
    display: flex;
    align-items: flex-start;
    justify-content: center;
    flex-wrap: wrap;
    flex: 1 0 0;
    min-width: 15em;
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
    margin: 0.5em;
  }
</style>
