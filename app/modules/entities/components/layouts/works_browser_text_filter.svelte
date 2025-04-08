<script lang="ts">
  import { getContext } from 'svelte'
  import { debounce, pluck } from 'underscore'
  import { API } from '#app/api/api'
  import { icon } from '#app/lib/icons'
  import { getActionKey } from '#app/lib/key_events'
  import preq from '#app/lib/preq'
  import { onChange } from '#app/lib/svelte/svelte'
  import Spinner from '#components/spinner.svelte'
  import { I18n, i18n } from '#user/lib/i18n'

  export let textFilterUris

  const searchFilterClaim = getContext('search-filter-claim')
  const searchFilterTypes = getContext('search-filter-types')
  const canSearch = searchFilterClaim && searchFilterTypes

  let textFilter, waiting

  async function search () {
    if (textFilter == null || textFilter.trim().length === 0) {
      textFilterUris = null
      return
    }
    waiting = preq.get(API.search({
      types: searchFilterTypes,
      claim: searchFilterClaim,
      search: textFilter,
      limit: 100,
    }))
    const { results } = await waiting
    textFilterUris = pluck(results, 'uri')
  }

  const lazySearch = debounce(search, 200)

  $: onChange(textFilter, lazySearch)

  const reset = () => textFilter = ''

  function onKeyDown (e) {
    const key = getActionKey(e)
    if (key === 'esc') reset()
  }
</script>

{#if canSearch}
  <div class="works-browser-text-filter">
    <input
      type="text"
      placeholder={i18n('Filter…')}
      bind:value={textFilter}
      on:keydown={onKeyDown}
    />
    <div class="search-icon">
      {#await waiting}
        <Spinner />
      {:then}
        {#if textFilter}
          <button
            title={I18n('reset filter')}
            on:click={reset}
          >
            {@html icon('close')}
          </button>
        {:else}
          {@html icon('search')}
        {/if}
      {/await}
    </div>
  </div>
{/if}

<style lang="scss">
  @use "#general/scss/utils";
  .works-browser-text-filter{
    align-self: flex-end;
    position: relative;
  }
  .search-icon{
    position: absolute;
    inset-block: 0;
    inset-inline-end: 0.2em;
    @include display-flex(column, stretch, center);
    color: $grey;
    button{
      padding: 0.2em 0 0.2em 0.2em;
      margin: 0;
      @include shy;
    }
  }
  input{
    margin: 0;
    padding: 0 0.5em;
    block-size: 2.1rem;
    @include radius(2px);
  }
  /* Large screens */
  @media screen and (width >= $small-screen){
    .works-browser-text-filter{
      margin-inline-end: 1em;
    }
  }
</style>
