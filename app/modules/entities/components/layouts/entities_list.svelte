<script>
  import { i18n } from '#user/lib/i18n'
  import EntityListRow from './entity_list_row.svelte'
  import WrapToggler from '#components/wrap_toggler.svelte'
  import EditionActions from './edition_actions.svelte'

  export let type = 'editions', entities, relatedEntities, parentEntity, itemsByEditions

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
      <EntityListRow
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
  @import "#general/scss/utils";
  ul{
    inline-size: 100%;
    margin: 1em 0 0.5em;
    @include radius;
  }
  li{
    background-color: white;
    margin: 0.3em 0;
  }
  .toggler-wrapper{
    padding: 0.3em;
  }
  /* Large screens */
  @media screen and (min-width: $smaller-screen){
    li{
      padding: 0.5em;
      @include display-flex(row, center, space-between);
    }
  }
</style>
