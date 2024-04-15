<script context="module" lang="ts">
  import type { EntityUri } from '#server/types/entity'
  import type { Item } from '#server/types/item'

  export type ItemsByEditions = Record<EntityUri, Item[]>

</script>
<script lang="ts">
  import { getOwnersCountPerEdition, getCounterText } from '#entities/components/lib/edition_action_helpers'
  import type { SerializedEntity } from '#entities/lib/entities'
  import Link from '#lib/components/link.svelte'
  import { I18n } from '#user/lib/i18n'

  export let entity: SerializedEntity
  export let itemsByEditions: ItemsByEditions = {}

  const { uri } = entity
  const url = `/entity/${uri}/add`

  $: editionItems = itemsByEditions[uri]
</script>

<div class="edition-actions">
  <div class="add-to-my-inventory">
    <Link
      {url}
      text={I18n('add to my inventory')}
      icon="plus"
      classNames="action-button tiny-button"
    />
  </div>
  {#if editionItems && getOwnersCountPerEdition(editionItems)}
    <div class="link-wrapper">
      <!-- insert itemsLists deeplink -->
      <Link
        url={`/entity/${uri}`}
        text={getCounterText(editionItems)}
        dark={true}
      />
    </div>
  {/if}
</div>
<style lang="scss">
  @import "#general/scss/utils";
  .edition-actions{
    @include display-flex(column, center, flex-end);
  }
  .add-to-my-inventory{
    :global(.action-button){
      @include tiny-button($light-blue);
      padding: 0.5em;
      white-space: nowrap;
    }
  }
  .link-wrapper{
    padding: 0.5em;
  }
  /* Small screens */
  @media screen and (max-width: $small-screen){
    .add-to-my-inventory{
      @include display-flex(row);
      margin-block-end: 0.5em;
    }
  }
</style>
