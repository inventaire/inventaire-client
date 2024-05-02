<script>
  import { clone } from 'underscore'
  import { icon } from '#app/lib/icons'
  import { moveArrayElement } from '#app/lib/utils'
  import Modal from '#components/modal.svelte'
  import Spinner from '#general/components/spinner.svelte'
  import { removeElement, updateElement, removeElementConfirmation } from '#listings/lib/listings'
  import ElementEditor from '#modules/listings/components/element_editor.svelte'
  import { i18n } from '#user/lib/i18n'

  export let isReordering, element, elements, listingId, flash

  let isLoading, isEditMode
  const { _id, uri } = element
  $: hasSeveralElements = elements.length > 1
  $: index = elements.findIndex(obj => obj.uri === uri)

  async function onRemoveElement (e) {
    const { comment } = e.detail
    const deletingData = {}
    if (comment) deletingData.commentElement = comment
    await removeElementConfirmation(_removeElement, deletingData)
  }

  async function _removeElement () {
    removeElement(listingId, uri)
      .then(() => {
        // Enhancement: after remove, have an "undo" button
        elements.splice(index, 1)
        elements = elements
      })
      .catch(err => flash = err)
  }

  async function reorder (newIndex) {
    isReordering = isLoading = true
    flash = null
    const oldElements = clone(elements)
    elements = moveArrayElement(elements, index, newIndex)
    const exclusiveOrdinal = newIndex + 1

    await updateElement({
      id: _id,
      ordinal: exclusiveOrdinal,
    })
      .then(() => {
        // isLoading could be moved before element update
        // to allow optismic UI, but make sure the server
        // can handle low bandwith update conflicts first.
        isReordering = isLoading = false
      })
      .catch(err => {
        flash = err
        elements = oldElements
      })
  }

  function toggleEditMode () {
    isEditMode = !isEditMode
  }
</script>
{#if isEditMode}
  <Modal on:closeModal={() => isEditMode = false}
  >
    <ElementEditor
      bind:element
      on:editorDone={toggleEditMode}
      on:removeElement={onRemoveElement}
    />
  </Modal>
{/if}

<div class="element-actions">
  <button
    class="edit-button tiny-button"
    on:click={toggleEditMode}
  >
    {@html icon('pencil')}
  </button>
  {#if hasSeveralElements}
    <div class="reorder-section">
      {#if index !== 0}
        <button
          disabled={isReordering}
          on:click={() => reorder(index - 1)}
          title={i18n('Move up')}
        >
          {@html icon('chevron-up')}
        </button>
      {/if}
      <div class="list-index">
        {#if isLoading}
          <Spinner />
        {:else}
          {index + 1}
        {/if}
      </div>
      {#if index !== elements.length - 1}
        <button
          disabled={isReordering}
          on:click={() => reorder(index + 1)}
          title={i18n('Move down')}
        >
          {@html icon('chevron-down')}
        </button>
      {/if}
    </div>

  {/if}
</div>
<style lang="scss">
  @import "#general/scss/utils";
  .reorder-section{
    @include display-flex(column, center);
    button{
      color: $grey;
    }
  }
  .element-actions{
    @include display-flex(row, center);
    margin: 0.3em;
  }
  .edit-button{
    margin: 1em;
    padding: 0.3em;
    color: $grey;
    background-color: $off-white;
  }
  .list-index{
    font-size: 1.3em;
  }
</style>
