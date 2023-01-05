<script>
  import { i18n } from '#user/lib/i18n'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import Flash from '#lib/components/flash.svelte'
  import Spinner from '#components/spinner.svelte'
  import ListingsLayout from '#modules/listings/components/listings_layout.svelte'
  import { getListingsByCreators, serializeListing } from '#modules/listings/lib/listings'
  import Modal from '#components/modal.svelte'
  import ListingEditor from '#listings/components/listing_editor.svelte'
  import { icon } from '#lib/handlebars_helpers/icons'

  export let usersIds, onUserLayout

  let listings = []
  let flash
  const paginationSize = 15
  let offset = paginationSize
  let fetching
  let windowScrollY = 0
  let listingBottomEl
  let hasMore = true

  const getNextListingsBatch = async (offset, limit) => {
    try {
      const { listings: newListings } = await getListingsByCreators({
        creatorsIds: usersIds,
        withElements: true,
        limit,
        offset
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

  const isMainUser = usersIds[0] === app.user.id

  let showListingCreationModal = false
  async function addNewListing (newListing) {
    try {
      showListingCreationModal = false
      listings = [ serializeListing(newListing), ...listings ]
    } catch (err) {
      flash = err
    }
  }

  const fetchMore = async () => {
    if (fetching || hasMore === false) return
    fetching = true
    const nextListings = await getNextListingsBatch(offset, paginationSize)
    if (isNonEmptyArray(nextListings)) {
      listings = [ ...listings, ...nextListings ]
    }
    offset += paginationSize
    fetching = false
  }
  $: {
    if (listingBottomEl != null && hasMore) {
      const screenBottom = windowScrollY + window.visualViewport.height
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
    <ListingsLayout {listings} {onUserLayout} />
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
      on:listingEditorDone={e => addNewListing(e.detail)}
    />
  </Modal>
{/if}

<style lang="scss">
  @import '#general/scss/utils';
  .user-listings{
    margin: 0 auto;
    padding: 0.5em;
  }
  .controls{
    @include display-flex(row, flex-end, flex-end);
    flex: 1 0 auto;
    margin-right: 0.7em;
    margin-bottom: 0.5em;
    button{
      margin: 0;
    }
  }
  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    .user-listings{
      padding: 0.5em 0;
    }
  }
</style>
