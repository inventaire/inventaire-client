<script>
  import { i18n } from '#user/lib/i18n'
  import { isOpenedOutside } from '#lib/utils'
  import Link from '#lib/components/link.svelte'
  import { getCounterText } from '#entities/components/lib/edition_action_helpers'

  export let entity, itemsByEditions

  const { uri, _id } = entity
  const url = `/entity/${uri}/add`

  // will break with #182 (remove edition from quarantine)
  const editionUri = `inv:${_id}`

  function onClick (e) {
    e.stopPropagation()
    if (!(isOpenedOutside(e))) {
      app.navigateAndLoad(url)
      e.preventDefault()
    }
  }
  $: editionItems = itemsByEditions[editionUri]
</script>
<button
  class="add action-button tiny-button"
  on:click={onClick}
>
  <Link
    {url}
    text={i18n('add to inventory')}
    light={true}
    icon='plus'
  />
</button>
{#if editionItems}
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
