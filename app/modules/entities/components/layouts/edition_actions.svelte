<script>
  import { i18n } from '#user/lib/i18n'
  import Link from '#lib/components/link.svelte'
  import { getCounterText } from '#entities/components/lib/edition_action_helpers'
  import { icon, loadInternalLink } from '#lib/utils'

  export let entity, itemsByEditions = {}

  const { uri, _id } = entity
  const url = `/entity/${uri}/add`

  // will break with #182 (remove edition from quarantine)
  const editionUri = `inv:${_id}`

  $: editionItems = itemsByEditions[editionUri]
</script>

<a
  href={url}
  on:click={loadInternalLink}
  class="action-button tiny-button"
  >
  {@html icon('plus') }
  {i18n('add to inventory')}
</a>

{#if itemsByEditions[uri]}
  <div class="link-wrapper">
    <!-- insert itemsLists deeplink -->
    <Link
      url={`/entity/${uri}`}
      text={getCounterText(editionItems)}
      dark={true}
    />
  </div>
{/if}
<style lang="scss">
  @import '#general/scss/utils';
  .action-button{
    @include tiny-button($light-blue);
    padding: 0.5em;
    white-space: nowrap;
  }
  .link-wrapper{
    padding: 1em 0.5em;
  }
</style>
