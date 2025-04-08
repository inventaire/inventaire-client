<script lang="ts">
  import app from '#app/app'
  import { isNonEmptyArray } from '#app/lib/boolean_tests'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import { getViewportHeight, getViewportWidth } from '#app/lib/screen'
  import Modal from '#components/modal.svelte'
  import Spinner from '#components/spinner.svelte'
  import ListingEditor from '#listings/components/listing_editor.svelte'
  import ListingsLayout from '#modules/listings/components/listings_layout.svelte'
  import { getListingPathname, getListingsByCreators, serializeListing } from '#modules/listings/lib/listings'
  import type { Listing } from '#server/types/listing'
  import { i18n } from '#user/lib/i18n'
  import { mainUser } from '#user/lib/main_user'

  export let usersIds

  let listings = []
  let flash
  const paginationSize = Math.trunc(getViewportWidth() / 100) + 5
  let offset = paginationSize
  let fetching
  let windowScrollY = 0
  let listingBottomEl
  let hasMore = true

  const getNextListingsBatch = async (offset, limit) => {
    try {
      const { listings: newListings } = await getListingsByCreators({
        usersIds,
        withElements: true,
        limit,
        offset,
      })
      if (isNonEmptyArray(newListings)) {
        listings = [ ...listings, ...newListings.map(serializeListing) ]
        offset += paginationSize
      }
      if (newListings.length < paginationSize) hasMore = false
    } catch (err) {
      flash = err
    }
  }

  const waitingForInitialListings = getNextListingsBatch(0, paginationSize)

  const isMainUser = usersIds[0] === mainUser?._id

  let showListingCreationModal = false
  async function showNewListing (newListing: Listing) {
    try {
      showListingCreationModal = false
      app.navigateAndLoad(getListingPathname(newListing._id))
    } catch (err) {
      flash = err
    }
  }

  const fetchMore = async () => {
    if (fetching || hasMore === false) return
    fetching = true
    await getNextListingsBatch(offset, paginationSize)
    offset += paginationSize
    fetching = false
  }

  $: {
    if (listingBottomEl != null && hasMore) {
      const screenBottom = windowScrollY + getViewportHeight()
      if (screenBottom + 100 > listingBottomEl.offsetTop) fetchMore()
    }
  }
</script>
<svelte:window bind:scrollY={windowScrollY} />
<div class="user-listings">
  {#await waitingForInitialListings}
    <Spinner />
  {:then}
    {#if isMainUser}
      <div class="controls">
        <button
          on:click={() => showListingCreationModal = true}
          class="tiny-button light-blue"
        >
          {@html icon('plus')}
          {i18n('Create a new list')}
        </button>
      </div>
    {/if}
    <ListingsLayout {listings} />
    {#if hasMore}
      <p bind:this={listingBottomEl}>
        <Spinner center={true} />
      </p>
    {/if}
  {/await}
  <Flash state={flash} />
</div>

{#if showListingCreationModal}
  <Modal on:closeModal={() => showListingCreationModal = false}
  >
    <ListingEditor
      layoutTitle={i18n('Create a new list')}
      on:listingEditorDone={e => showNewListing(e.detail)}
    />
  </Modal>
{/if}

<style lang="scss">
  @use "#general/scss/utils";
  .user-listings{
    margin: 0 auto;
    padding: 0.5em;
  }
  .controls{
    @include display-flex(row, flex-end, flex-end);
    flex: 1 0 auto;
    margin-inline-end: 0.7em;
    margin-block-end: 0.5em;
    button{
      margin: 0;
    }
  }
  /* Small screens */
  @media screen and (width < $small-screen){
    .user-listings{
      padding: 0.5em 0;
    }
  }
</style>
