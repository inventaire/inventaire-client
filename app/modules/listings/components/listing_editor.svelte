<script>
  import app from '#app/app'
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

  let validating, flash
  const { _id } = listing
  let { name, description, visibility } = listing

  const validate = async () => {
    validating = _validate()
  }

  const _validate = async () => {
    try {
      await updateListing({
        id: _id,
        name,
        description,
        visibility,
      })
      listing = Object.assign(listing, { name, description, visibility })
      dispatch('listingEditorDone')
    } catch (err) {
      flash = err
    }
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
      app.user.trigger('listings:change', 'removeListing')
      app.execute('show:main:user:listings')
    } catch (err) {
      flash = err
    }
  }
</script>

<h3>{I18n('edit list')}</h3>
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
  bind:visibility={visibility}
  showTip={true}
/>
<div class="buttons">
  {#await validating}
    <Spinner/>
  {:then}
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
    </button>
  {/await}
</div>
<Flash bind:state={flash}/>

<style lang="scss">
  @import '#general/scss/utils';
  h3{
    text-align: center;
  }
  label{
    font-size: 1rem;
    margin-bottom: 0.2em;
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
