<script lang="ts">
  import { getContext } from 'svelte'
  import { debounce, pluck } from 'underscore'
  import { API } from '#app/api/api'
  import { icon } from '#app/lib/icons'
  import { getActionKey } from '#app/lib/key_events'
  import preq from '#app/lib/preq'
  import { onChange } from '#app/lib/svelte/svelte'
  import Spinner from '#components/spinner.svelte'
  import type { ItemsSearchQuery } from '#server/types/api/items/search'
  import { I18n } from '#user/lib/i18n'
  import type { ItemsSearchFilters } from './inventory_browser.svelte'

  export let textFilterItemsIds, flash

  const { ownerId, groupId, shelfId } = getContext('items-search-filters') as ItemsSearchFilters

  let textFilter, waiting

  async function search () {
    try {
      if (!textFilter) {
        // Use 'undefined' rather than 'null', to not trigger reactive blocks
        // when the previous value was already undefined
        textFilterItemsIds = undefined
        return
      }
      const query: ItemsSearchQuery = {
        search: textFilter,
        limit: 100,
      }
      if (groupId) query.group = groupId
      if (shelfId) query.shelf = shelfId
      else query.user = ownerId
      waiting = preq.get(API.items.search(query))
      const { items } = await waiting
      textFilterItemsIds = pluck(items, '_id')
    } catch (err) {
      flash = err
    }
  }

  const lazySearch = debounce(search, 200)

  $: onChange(textFilter, lazySearch)

  const reset = () => textFilter = ''

  function onKeyDown (e) {
    const key = getActionKey(e)
    if (key === 'esc') reset()
  }
</script>

<div class="wrapper">
  <input
    type="text"
    placeholder={I18n('search_verb')}
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

<style lang="scss">
  @use "#general/scss/utils";
  .wrapper{
    align-self: flex-end;
    position: relative;
  }
  .search-icon{
    position: absolute;
    inset-inline-end: 0.5em;
    inset-block-start: 0.35em;
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
    @include radius;
  }
</style>
