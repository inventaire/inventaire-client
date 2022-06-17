<script>
  import { I18n } from '#user/lib/i18n'
  import EditionList from './edition_list.svelte'
  import WrapToggler from '#components/wrap_toggler.svelte'

  // type is optional
  export let type, entities, relatedEntities, compactView

  let showMore = false
  let shownEntities = entities
  let showLessSize = 4

  const entityComponentsByType = { editions: EditionList }

  $: {
    if (showMore) shownEntities = entities
    else shownEntities = entities.slice(0, showLessSize)
  }
</script>
<div
  class="entities-list"
  class:compactView={compactView}
>
  {#each shownEntities as entity (entity._id)}
    <svelte:component
      this={entityComponentsByType[type] || EditionList}
      {entity}
      {relatedEntities}
      {compactView}
    />
  {/each}
</div>
{#if entities.length > showLessSize}
  <div class="toggler-wrapper">
    <WrapToggler
      bind:show={showMore}
      moreText={I18n(`see more ${type}`)}
      lessText={I18n(`see less ${type}`)}
    />
  </div>
{/if}

<style lang="scss">
  @import '#general/scss/utils';
  .entities-list{
    width: 100%;
  }
  .compactView{
    @include display-flex(row, center, center);
  }
  .toggler-wrapper{
    @include display-flex(column, center, flex-start);
    padding: 0.3em;
  }
</style>
