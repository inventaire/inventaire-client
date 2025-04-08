<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import { icon } from '#app/lib/icons'
  import { BubbleUpComponentEvent } from '#app/lib/svelte/svelte'
  import type { ShelvesByIds } from '#app/types/shelf'
  import Modal from '#components/modal.svelte'
  import Spinner from '#components/spinner.svelte'
  import ItemRow from '#inventory/components/item_row.svelte'
  import ItemsTableSelectionEditor from '#inventory/components/items_table_selection_editor.svelte'
  import type { ItemId } from '#server/types/item'
  import type { ShelfId } from '#server/types/shelf'
  import { I18n, i18n } from '#user/lib/i18n'

  export let items
  export let itemsShelvesByIds: ShelvesByIds = null
  export let isMainUser = false
  export let shelfId: ShelfId = null
  export let itemsIds: ItemId[] = null
  export let waiting = null
  export let haveSeveralOwners = false

  let selectedItemsIds = []
  let showItemsTableSelectionEditor = false

  function selectAll () {
    selectedItemsIds = itemsIds
  }
  function unselectAll () {
    selectedItemsIds = []
  }

  $: emptySelection = selectedItemsIds.length === 0

  const dispatch = createEventDispatcher()
  const bubbleUpComponentEvent = BubbleUpComponentEvent(dispatch)

  function onUpdate (attribute, value) {
    const selectedItemsIdsSet = new Set(selectedItemsIds)
    items = items.map(item => {
      if (selectedItemsIdsSet.has(item._id)) {
        item[attribute] = value
      }
      return item
    })
  }

  function onDelete () {
    const selectedItemsIdsSet = new Set(selectedItemsIds)
    items = items.filter(item => !selectedItemsIdsSet.has(item._id))
  }
</script>

<div class="items-table">
  {#if isMainUser}
    <ul id="selectable-items">
      {#each items as item (item._id)}
        <li>
          <ItemRow
            bind:item
            {shelfId}
            shelvesByIds={itemsShelvesByIds}
            on:selectShelf={bubbleUpComponentEvent}
          >
            <input
              slot="checkbox"
              type="checkbox"
              bind:group={selectedItemsIds}
              value={item._id}
            />
          </ItemRow>
        </li>
      {/each}
    </ul>
  {:else}
    <ul>
      {#each items as item (item._id)}
        <li>
          <ItemRow
            {item}
            shelvesByIds={itemsShelvesByIds}
            showUser={haveSeveralOwners}
            on:selectShelf={bubbleUpComponentEvent}
          />
        </li>
      {/each}
    </ul>
  {/if}

  {#await waiting}<Spinner center={true} />{/await}

  {#if isMainUser}
    <div id="table-actions">
      <button
        id="selectAll"
        on:click={selectAll}
        aria-controls="selectable-items"
      >
        {@html icon('check-square-o')}
        <span class="button-label">{I18n('select all')}</span>
        <span class="count">({itemsIds.length})</span>
      </button>
      <button
        id="unselectAll"
        disabled={emptySelection}
        on:click={unselectAll}
        aria-controls="selectable-items"
      >
        {@html icon('square-o')}
        <span class="button-label">{I18n('unselect all')}</span>
      </button>
      <button
        id="editSelection"
        disabled={emptySelection}
        title={emptySelection ? i18n('You need to select items to be able to edit the selection') : null}
        on:click={() => showItemsTableSelectionEditor = true}
        aria-controls="selectable-items"
      >
        {@html icon('pencil')}
        <span class="button-label">{I18n('edit selection')}</span>
        {#if !emptySelection}
          <span class="count">({selectedItemsIds.length})</span>
        {/if}
      </button>
    </div>
  {/if}
</div>

{#if showItemsTableSelectionEditor}
  <Modal size="large" on:closeModal={() => showItemsTableSelectionEditor = false}>
    <ItemsTableSelectionEditor
      {selectedItemsIds}
      {onUpdate}
      {onDelete}
      onDone={() => showItemsTableSelectionEditor = false}
    />
  </Modal>
{/if}

<style lang="scss">
  @use "#general/scss/utils";
  .items-table{
    position: relative;
    background-color: $inventory-nav-grey;
  }
  #table-actions:not(.hidden){
    @include display-flex(row);
    background-color: $inventory-nav-grey;
    position: sticky;
    inset-block-end: 0;
    // Required for unclear reasons to allow dropdowns to appear
    // above .item-row elements
    z-index: 1;
    button{
      text-align: center;
      font-weight: bold;
      line-height: 1.6em;
    }
  }
  #selectAll, #unselectAll{
    @include bg-hover(white);
  }
  #editSelection{
    @include bg-hover($light-blue);
    &, .count{
      color: white;
    }
    &:disabled{
      background-color: white;
      color: $grey;
    }
  }
  ul{
    border: 1px solid #ddd;
    @include radius;
  }
  li:not(:last-child){
    border-block-end: 1px solid #ddd;
  }

  /* Medium and Large screens */
  @media screen and (width >= 800px){
    #table-actions:not(.hidden){
      padding: 0.5em;
    }
    button{
      padding: 0.5em 1em;
      margin: 0 0.5em;
    }
  }

  /* Small screens */
  @media screen and (width < 800px){
    #table-actions:not(.hidden){
      @include shy-border;
      align-items: stretch;
      flex-wrap: wrap;
    }
    #selectAll, #unselectAll, #editSelection{
      @include radius(0);
      padding: 0.5em 0;
    }
    #selectAll, #unselectAll{
      // Prefer to `width: 50%` to prevent horizontal scroll
      flex: 1 0 40%;
    }
    #editSelection{
      // Prefer to `width: 100%` to prevent horizontal scroll
      flex: 1 0 80%;
    }
    #selectAll .count{
      display: none;
    }
  }
</style>
