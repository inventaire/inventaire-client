<script>
  import Spinner from '#components/spinner.svelte'
  import getActionKey from '#lib/get_action_key'
  import { icon } from '#lib/handlebars_helpers/icons'
  import preq from '#lib/preq'
  import { onChange } from '#lib/svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import { getContext } from 'svelte'
  import { debounce, pluck } from 'underscore'

  export let textFilterUris

  const searchFilterClaim = getContext('search-filter-claim')
  const searchFilterTypes = getContext('search-filter-types')
  const canSearch = searchFilterClaim && searchFilterTypes

  let textFilter, waiting

  async function search () {
    if (!textFilter) {
      textFilterUris = null
      return
    }
    waiting = preq.get(app.API.search({
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
      placeholder={i18n('Filter...')}
      bind:value={textFilter}
      on:keydown={onKeyDown}
    >
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
  @import '#general/scss/utils';
  .works-browser-text-filter{
    align-self: flex-end;
    position: relative;
  }
  .search-icon{
    position: absolute;
    right: 0.5em;
    top: 0.35em;
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
    height: 2.1rem;
    @include radius(2em);
  }
  /*Large screens*/
  @media screen and (min-width: $small-screen) {
    .works-browser-text-filter{
      margin-right: 1em;
    }
  }
</style>
