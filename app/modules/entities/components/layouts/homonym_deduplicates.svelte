<script>
  import { getHomonymsEntities } from '#entities/lib/show_homonyms'
  import Spinner from '#general/components/spinner.svelte'
  import { icon } from '#lib/utils'
  import { I18n, i18n } from '#user/lib/i18n'
  import EntityListElement from './entity_list_element.svelte'

  export let entity

  let homonyms = []
  const { hasDataadminAccess } = app.user

  const getHomonymsPromise = async () => homonyms = await getHomonymsEntities(entity)
</script>
{#if hasDataadminAccess}
  {#await getHomonymsPromise()}
    <div class="loading-wrapper">
      <p class="loading">{i18n('Looking for duplicates...')}
        <Spinner center={true} />
      </p>
    </div>
  {:then}
  	<div class="dataadmin-section">
      <h4>
        {@html icon('compress')}
        {I18n('merge homonyms')}
      </h4>
      <!-- TODO: recover select all/unselect all/merge all selected buttons -->
      <ul class='homonyms'>
        {#each homonyms as homonym}
          {#if !homonym.merged}
            <li>
              <!-- TODO: recover list of subentities (typically author works) -->
              <EntityListElement
                entity={homonym}
                actionType={'merge'}
                parentEntity={entity}
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
  @import '#general/scss/utils';
  .dataadmin-section{
    @include display-flex(column, center);
    background-color: $off-white;
    padding: 1em;
    margin: 1em 0;
  }
  .homonyms{
    @include display-flex(row, baseline, space-around, wrap);
    :global(.entity-list){
      width: 100%;
      max-width: 30em;
    }
  }
  li{
    @include display-flex(column, center, center);
    padding: 0.5em;
    margin: 0.5em;
    width: 18em;
    background-color: $light-grey;
    background-color: white;
    @include radius;
  }
  /*Large screens*/
  @media screen and (min-width: $small-screen) {
    .dataadmin-section{
      min-width: 30em;
    }
  }
</style>
