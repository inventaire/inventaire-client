<script>
  import _ from 'underscore'
  import Spinner from '#general/components/spinner.svelte'
  import DeduplicateAuthorsNames from './deduplicate_authors_names.svelte'
  import SelectableEntity from './selectable_entity.svelte'
  import DeduplicateControls from './deduplicate_controls.svelte'
  import searchType from '../lib/search/search_type.js'
  import { getEntityUri } from '#entities/lib/search/entities_uris_results'
  import { getEntitiesByUris } from '#entities/lib/entities'
  import { addAuthorWorks } from '../lib/types/author_alt.js'
  import mergeEntities from '#entities/views/editor/lib/merge_entities'
  import { fade } from 'svelte/transition'
  import { select } from './lib/deduplicate_helpers.js'
  const searchHumans = searchType('humans')

  const name = app.request('querystring:get', 'name')
  let showDuplicateAuthorsNames = false
  let selectedName, waitingForHomonyms, homonymsEntities, error, filterPattern, from, to

  if (name) showName(name)
  else showDuplicateAuthorsNames = true

  async function showName (name) {
    app.execute('querystring:set', 'name', name)
    selectedName = name
    filterPattern = new RegExp(name, 'i')
    waitingForHomonyms = getHomonyms(name)
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

  function merge () {
    mergeEntities(from.uri, to.uri)
      .then(() => {
        homonymsEntities = homonymsEntities.filter(entity => entity !== from)
        from = null
        to = null
      })
      .catch(err => {
        error = err
      })
  }

  const onEntitySelect = ({ detail: entity }) => {
    ({ from, to } = select(entity, from, to))
  }
</script>

{#if showDuplicateAuthorsNames}
  <DeduplicateAuthorsNames on:select={e => showName(e.detail)} />
{:else}
  <button on:click={() => showDuplicateAuthorsNames = !showDuplicateAuthorsNames}>
    Display duplicated author names list
  </button>
{/if}

{#if selectedName}
  <h2>{selectedName}</h2>
  {#await waitingForHomonyms}
    <p class="loading">Loading homonyms... <Spinner /></p>
  {:then}
    <ul class="homonyms">
      {#each homonymsEntities as homonym (homonym.uri)}
        <li class="homonym" in:fade={{ duration: 200 }}>
          <SelectableEntity
            entity={homonym}
            on:select={onEntitySelect}
            bind:from
            bind:to
            {filterPattern}
          />
        </li>
      {/each}
    </ul>
  {/await}
{/if}

<DeduplicateControls
  bind:from
  bind:to
  {error}
  on:merge={merge} />

<style>
  h2, .loading{
    text-align: center;
  }
  .loading{
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: center;
  }
  .homonyms{
    display: flex;
    align-items: stretch;
    justify-content: flex-start;
    flex-wrap: wrap;
    /* Compensating for the place taken by the controls */
    margin-bottom: 4em;
  }
  .homonym{
    margin: 0.5em;
    overflow-y: auto;
    width: 48%;
  }
</style>
