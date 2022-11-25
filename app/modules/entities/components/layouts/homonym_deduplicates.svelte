<script>
  import { getHomonymsEntities, haveLabelMatch } from '#entities/lib/show_homonyms'
  import Spinner from '#general/components/spinner.svelte'
  import { icon } from '#lib/utils'
  import { I18n, i18n } from '#user/lib/i18n'
  import EntityListRow from './entity_list_row.svelte'
  import MergeAction from '#entities/components/layouts/merge_action.svelte'
  import { pluck } from 'underscore'

  export let entity

  let homonyms = []
  let selectedHomonymsUris = []

  const { hasDataadminAccess } = app.user

  const getHomonymsPromise = async () => homonyms = await getHomonymsEntities(entity)
    .then(checkCheckboxOnLabelsMatch)

  async function checkCheckboxOnLabelsMatch (homonyms) {
    selectedHomonymsUris = homonyms
      .filter(homonym => haveLabelMatch(homonym, entity))
      .map((_.property('uri')))
    return homonyms
  }

  const selectedHomonyms = homonym => !homonym.isMerging && !homonym.merged && selectedHomonymsUris.includes(homonym.uri)

  function selectAll () {
    selectedHomonymsUris = pluck(homonyms, 'uri')
  }
  function unselectAll () {
    selectedHomonymsUris = []
  }

  function mergeSelectedSuggestions () {
    const homonymsToMerge = homonyms.filter(selectedHomonyms)

    const mergeSequentially = function () {
      const nextSelectedView = homonymsToMerge.shift()
      if (nextSelectedView == null) return
      return nextSelectedView.merge()
        .then(mergeSequentially)
    }

    // Merge 3 at a time
    mergeSequentially()
    mergeSequentially()
    mergeSequentially()
  }
</script>
{#if hasDataadminAccess}
  {#await getHomonymsPromise()}
    <div class="loading-wrapper">
      <p class="loading">{i18n('Looking for duplicates…')}
        <Spinner center={true} />
      </p>
    </div>
  {:then}
    <div class="dataadmin-section">
      <h4>
        {@html icon('compress')}
        {I18n('merge homonyms')}
      </h4>

      <div class="merge-homonyms-controls">
        <button
          on:click={selectAll}
          aria-controls="selectable-homonyms"
        >
          {@html icon('check-square')}
          <span class="button-label">{I18n('select all')}</span>
          <span class="count">({homonyms.length})</span>
        </button>
        <button
          on:click={unselectAll}
          aria-controls="selectable-homonyms"
        >
          {@html icon('square')}
          <span class="button-label">{I18n('unselect all')}</span>
        </button>
        <button
          on:click={mergeSelectedSuggestions}
          aria-controls="selectable-homonyms"
          disabled={selectedHomonymsUris.length === 0}
        >
          {@html icon('compress')}
          <span class="button-label">{I18n('merge selected suggestions')}</span>
          <span class="count">({selectedHomonymsUris.length})</span>
        </button>
      </div>
      <ul id="selectable-homonyms">
        {#each homonyms as homonym}
          {#if !homonym.merged}
            <li>
              <input type="checkbox" bind:group={selectedHomonymsUris} value={homonym.uri} />
              <!-- TODO: recover list of subentities (typically author works) -->
              <EntityListRow
                entity={homonym}
                parentEntity={entity}
                noImageCredits="true"
                displayUri="true"
              />
              <MergeAction
                bind:merge={homonym.merge}
                fromEntityUri={homonym.uri}
                targetEntityUri={entity.uri}
                on:merged={() => homonym.merged = true}
                on:isMerging={() => homonym.isMerging = true}
              />
            </li>
          {/if}
        {:else}
          {i18n('has no homonym')}
        {/each}
      </ul>
    </div>
  {/await}
{/if}
<style lang="scss">
  @import "#general/scss/utils";
  .dataadmin-section{
    @include display-flex(column, center);
    background-color: $off-white;
    padding: 1em;
    margin: 1em 0;
  }
  #selectable-homonyms{
    @include display-flex(row, baseline, space-around, wrap);
    :global(.entity-wrapper){
      max-width: 30em;
    }
  }
  li{
    :global(.images-collage){
      // keep series covers tight
      width: 7em;
    }
    @include display-flex(row, center, center);
    @include radius;
    padding: 0.5em 1em;
    margin: 0.5em;
    background-color: $light-grey;
    background-color: white;
    input{
      margin-right: 1em;
    }
  }
  button{
    @include tiny-button($grey);
  }
  /* Large screens */
  @media screen and (min-width: $small-screen){
    .dataadmin-section{
      min-width: 30em;
    }
  }
  /*Smaller screens*/
  @media screen and (max-width: $smaller-screen) {
    .merge-homonyms-controls{
      @include display-flex(column, center);
    }
  }
  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    button{
      margin-bottom: 0.5em;
    }
  }
</style>
