<script>
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { updateListing, deleteListing } from '#listings/lib/listings'
  import autosize from 'autosize'
  import Spinner from '#general/components/spinner.svelte'
  import Flash from '#lib/components/flash.svelte'
  import { createEventDispatcher } from 'svelte'
  import VisibilitySelector from '#inventory/components/visibility_selector.svelte'

  const dispatch = createEventDispatcher()

  export let listing

  let isValidating, flash
  const { _id } = listing
  let { name, description, visibility } = listing

  const validate = async () => {
    isValidating = true
    return updateListing({
      id: _id,
      name,
      description,
      visibility,
    })
    .then(listing => dispatch('listingUpdated', listing))
    .then(closeModal)
    .catch(err => {
      // Prefer to close modal anyway if no info have been updated,
      // since action is most likely motivated by escaping this context,
      // hence close modal.
      if (err.message === 'nothing to update') {
        return closeModal()
      }
      flash = err
    })
    .finally(() => isValidating = false)
  }

  async function askListDeletionConfirmation () {
    app.execute('ask:confirmation', {
      confirmationText: i18n('delete_list_confirmation', { name }),
      warningText: i18n('cant_undo_warning'),
      action: _deleteListing
    })
  }

  async function _deleteListing () {
    try {
      await deleteListing({ ids: _id })
      closeModal()
      app.execute('show:inventory:main:user', true)
    } catch (err) {
      flash = err
    }
  }

  const closeModal = () => app.execute('modal:close')
</script>
<div class="header">
  <h3>{I18n('edit list')}</h3>
</div>
<div class="field">
  <label for={name}>{i18n('name')}</label>
  <input
    placeholder={i18n('list name')}
    bind:value={name}
  />
</div>
<div class="field">
  <label for={description}>{i18n('description')}</label>
  <textarea
    type="text"
    bind:value={description}
    use:autosize
  />
</div>
<VisibilitySelector bind:visibility showTip={true} />
<div class="buttons">
  <button class="delete button"
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
    {#if isValidating}
      <p class="loading">
        <Spinner/>
      </p>
    {/if}
  </button>
</div>
<Flash bind:state={flash}/>

<style lang="scss">
  @import '#general/scss/utils';
  .header{
   @include display-flex(column, center);
   display: flex;
   width: 100%;
  }
  .field{
    @include display-flex(column, flex-start, center);
  }
  .buttons{
    margin-top: 1em;
    @include display-flex(row, center, center);
  }
  .delete{
    @include dangerous-action;
    margin-right: 1em;
  }
</style>
