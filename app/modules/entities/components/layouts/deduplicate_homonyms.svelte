<script lang="ts">
  import { pluck, partition } from 'underscore'
  import { icon } from '#app/lib/icons'
  import CompactAuthorWorksList from '#entities/components/layouts/compact_author_works_list.svelte'
  import MergeAction from '#entities/components/layouts/merge_action.svelte'
  import { findExactMatches, getHomonymsEntities, preselectLikelyDuplicates } from '#entities/components/lib/homonym_deduplicates_helpers'
  import Spinner from '#general/components/spinner.svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import { mainUser } from '#user/lib/main_user'
  import EntityListRow from './entity_list_row.svelte'

  export let entity
  export let standalone = false

  let homonyms = []
  let invHomonyms = []
  let selectedHomonymsUris = []
  let wdExactMatches, invExactMatches

  const { hasDataadminAccess } = mainUser

  const getHomonymsPromise = async () => {
    homonyms = await getHomonymsEntities(entity)
    ;({ wdExactMatches, invExactMatches } = findExactMatches({ entity, homonyms }))
    selectedHomonymsUris = preselectLikelyDuplicates({ entity, wdExactMatches, invExactMatches }) || []
    // Display the preselected homonyms first
    const [ preselected, notPreselected ] = partition(homonyms, isSelectedHomonym)
    homonyms = preselected.concat(notPreselected)
    invHomonyms = homonyms.filter(homonym => !homonym.isWikidataEntity)
  }

  const isSelectedHomonym = homonym => {
    return !homonym.isMerging && !homonym.merged && selectedHomonymsUris.includes(homonym.uri)
  }

  function selectAllExactMatches () {
    selectedHomonymsUris = pluck(invExactMatches, 'uri')
  }
  function selectAll () {
    selectedHomonymsUris = pluck(invHomonyms, 'uri')
  }
  function unselectAll () {
    selectedHomonymsUris = []
  }

  function mergeSelectedSuggestions () {
    const homonymsToMerge = homonyms.filter(isSelectedHomonym)

    const mergeSequentially = async () => {
      const nextSelectedView = homonymsToMerge.shift()
      if (nextSelectedView == null) return
      await nextSelectedView.merge()
      return mergeSequentially()
    }

    // Merge 3 at a time
    mergeSequentially()
    mergeSequentially()
    mergeSequentially()
  }
</script>

{#if standalone}
  <div class="entity-info-wrapper">
    <EntityListRow {entity} />
  </div>
{/if}

{#if hasDataadminAccess}
  {#await getHomonymsPromise()}
    <div class="loading-wrapper">
      <p class="loading">{i18n('Looking for duplicates…')}
        <Spinner center={true} />
      </p>
    </div>
  {:then}
    <div class="deduplicate-homonyms" class:standalone>
      <h4>
        {@html icon('compress')}
        {I18n('merge homonyms')}
      </h4>

      <div class="merge-homonyms-controls">
        <button
          class="tiny-button"
          on:click={selectAllExactMatches}
          aria-controls="selectable-homonyms"
          disabled={invExactMatches.length === 0}
        >
          {@html icon('check-square')}
          {I18n('select all local exact matches')}
          <span class="count">({invExactMatches.length})</span>
        </button>
        <button
          class="tiny-button"
          on:click={selectAll}
          aria-controls="selectable-homonyms"
          disabled={invHomonyms.length === 0}
        >
          {@html icon('check-square')}
          {I18n('select all local entities')}
          <span class="count">({invHomonyms.length})</span>
        </button>
        <button
          class="tiny-button"
          on:click={unselectAll}
          aria-controls="selectable-homonyms"
        >
          {@html icon('square')}
          {I18n('unselect all')}
        </button>
        <button
          class="tiny-button"
          on:click={mergeSelectedSuggestions}
          aria-controls="selectable-homonyms"
          disabled={selectedHomonymsUris.length === 0}
        >
          {@html icon('compress')}
          {I18n('merge selected suggestions')}
          <span class="count">({selectedHomonymsUris.length})</span>
        </button>
      </div>
      <ul id="selectable-homonyms">
        {#each homonyms as homonym}
          <li class:merged={homonym.merged}>
            <div class="top-row">
              {#if !(entity.isWikidataEntity && homonym.isWikidataEntity)}
                <input type="checkbox" bind:group={selectedHomonymsUris} value={homonym.uri} />
              {/if}
              <EntityListRow
                entity={homonym}
                isUriToDisplay={true}
              />
            </div>
            {#if entity.type === 'human'}
              <CompactAuthorWorksList author={homonym} />
            {/if}
            <div class="action">
              <MergeAction
                bind:merge={homonym.merge}
                fromEntityUri={homonym.uri}
                targetEntityUri={entity.uri}
                on:merged={() => homonym.merged = true}
                on:isMerging={() => homonym.isMerging = true}
              />
            </div>
          </li>
        {:else}
          <p class="no-results">{I18n('no homonym found')}</p>
        {/each}
      </ul>
    </div>
  {/await}
{/if}
<style lang="scss">
  @import "#general/scss/utils";
  .loading-wrapper, .entity-info-wrapper{
    @include display-flex(row, center, center);
  }
  .entity-info-wrapper{
    max-inline-size: 50em;
    margin: 1em auto;
  }
  .merge-homonyms-controls button{
    margin: 0.2em;
    .count{
      color: white;
      // Prevent button width change on count change
      display: inline-block;
      min-inline-size: 2em;
      text-align: center;
    }
  }
  .deduplicate-homonyms{
    @include display-flex(column, center);
    background-color: $off-white;
    padding: 1em;
    margin: 0.5em 0;
  }
  #selectable-homonyms{
    @include display-flex(row, flex-start, center, wrap);
    margin: 1em auto;
  }
  .standalone{
    li{
      margin: 0.5em;
    }
  }
  li{
    @include display-flex(column, center, center);
    @include radius;
    padding: 0.2em 0.5em;
    margin: 0.3em;
    inline-size: min(26em, 95vw);
    background-color: white;
    &.merged{
      // Hide without removing from the document flow, to prevent element jumping
      // and accidental clicks on "merge" buttons
      visibility: hidden;
    }
    :global(.images-collage){
      // keep series covers tight
      inline-size: 7em;
    }
    :global(.images-collage.empty){
      display: none;
    }
    :global(.entity-list-row){
      margin-block-end: 0 !important;
    }
    :global(.entity-details){
      max-block-size: 10em;
      line-height: 1.5rem;
      overflow-y: auto;
    }
  }
  .top-row{
    align-self: stretch;
    @include display-flex(row, flex-start);
    input[type="checkbox"]{
      margin: 0.5em 0;
    }
  }
  .action{
    margin: 0.5em;
  }
  .no-results{
    margin: 1em;
    padding: 1em;
  }
  /* Smaller screens */
  @media screen and (width < $smaller-screen){
    .merge-homonyms-controls{
      @include display-flex(column, center);
    }
  }
  /* Small screens */
  @media screen and (width < $small-screen){
    button{
      margin-block-end: 0.5em;
    }
  }
</style>
