<script>
  import { I18n } from '#user/lib/i18n'
  import ItemMixedBox from '#inventory/components/item_mixed_box.svelte'
  import ItemRequestBox from '#inventory/components/item_request_box.svelte'
  import ItemUserBox from '#inventory/components/item_user_box.svelte'
  import ItemTransactionBox from '#inventory/components/item_transaction_box.svelte'
  import ItemVisibilityBox from '#inventory/components/item_visibility_box.svelte'
  import ItemDetails from '#inventory/components/item_details.svelte'
  import ItemNotes from '#inventory/components/item_notes.svelte'

  export let item, user, flash

  const { mainUserIsOwner, details } = item
  $: isPrivate = item.visibility?.length === 0
</script>

<span class="section-label">{I18n('owner')}</span>

{#if mainUserIsOwner}
  <ItemUserBox {user} />
  <div class="item-settings">
    {#if !isPrivate}
      <ItemTransactionBox bind:item bind:flash large={true} />
    {/if}
    <ItemVisibilityBox bind:item bind:flash large={true} />
  </div>
  <ItemDetails bind:item bind:flash />
  <ItemNotes bind:item bind:flash />
{:else}
  <ItemMixedBox {item} />
  <ItemRequestBox {item} />
  {#if details}
    <ItemDetails bind:item bind:flash />
  {/if}
{/if}

<style lang="scss">
  @import '#general/scss/utils';
  .item-settings{
    margin: 1em 0;
    @include display-flex(row, center, center, wrap);
  }
</style>
