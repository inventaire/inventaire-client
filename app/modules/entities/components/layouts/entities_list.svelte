<script>
  import { I18n } from '#user/lib/i18n'
  import EditionList from './edition_list.svelte'
  import WrapToggler from '#components/wrap_toggler.svelte'

  export let entities, relatedEntities, type

  const entityComponentsByType = { editions: EditionList }

  let showMore = false
  let shownEntities = entities
  let showLessSize = 4

  $: {
    if (showMore) shownEntities = entities
    else shownEntities = entities.slice(0, showLessSize)
  }
</script>
{#each shownEntities as entity (entity._id)}
  <div class="entity-list-wrapper">
    <svelte:component
      this={entityComponentsByType[type]}
      {entity}
      {relatedEntities}
    />
  </div>
{/each}
{#if entities.length > showLessSize}
  <div class="toggler-wrapper">
    <WrapToggler
      bind:show={showMore}
      moreText={I18n(`see more ${type}...`)}
      lessText={I18n(`see less ${type}`)}
    />
  </div>
{/if}

<style lang="scss">
  @import '#general/scss/utils';
  .toggler-wrapper{
    @include display-flex(column, center, flex-start);
    padding: 0.3em;
  }
  .entity-list-wrapper{
    padding: 0.3em 0;
    width: 100%;
    border-top: 1px solid #ddd;
  }

  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .entity-list{
      @include display-flex(column, center);
    }
  }
</style>
