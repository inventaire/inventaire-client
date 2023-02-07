<script>
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import ItemRow from '#inventory/components/item_row.svelte'
  import ItemsTableSelectionEditor from '#inventory/components/items_table_selection_editor.svelte'
  import Spinner from '#components/spinner.svelte'

  export let items, isMainUser, itemsIds, waiting, haveSeveralOwners

  let selectedItemsIds = []

  function selectAll () {
    selectedItemsIds = itemsIds
  }
  function unselectAll () {
    selectedItemsIds = []
  }
  function editSelection () {
    app.layout.showChildComponent('modal', ItemsTableSelectionEditor, {
      props: {
        selectedItemsIds,
      }
    })
  }

  $: emptySelection = selectedItemsIds.length === 0
</script>

<div class="items-table">
  {#if isMainUser}
    <ul id="selectable-items">
      {#each items as item (item._id)}
        <li>
          <ItemRow bind:item>
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
        <li><ItemRow {item} showUser={haveSeveralOwners} /></li>
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
        on:click={editSelection}
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

<style lang="scss">
  @import "#general/scss/utils";
  .items-table{
    position: relative;
    background-color: $inventory-nav-grey;
  }
  #table-actions:not(.hidden){
    @include display-flex(row);
    background-color: $inventory-nav-grey;
    position: sticky;
    bottom: 0;
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
    border-bottom: 1px solid #ddd;
  }

  /* Medium and Large screens */
  @media screen and (min-width: 800px){
    #table-actions:not(.hidden){
      padding: 0.5em;
    }
    button{
      padding: 0.5em 1em;
      margin: 0 0.5em;
    }
  }

  /* Small screens */
  @media screen and (max-width: 800px){
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
