<script>
  import getFavoriteLabel from '#entities/lib/get_favorite_label'
  import { getHomonymsEntities } from '#entities/lib/show_homonyms'
  import Spinner from '#general/components/spinner.svelte'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import Flash from '#lib/components/flash.svelte'
  import { icon } from '#lib/utils'
  import { I18n, i18n } from '#user/lib/i18n'
  import HomonymDeduplicate from './homonym_deduplicate.svelte'

  export let entity

  let homonyms = [], flash
  const { hasDataadminAccess } = app.user

  const getHomonymsPromise = async () => homonyms = await getHomonymsEntities(entity)

  const checkAll = checked => homonyms = homonyms.map(homonym => ({ ...homonym, checked }))

  const mergeSelectedHomonyms = async () => {
    flash = null
    if (selectedHomonyms.length === 0) {
      flash = {
        type: 'warning',
        message: I18n('nothing')
      }
    }

    const homonymsPromises = selectedHomonyms.map(homonym => homonym.childEvents.merge())
    // TODO: merge sequentially 3 at a time
    await Promise.all(homonymsPromises)
  }

  $: selectedHomonyms = homonyms.filter(_.property('checked'))
</script>
{#if hasDataadminAccess}
  {#await getHomonymsPromise()}
    <div class="loading-wrapper">
      <p class="loading">{I18n('looking for duplicates...')}
        <Spinner center={true} />
      </p>
    </div>
  {:then}
  	<div class="dataadmin-section">
  	  <h3>
        {@html icon('compress')}
        {I18n('merge homonyms')}
      </h3>
      {#if isNonEmptyArray(homonyms)}
        <div class="merge-homonyms-controls">
          <button
            class="grey-button"
            on:click={() => checkAll(true)}
            name={I18n('select all')}
          >
            {I18n('select all')}
          </button>
          <button
            class="grey-button"
            on:click={() => checkAll(false) }
            name={I18n('unselect all')}
          >
            {I18n('unselect all')}
          </button>
          <button
            class="grey-button"
            disabled={selectedHomonyms.length === 0}
            title={selectedHomonyms.length === 0 ? I18n('no homonym selected') : ''}
            on:click={mergeSelectedHomonyms}
          >
            {@html icon('compress')}
            {I18n('merge selected suggestions')}
          </button>
          <Flash bind:state={flash}/>
        </div>
      {:else}
        <p>{i18n('no result')}</p>
      {/if}
  	  <div class='merge-homonyms'>
        {#each homonyms as homonym, i}
          {#if !homonym.merged}
            <HomonymDeduplicate
              bind:homonym={homonym}
              {entity}
              bind:this={homonyms[i].childEvents}
            />
          {/if}
        {:else}
          {i18n('has no homonym')}
        {/each}
      </div>
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
  .merge-homonyms-controls{
    padding: 1em;
  }
  .merge-homonyms{
    @include display-flex(row, center, center, wrap);
  }
  /*Large screens*/
  @media screen and (min-width: $small-screen) {
    .dataadmin-section{
      min-width: 30em;
    }
  }
</style>
