<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import ListLi from './list_li.svelte'
  import Spinner from '#general/components/spinner.svelte'
  import { getListsByEntityUri } from '#lists/lib/lists'

  export let entity, emptyLists
  let lists = []

  const getLists = async () => {
    const { uri } = entity
    if (uri) {
      lists = await getListsByEntityUri(uri) || []
    }
  }

  const waitingForLists = getLists()

  $: emptyLists = lists.length === 0
</script>

<div class="lists-layout">
  <h5>
    {I18n('lists with this entityType', { entityType: entity.type })}
  </h5>
  <div class="lists">
    {#await waitingForLists}
      <p class="loading">{I18n('loading')}<Spinner/></p>
    {:then}
      {#each lists as list}
        <ListLi {list} />
      {/each}
      {#if emptyLists}
        <div class="no-lists">
          {i18n('There is nothing here')}
        </div>
      {/if}
    {/await}
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .lists-layout{
    @include display-flex(column, center);
    background-color: $off-white;
    padding: 1em 0.5em;
    margin: 1em 0;
  }
  h5{
    @include sans-serif;
    margin-bottom: 0.5em;
  }
  .lists{
    @include display-flex(row, center);
    max-height: 42em;
    overflow-y: auto;
  }
  .loading{
    @include display-flex(column, center);
  }
  .no-lists{
    @include display-flex(row, center, center);
    color: $grey;
    margin-top: 1em;
  }
  /*Very small screens*/
  @media screen and (max-width: 700px) {
    .lists{
      @include display-flex(column, center);
    }
  }
</style>
