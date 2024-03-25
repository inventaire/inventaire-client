<script>
  import { flip } from 'svelte/animate'
  import EditionActions from './edition_actions.svelte'
  import EntityListRow from './entity_list_row.svelte'

  export let entities, relatedEntities, parentEntity, itemsByEditions
</script>
<ul>
  {#each entities as entity (entity.uri)}
    <li animate:flip={{ duration: 300 }}>
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
<style lang="scss">
  @import "#general/scss/utils";
  ul{
    inline-size: 100%;
    margin: 1em 0 0.5em;
    @include radius;
    max-block-size: 70vh;
    overflow-y: auto;
  }
  li{
    background-color: white;
    margin: 0.3em 0;
  }
  /* Large screens */
  @media screen and (min-width: $smaller-screen){
    li{
      padding: 0.5em;
      @include display-flex(row, center, space-between);
    }
  }
</style>
