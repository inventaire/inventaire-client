<script>
  import Flash from '#lib/components/flash.svelte'
  import Spinner from '#components/spinner.svelte'
  import ListingsLayout from '#modules/listings/components/listings_layout.svelte'
  import { getListingsByCreators, serializeListing } from '#modules/listings/lib/listings'
  import { getAllGroupMembersIds } from '#groups/lib/groups'

  export let group

  let listings, flash

  const membersIds = getAllGroupMembersIds(group)

  const waitingForListings = getListingsByCreators(membersIds, true)
    .then(res => listings = res.listings.map(serializeListing))
    .catch(err => flash = err)
</script>

<div class="group-listings">
  {#await waitingForListings}
    <Spinner />
  {:then}
    <ListingsLayout listingsWithElements={listings} />
  {/await}
  <Flash state={flash} />
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .group-listings{
    margin: 0 auto;
    background-color: white;
    max-width: 60em;
    padding: 0.5em;
  }
</style>
