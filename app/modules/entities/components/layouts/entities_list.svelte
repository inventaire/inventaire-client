<script lang="ts">
  import { flip } from 'svelte/animate'
  import type { SerializedEntitiesByUris, SerializedEntity } from '#entities/lib/entities'
  import type { EntityUri } from '#server/types/entity'
  import type { Item } from '#server/types/item'
  import EditionActions from './edition_actions.svelte'
  import EntityListRow from './entity_list_row.svelte'

  export let entities: SerializedEntity[]
  export let relatedEntities: SerializedEntitiesByUris = {}
  export let itemsByEditions: Record<EntityUri, Item[]> = {}
</script>
<ul>
  {#each entities as entity (entity.uri)}
    <li animate:flip={{ duration: 300 }}>
      <EntityListRow
        {entity}
        {relatedEntities}
      />
      <EditionActions
        {entity}
        {itemsByEditions}
      />
    </li>
  {/each}
</ul>
<style lang="scss">
  @use "#general/scss/utils";
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
  @media screen and (width >= $smaller-screen){
    li{
      padding: 0.5em;
      @include display-flex(row, center, space-between);
    }
  }
</style>
