<script>
  import Spinner from '#components/spinner.svelte'
  import getActionKey from '#lib/get_action_key'
  import { icon } from '#lib/handlebars_helpers/icons'
  import preq from '#lib/preq'
  import { onChange } from '#lib/svelte/svelte'
  import { I18n } from '#user/lib/i18n'
  import { getContext } from 'svelte'
  import { debounce, pluck } from 'underscore'

  export let textFilterItemsIds, flash

  const { ownerId, groupId, shelfId } = getContext('items-search-filters')

  let textFilter, waiting

  async function search () {
    try {
      if (!textFilter) {
        textFilterItemsIds = null
        return
      }
      const query = {
        search: textFilter,
        limit: 100,
      }
      if (groupId) query.group = groupId
      if (shelfId) query.shelf = shelfId
      else query.user = ownerId
      waiting = preq.get(app.API.items.search(query))
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

<style lang="scss">
  @import '#general/scss/utils';
  .wrapper{
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
    @include radius;
  }
</style>
