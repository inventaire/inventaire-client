<script>
  import { I18n } from '#user/lib/i18n'
  import EntityListElement from './entity_list_element.svelte'
  import WrapToggler from '#components/wrap_toggler.svelte'

  // type is optional
  export let type, entities, relatedEntities, parentEntity

  let showMore = false
  let shownEntities = entities
  let showLessSize = 4

  $: {
    if (showMore) shownEntities = entities
    else shownEntities = entities.slice(0, showLessSize)
  }
</script>
<div  class="entities-list">
  {#each shownEntities as entity (entity.uri)}
    <EntityListElement
      {entity}
      {relatedEntities}
      {parentEntity}
      actionType='link'
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
  .toggler-wrapper{
    @include display-flex(column, center, flex-start);
    padding: 0.3em;
  }
</style>
