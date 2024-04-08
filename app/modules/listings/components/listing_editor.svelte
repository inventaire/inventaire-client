<script lang="ts">
  import autosize from 'autosize'
  import { createEventDispatcher } from 'svelte'
  import app from '#app/app'
  import Spinner from '#general/components/spinner.svelte'
  import VisibilitySelector from '#inventory/components/visibility_selector.svelte'
  import Flash from '#lib/components/flash.svelte'
  import { icon } from '#lib/icons'
  import { updateListing, deleteListing, createListing } from '#listings/lib/listings'
  import { showMainUserListings } from '#listings/listings'
  import { serializeListing } from '#modules/listings/lib/listings'
  import { I18n, i18n } from '#user/lib/i18n'

  const dispatch = createEventDispatcher()

  export let listing = {}, layoutTitle = i18n('Edit list')

  let validating, flash
  const { _id } = listing
  let { name, description, visibility } = listing

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
      id: _id,
      name,
      description,
      visibility,
    })
    listing = serializeListing(res.listing)
    app.user.trigger('listings:change', 'createListing')
  }

  async function askListDeletionConfirmation () {
    app.execute('ask:confirmation', {
      confirmationText: i18n('delete_list_confirmation', { name }),
      warningText: i18n('cant_undo_warning'),
      action: _deleteListing,
    })
  }

  async function _deleteListing () {
    try {
      await deleteListing({ ids: _id })
      app.user.trigger('listings:change', 'removeListing')
      await showMainUserListings()
    } catch (err) {
      flash = err
    }
  }
</script>

<h3>{layoutTitle}</h3>
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
<VisibilitySelector
  bind:visibility
  showTip={true}
/>
<div class="buttons">
  {#await validating}
    <Spinner />
  {:then}
    <button
      class="delete button"
      on:click={askListDeletionConfirmation}
    >
      {@html icon('trash')}
      {I18n('delete')}
    </button>
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
  .buttons{
    margin-block-start: 1em;
    @include display-flex(row, center, center);
  }
  button{
    min-width: 10rem;
    margin: 0 0.5em;
  }
  .delete{
    @include dangerous-action;
  }
</style>
