<script lang="ts">
  import app from '#app/app'
  import { icon } from '#app/lib/icons'
  import Spinner from '#components/spinner.svelte'
  import ShelvesSelector from '#inventory/components/shelves_selector.svelte'
  import TransactionSelector from '#inventory/components/transaction_selector.svelte'
  import VisibilitySelector from '#inventory/components/visibility_selector.svelte'
  import { updateItems, deleteItems as _deleteItems } from '#inventory/lib/item_actions'
  import type { ItemId } from '#server/types/item'
  import { i18n, I18n } from '#user/lib/i18n'

  export let selectedItemsIds: ItemId[]
  export let onUpdate: (attribute: 'transaction' | 'visibility' | 'shelves', value: unknown) => void
  export let onDelete: () => void
  export let onDone: () => void

  let transaction, visibility, shelves, waitingForSave

  async function saveAttribute (attribute, value) {
    if (value != null) {
      await updateItems({
        items: selectedItemsIds,
        attribute,
        value,
      })
      onUpdate(attribute, value)
    }
  }

  async function save () {
    waitingForSave = _save()
    await waitingForSave
    onDone()
  }

  async function _save () {
    await saveAttribute('transaction', transaction)
    await saveAttribute('visibility', visibility)
    await saveAttribute('shelves', shelves)
  }

  async function deleteItems () {
    await _deleteItems({
      items: selectedItemsIds,
      next: () => {
        onDelete()
        onDone()
      },
      back: () => {
        app.execute('modal:close')
        onDone()
      },
    })
  }
</script>

<div class="items-table-selection-editor">
  <h3>
    {@html I18n('editing_selected_items', { smart_count: selectedItemsIds.length })}
  </h3>

  {#if transaction == null}
    <button
      class="editor-toggler"
      on:click={() => transaction = 'inventorying'}
    >
      {i18n('Edit items transaction')}
    </button>
  {:else}
    <div class="editor">
      <button
        class="editor-untoggler"
        title={I18n('cancel')}
        on:click={() => transaction = null}
      >
        {@html icon('close')}
      </button>
      <TransactionSelector bind:transaction />
    </div>
  {/if}

  {#if visibility == null}
    <button
      class="editor-toggler"
      on:click={() => visibility = []}
    >
      {i18n('Edit items visibility')}
    </button>
  {:else}
    <div class="editor">
      <button
        class="editor-untoggler"
        title={I18n('cancel')}
        on:click={() => visibility = null}
      >
        {@html icon('close')}
      </button>
      <VisibilitySelector bind:visibility />
    </div>
  {/if}

  {#if shelves == null}
    <button
      class="editor-toggler"
      on:click={() => shelves = []}
    >
      {i18n('Edit items shelves')}
    </button>
  {:else}
    <div class="editor">
      <button
        class="editor-untoggler"
        title={I18n('cancel')}
        on:click={() => shelves = null}
      >
        {@html icon('close')}
      </button>
      <ShelvesSelector bind:shelvesIds={shelves} />
    </div>
  {/if}

  <div class="buttons">
    <button
      class="cancel"
      disabled={waitingForSave != null}
      on:click={() => app.execute('modal:close')}
    >
      {@html icon('close')}
      <span>{I18n('cancel')}</span>
    </button>

    <button
      class="delete"
      disabled={waitingForSave != null}
      on:click={deleteItems}>
      {@html icon('trash-o')}
      <span>{I18n('delete')}</span>
    </button>

    <button
      class="done success-button"
      disabled={waitingForSave != null}
      on:click={save}
    >
      {#if waitingForSave}
        <Spinner />
      {:else}
        {@html icon('check')}
      {/if}
      <span>{I18n('save')}</span>
    </button>
  </div>
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .items-table-selection-editor{
    @include display-flex(column, center, center);
  }
  .editor-toggler, .editor{
    margin-block-end: 1em;
  }
  .editor-toggler{
    align-self: stretch;
    padding: 0.6em 0;
    @include bg-hover(#ddd);
  }
  .editor{
    align-self: stretch;
    background-color: $light-grey;
    padding: 0.5em;
    position: relative;
  }
  .editor-untoggler{
    position: absolute;
    inset-block-start: 0;
    inset-inline-end: 0.5rem;
    @include display-flex(row, center, center);
    width: 1em;
    @include shy(0.9);
    @include text-hover(#333, $dark-grey);
    :global(.fa){
      font-size: 1.4rem;
    }
  }
  .buttons button{
    font-weight: bold;
    padding: 0.7em;
    flex: 1;
  }
  .cancel{
    @include bg-hover(#ddd);
  }
  .delete{
    @include dangerous-action;
  }

  /* Small screens */
  @media screen and (width < $small-screen){
    .buttons{
      align-self: stretch;
      @include display-flex(column, stretch, center);
      > button{
        margin: 1em auto 0;
        width: 15em;
      }
    }
  }

  /* Large screens */
  @media screen and (width >= $small-screen){
    .buttons{
      @include display-flex(row, center, center);
      align-self: stretch;
      > button:not(:last-child){
        margin-inline-end: 0.5em;
      }
    }
  }
</style>
