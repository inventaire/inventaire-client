<script>
  import ItemsCascade from '#inventory/components/items_cascade.svelte'
  import app from '#app/app'
  import Spinner from '#components/spinner.svelte'
  import { screen } from '#lib/components/stores/screen'
  import ItemsTable from '#inventory/components/items_table.svelte'

  const params = {
    lang: app.user.lang,
    assertImage: true,
    items: [],
  }

  const waiting = app.request('items:getNearbyItems', params)
</script>

{#await waiting}
  <Spinner center={true} />
{:then}
  {#if $screen.isSmallerThan('$smaller-screen')}
    <ItemsTable items={params.items} {waiting} haveSeveralOwners={true} />
  {:else}
    <ItemsCascade items={params.items} {waiting} />
  {/if}
{/await}
