<script>
  import Flash from '#lib/components/flash.svelte'
  import Spinner from '#components/spinner.svelte'
  import ListingsLayout from '#modules/listings/components/listings_layout.svelte'
  import { getListingsByCreators, serializeListing } from '#modules/listings/lib/listings'
  import Modal from '#components/modal.svelte'
  import ListingEditor from '#listings/components/listing_editor.svelte'
  import { i18n } from '#user/lib/i18n'
  import { icon } from '#lib/handlebars_helpers/icons'

  export let user

  let listings, flash

  const waitingForListings = getListingsByCreators(user._id, true)
    .then(res => listings = res.listings.map(serializeListing))
    .catch(err => flash = err)

  const isMainUser = user._id === app.user.id

  let showListingCreationModal = false
  async function addNewListing (newListing) {
    try {
      showListingCreationModal = false
      listings = [ serializeListing(newListing), ...listings ]
    } catch (err) {
      flash = err
    }
  }
</script>

<div class="user-listings">
  {#await waitingForListings}
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
    <ListingsLayout
      listingsWithElements={listings}
      onUserLayout={true}
    />
  {/await}
  <Flash state={flash} />
</div>

{#if showListingCreationModal}
  <Modal
    on:closeModal={() => showListingCreationModal = false}
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
