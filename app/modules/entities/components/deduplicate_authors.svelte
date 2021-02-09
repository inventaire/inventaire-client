<script>
  import _ from 'underscore'
  import Spinner from 'modules/general/components/spinner.svelte'
  import DeduplicateAuthorsNames from './deduplicate_authors_names.svelte'
  import MergeCandidate from './merge_candidate.svelte'
  import DeduplicateControls from './deduplicate_controls.svelte'
  import searchType from '../lib/search/search_type'
  import { getEntityUri } from 'modules/entities/lib/search/entities_uris_results'
  import { getEntitiesByUris } from 'modules/entities/lib/entities'
  import { addAuthorWorks } from '../lib/types/author'
  import mergeEntities from 'modules/entities/views/editor/lib/merge_entities'
  import { getSelectionStore } from './lib/deduplicate_helpers'
  import { fade } from 'svelte/transition'
  const searchHumans = searchType('humans')

  export let name
  let showDuplicateAuthorsNames = false
  let selectedName, waitingForHomonymes, homonymsEntities, error

  if (name) showName(name)
  else showDuplicateAuthorsNames = true

  async function showName (name) {
    app.execute('querystring:set', 'name', name)
    selectedName = name
    waitingForHomonymes = getHomonyms(name)
  }

  async function getHomonyms (name) {
    let humans = await searchHumans(name, 4)
    // If there are many candidates, keep only those that look the closest, if any
    if (humans.length > 50) {
      const subset = humans.filter(asNameMatch(name))
      if (subset.length > 1) humans = subset
    }

    // If there are still many candidates, truncate the list to make it less
    // resource intensive
    if (humans.length > 50) humans = humans.slice(0, 51)

    const uris = humans.map(human => getEntityUri(human.id || human._id))
    homonymsEntities = await getAuthorsWithWorks(uris)
  }

  const getAuthorsWithWorks = async uris => {
    const authors = await getEntitiesByUris(uris)
    await Promise.all(authors.map(addAuthorWorks))
    return authors
  }

  const asNameMatch = name => human => _.any(_.values(human.labels), labelMatch(name))
  const labelMatch = name => label => normalize(label) === normalize(name)
  const normalize = name => {
    return name
    .trim()
    // Remove single letter for second names 'L.'
    .replace(/\s\w{1}\.\s?/g, ' ')
    // Remove double spaces
    .replace(/\s\s/g, ' ')
    // Remove special characters
    .replace(/[./\\,]/g, '')
    .toLowerCase()
  }

  const selection = getSelectionStore()

  function merge () {
    const { from, to } = selection.get()
    mergeEntities(from.uri, to.uri)
    .then(() => {
      homonymsEntities = homonymsEntities.filter(entity => entity !== from)
    })
    .catch(err => {
      error = err
    })
  }
</script>

{#if showDuplicateAuthorsNames}
  <DeduplicateAuthorsNames on:selected={e => showName(e.detail)} />
{:else}
  <button on:click={() => showDuplicateAuthorsNames = !showDuplicateAuthorsNames}>
    Display duplicated author names list
  </button>
{/if}

{#if selectedName}
  <h2>{selectedName}</h2>
  {#await waitingForHomonymes}
    <p class="loading">Loading homonyms... <Spinner/></p>
  {:then}
    <ul class="homonyms">
      {#each homonymsEntities as homonym}
        <li class="homonym" in:fade={{ duration: 200 }}>
          <MergeCandidate entity={homonym} {selection} />
        </li>
      {/each}
    </ul>
  {/await}
{/if}

<DeduplicateControls {selection} {error} on:merge={merge}/>

<style>
  h2, .loading{
    text-align: center;
  }
  .loading, .homonyms{
    display: flex;
    align-items: flex-start;
    justify-content: center;
  }
  .homonyms{
    flex-wrap: wrap;
    /* Compensating for the place taken by the controls */
    margin-bottom: 4em;
  }
  .homonym{
    margin: 0.5em;
    width: 18em;
    max-height: 20em;
    overflow-y: auto;
  }
</style>
