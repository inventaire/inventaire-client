<script>
  import { i18n } from '#user/lib/i18n'
  import { icon, isOpenedOutside } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { serializeItem } from '#inventory/lib/items'
  import ItemShowModal from '#inventory/components/item_show_modal.svelte'
  import { addItemsToShelf, removeItemsFromShelf } from '#shelves/lib/shelves'
  import { without } from 'underscore'
  import Flash from '#lib/components/flash.svelte'

  export let item, shelfId

  const { image, details, title, authors, pathname } = serializeItem(item)

  let showItemModal
  function showItem (e) {
    if (isOpenedOutside(e)) return
    showItemModal = true
    e.preventDefault()
  }

  let flash

  async function addToShelf () {
    item.shelves = item.shelves.concat([ shelfId ])
    try {
      await addItemsToShelf({ shelfId, items: [ item ] })
    } catch (err) {
      flash = err
      item.shelves = without(item.shelves, shelfId)
    }
  }

  async function removeFromShelf () {
    item.shelves = without(item.shelves, shelfId)
    try {
      await removeItemsFromShelf({ shelfId, items: [ item ] })
    } catch (err) {
      flash = err
      item.shelves = item.shelves.concat([ shelfId ])
    }
  }

  $: alreadyAdded = item.shelves.includes(shelfId)
</script>

<li class="shelf-item-candidate">
  <a href={pathname} on:click={showItem} class="show-item">
    <div class="image-wrapper">
      {#if image}<img src={imgSrc(image, 128)} alt={title} />{/if}
    </div>
    <div class="info">
      <p class="title">{title}</p>
      <p class="authors">{authors}</p>
      {#if details}<p class="details">{details}</p>{/if}
    </div>
  </a>

  <div class="status">
    {#if alreadyAdded}
      <button
        class="tiny-button soft-grey remove"
        on:click={removeFromShelf}
      >
        {@html icon('minus')}
        {i18n('remove')}
      </button>
    {:else}
      <button
        class="tiny-button light-blue add"
        on:click={addToShelf}
      >
        {@html icon('plus')}
        {i18n('add')}
      </button>
    {/if}
    <div class="has-alertbox" />
  </div>

  <Flash state={flash} />
</li>

<ItemShowModal bind:item bind:showItemModal />

<style lang="scss">
  @import "#general/scss/utils";
  .shelf-item-candidate{
    background-color: #f3f3f3;
    padding: 0.5em;
    @include radius;
    @include display-flex(row, center, center);
    flex: 1 1 0;
    margin: 0.5em 0;
  }
  .show-item{
    flex: 1;
    overflow: hidden;
    @include display-flex(row, flex-start, center);
    margin: 0.5em;
    color: $dark-grey;
  }
  .info{
    overflow: hidden;
    padding: 0.5em;
    max-width: 25em;
    flex: 1 0 5em;
  }
  .image-wrapper:not(:empty){
    flex: 0 0 5em;
  }
  .title, .authors{
    margin-inline-end: 0.5em;
    flex: 0 0 auto;
  }
  .title{
    font-size: 1.1rem;
  }
  .authors{
    color: $grey;
  }
  .details{
    color: $grey;
    max-height: 1.4em;
    overflow-y: auto;
  }
  .status{
    @include display-flex(column);
  }
  .add, .remove{
    white-space: nowrap;
    flex: 0 0 auto;
  }
  /* Very Small screens */
  @media screen and (max-width: $smaller-screen){
    .show-item{
      @include display-flex(column, center, center);
    }
    .shelf-item-candidate{
      @include display-flex(column, center, center);
    }
  }
  /* Large screens */
  @media screen and (min-width: $smaller-screen){
    .status{
      margin-inline-start: auto;
    }
  }
</style>
