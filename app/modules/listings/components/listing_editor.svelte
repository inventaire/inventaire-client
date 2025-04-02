<script lang="ts">
  import autosize from 'autosize'
  import { createEventDispatcher } from 'svelte'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import Spinner from '#general/components/spinner.svelte'
  import { askConfirmation } from '#general/lib/confirmation_modal'
  import VisibilitySelector from '#inventory/components/visibility_selector.svelte'
  import { updateListing, deleteListing, createListing } from '#listings/lib/listings'
  import { showMainUserListings } from '#listings/listings'
  import { serializeListing } from '#modules/listings/lib/listings'
  import type { Listing } from '#server/types/listing'
  import { I18n, i18n } from '#user/lib/i18n'
  import { updateMainUserListingsCount } from '#user/lib/main_user'

  const dispatch = createEventDispatcher()

  export let listing: Listing = null
  export let layoutTitle = i18n('Edit list')

  let validating, flash
  let _id, name, description, visibility, type
  const listingTypesI18nKey = {
    work: 'work and series',
    author: 'P50',
    publisher: 'P123',
  }
  const listingTypes = Object.keys(listingTypesI18nKey)

  if (listing) {
    ;({ _id, name, description, visibility } = listing)
  }

  const validate = async () => {
    validating = _validate()
  }

  const _validate = async () => {
    try {
      if (_id) {
        await _updateListing()
      } else {
        await _createListing()
      }
      dispatch('listingEditorDone', listing)
    } catch (err) {
      flash = err
    }
  }

  async function _updateListing () {
    await updateListing({
      id: _id,
      name,
      description,
      visibility,
    })
    listing = Object.assign(listing, { name, description, visibility })
  }

  async function _createListing () {
    const res = await createListing({
      name,
      description,
      visibility,
      type,
    })
    listing = serializeListing(res.listing)
    updateMainUserListingsCount(1)
  }

  async function askListDeletionConfirmation () {
    askConfirmation({
      confirmationText: I18n('delete_list_confirmation', { name }),
      warningText: I18n('cant_undo_warning'),
      action: _deleteListing,
    })
  }

  async function _deleteListing () {
    try {
      await deleteListing({ ids: _id })
      updateMainUserListingsCount(-1)
      await showMainUserListings()
    } catch (err) {
      flash = err
    }
  }
</script>

<h3>{layoutTitle}</h3>
{#if !listing}
  <label>
    {i18n('List type')}
    <select
      name={i18n('listing type selector')}
      bind:value={type}
      class="listing-type"
    >
      {#each listingTypes as selectableType}
        <option value={selectableType}>
          {I18n(listingTypesI18nKey[selectableType])}
        </option>
      {/each}
    </select>
  </label>
{/if}
<label>
  {i18n('name')}
  <input
    type="text"
    placeholder={i18n('List name')}
    bind:value={name}
  />
</label>
<label>
  {I18n('description')}
  <textarea
    type="text"
    bind:value={description}
    use:autosize
  />
</label>
<div class="visibility-selector">
  <VisibilitySelector
    bind:visibility
    showTip={true}
  />
</div>
<div class="buttons">
  {#await validating}
    <Spinner />
  {:then}
    {#if listing}
      <button
        class="delete button"
        on:click={askListDeletionConfirmation}
      >
        {@html icon('trash')}
        {I18n('delete')}
      </button>
    {/if}
    <button
      class="validate button success-button"
      title={I18n('validate')}
      on:click={validate}
    >
      {@html icon('check')}
      {I18n('validate')}
    </button>
  {/await}
</div>
<Flash bind:state={flash} />

<style lang="scss">
  @import "#general/scss/utils";
  h3{
    text-align: center;
  }
  label{
    font-size: 1rem;
    margin-block-end: 0.2em;
  }
  .visibility-selector, .listing-type{
    margin-block-end: 1em;
  }
  .buttons{
    @include display-flex(row, center, center);
    margin-block-start: 2em;
    margin-block-end: 1em;
  }
  button{
    min-width: 10rem;
    margin: 0 0.5em;
  }
  .delete{
    @include dangerous-action;
  }
</style>
