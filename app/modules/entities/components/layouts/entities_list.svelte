<script>
  import { i18n } from '#user/lib/i18n'
  import EntityListElement from './entity_list_element.svelte'
  import WrapToggler from '#components/wrap_toggler.svelte'
  import EditionActions from './edition_actions.svelte'

  // type is optional
  export let type, entities, relatedEntities, parentEntity, itemsByEditions

  let showMore = false
  let shownEntities = entities
  let showLessSize = 4

  $: {
    if (showMore) shownEntities = entities
    else shownEntities = entities.slice(0, showLessSize)
  }
</script>
<ul>
  {#each shownEntities as entity (entity.uri)}
    <li>
      <EntityListElement
        {entity}
        {relatedEntities}
        {parentEntity}
      />
      <EditionActions
        {entity}
        {itemsByEditions}
      />
    </li>
  {/each}
</ul>
{#if entities.length > showLessSize}
  <div class="toggler-wrapper">
    <WrapToggler
      bind:show={showMore}
      moreText={i18n(`See more ${type}`)}
      lessText={i18n(`See less ${type}`)}
      remainingCounter={entities.length - shownEntities.length}
    />
  </div>
{/if}
<style lang="scss">
  @import '#general/scss/utils';
  ul{
    width: 100%;
    margin-top: 1em;
    margin: 1em 0 0.5em 0;
    @include radius;
  }
  li{
    border: 1px solid #ddd;
    background-color: white;
    margin: 0.3em 0;
  }
  .toggler-wrapper{
    padding: 0.3em;
  }
  /*Large screens*/
  @media screen and (min-width: $smaller-screen) {
    li{
      padding: 0.5em;
      @include display-flex(row, center, space-between);
    }
  }
</style>
