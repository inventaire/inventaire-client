<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import Link from '#lib/components/link.svelte'
  import Spinner from '#general/components/spinner.svelte'
  import { getListsByEntityUri } from '#lists/lib/lists'

  export let entity
  let lists = []

  const getLists = async () => {
    lists = await getListsByEntityUri(entity.uri) || []
  }

  const waitingForLists = getLists()
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
        <div class="list-element">
          <div class="top">
            <span class="label">{list.name}</span>
            <Link
              url={`/lists/${list._id}`}
              text={list.name}
            />
          </div>
          <div class="bottom">
            {#if list.description}<span class="description">{list.description}</span>{/if}
          </div>
        </div>
      {/each}
    {/await}
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .lists-layout{
    @include display-flex(column, center);
    background-color: $off-white;
    padding: 1em;
    margin: 1em 0;
  }
  h5{
    @include sans-serif;
    margin-bottom: 0;
  }
  .lists{
    width: 100%;
  }
  .list-element{
    @include display-flex(column, flex-start, flex-start, wrap);
  }
  .top{
    @include display-flex(row, center, flex-start, wrap);
  }
  .description{
    color: $grey;
    margin-right: 1em;
  }
</style>
