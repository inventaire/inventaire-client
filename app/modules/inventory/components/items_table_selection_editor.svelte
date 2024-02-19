<script>
  import app from '#app/app'
  import { i18n, I18n } from '#user/lib/i18n'
  import { icon } from '#lib/icons'
  import VisibilitySelector from '#inventory/components/visibility_selector.svelte'
  import TransactionSelector from '#inventory/components/transaction_selector.svelte'
  import ShelvesSelector from '#inventory/components/shelves_selector.svelte'
  import Spinner from '#components/spinner.svelte'

  app.execute('modal:open', 'large')

  export let selectedItemsIds

  let transaction, visibility, shelves, waitingForSave

  async function saveAttribute (attribute, value) {
    if (value != null) {
      await app.request('items:update', {
        items: selectedItemsIds,
        attribute,
        value,
      })
    }
  }

  async function save () {
    waitingForSave = _save()
    await waitingForSave
    app.execute('modal:close')
  }

  async function _save () {
    await saveAttribute('transaction', transaction)
    await saveAttribute('visibility', visibility)
    await saveAttribute('shelves', shelves)
  }

  function deleteItems () {
    app.request('items:delete', {
      items: selectedItemsIds,
      next: () => {
        // Force a refresh of the inventory, so that the deleted item doesn't appear
        app.execute('show:inventory:main:user')
      },
      back: () => {
        app.execute('modal:close')
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
      on:click={e => transaction = 'inventorying'}
    >
      {i18n('Edit items transaction')}
    </button>
  {:else}
    <div class="editor">
      <button
        class="editor-untoggler"
        title={I18n('cancel')}
        on:click={e => transaction = null}
      >
        {@html icon('close')}
      </button>
      <TransactionSelector bind:transaction />
    </div>
  {/if}

  {#if visibility == null}
    <button
      class="editor-toggler"
      on:click={e => visibility = []}
    >
      {i18n('Edit items visibility')}
    </button>
  {:else}
    <div class="editor">
      <button
        class="editor-untoggler"
        title={I18n('cancel')}
        on:click={e => visibility = null}
      >
        {@html icon('close')}
      </button>
      <VisibilitySelector bind:visibility />
    </div>
  {/if}

  {#if shelves == null}
    <button
      class="editor-toggler"
      on:click={e => shelves = []}
    >
      {i18n('Edit items shelves')}
    </button>
  {:else}
    <div class="editor">
      <button
        class="editor-untoggler"
        title={I18n('cancel')}
        on:click={e => shelves = null}
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
  @media screen and (max-width: $small-screen){
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
  @media screen and (min-width: $small-screen){
    .buttons{
      @include display-flex(row, center, center);
      align-self: stretch;
      > button:not(:last-child){
        margin-inline-end: 0.5em;
      }
    }
  }
</style>
