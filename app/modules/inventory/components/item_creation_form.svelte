<script lang="ts">
  import app from '#app/app'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import { imgSrc } from '#app/lib/image_source'
  import { loadInternalLink } from '#app/lib/utils'
  import Spinner from '#components/spinner.svelte'
  import type { SerializedEntity } from '#entities/lib/entities'
  import ItemRow from '#inventory/components/item_row.svelte'
  import { addNext, cancel } from '#inventory/components/lib/item_creation_helpers'
  import ShelvesSelector from '#inventory/components/shelves_selector.svelte'
  import TransactionSelector from '#inventory/components/transaction_selector.svelte'
  import VisibilitySelector from '#inventory/components/visibility_selector.svelte'
  import { getLastShelves, setLastShelves, setLastTransaction, setLastVisbility } from '#inventory/lib/add_helpers'
  import { createItem as _createItem } from '#inventory/lib/item_actions'
  import { showShelf } from '#shelves/shelves'
  import { i18n, I18n } from '#user/lib/i18n'
  import { getItemsByUserIdAndEntities } from '../lib/queries'

  export let entity: SerializedEntity

  const { uri, label, pathname, image } = entity

  let flash

  let existingEntityItems
  const waitForExistingInstances = getItemsByUserIdAndEntities(app.user._id, uri)
    .then(items => existingEntityItems = items)
    .catch(err => flash = err)

  let transaction, visibility, shelvesIds, details, notes

  if (shelvesIds == null) shelvesIds = getLastShelves()

  async function createItem () {
    setLastShelves(shelvesIds)
    setLastTransaction(transaction)
    setLastVisbility(visibility)
    await _createItem({
      entity: uri,
      transaction,
      visibility,
      details,
      notes,
      shelves: shelvesIds,
    })
  }

  let validating
  async function validate () {
    try {
      validating = createItem()
      await validating
      if (shelvesIds.length > 0) {
        showShelf(shelvesIds[0])
      } else {
        app.execute('show:inventory:main:user')
      }
    } catch (err) {
      flash = err
    }
  }

  let validatingBeforeAddingNext
  async function validateAndAddNext () {
    try {
      validatingBeforeAddingNext = createItem()
      await validatingBeforeAddingNext
      addNext()
    } catch (err) {
      flash = err
    }
  }

  $: disableButtons = validating || validatingBeforeAddingNext
</script>

<div class="item-creation">
  <div class="entity-preview">
    {#if image.url}
      <div class="cover">
        <img src={imgSrc(image.url, 300)} alt="" />
      </div>
    {/if}

    <div class="data">
      <h2><a href={pathname} on:click|stopPropagation={loadInternalLink} class="link">{label}</a></h2>
      <p class="uri">{uri}</p>
    </div>
  </div>

  {#await waitForExistingInstances}
    <Spinner />
  {:then}
    {#if existingEntityItems.length > 0}
      <div class="existing-entity-items-warning">
        <p>{@html icon('warning')} {i18n('You already have this book in your inventory:')}</p>
        <ul>
          {#each existingEntityItems as item}
            <li>
              <ItemRow {item} />
            </li>
          {/each}
        </ul>
      </div>
    {/if}
  {/await}

  <form class="panel">
    <TransactionSelector bind:transaction showDescription={true} />
    <VisibilitySelector bind:visibility showDescription={true} showTip={true} />
    <ShelvesSelector bind:shelvesIds showDescription={true} />

    <label class="details">
      {I18n('details')}
      <textarea bind:value={details} placeholder={I18n('details_placeholder')} />
    </label>

    <label class="notes">
      {I18n('notes')}
      <span class="indicator" title={I18n('notes_placeholder')}>{@html icon('lock')}</span>
      <textarea bind:value={notes} placeholder={I18n('notes_placeholder')} />
    </label>

    <Flash state={flash} />

    <div class="buttons">
      <button
        class="button grey"
        disabled={disableButtons}
        on:click={cancel}
      >
        {@html icon('ban')}
        {I18n('cancel')}
      </button>

      <button
        class="button success"
        on:click={validate}
        disabled={disableButtons}
      >
        {#await validating}
          <Spinner light={true} />
        {:then}
          {@html icon('check')}
        {/await}
        {I18n('validate')}
      </button>

      <button
        class="button secondary"
        on:click={validateAndAddNext}
        disabled={disableButtons}
      >
        {#await validatingBeforeAddingNext}
          <Spinner light={true} />
        {:then}
          {@html icon('plus')}
        {/await}
        {I18n('validate and add another book')}
      </button>
    </div>
  </form>
</div>

<style lang="scss">
  @import "#general/scss/utils";

  .item-creation{
    max-width: 50em;
    margin: 0 auto;
    /* Large screens */
    @media screen and (width >= $small-screen){
      padding: 0 1em 1em;
    }
  }

  .panel{
    @include panel;
    :global(fieldset){
      margin-block-end: 1em;
    }
    :global(label.details), :global(label.notes){
      font-size: 1rem;
    }
  }

  .entity-preview{
    @include display-flex(row);
    .data{
      padding: 1em;
    }
  }

  label{
    display: block;
    margin: 1em 0;
  }

  label.notes{
    background-color: $dark-grey;
    @include radius;
    margin: 1em 0;
    padding: 0.2em 0 1em;
    padding: 0.2em 1em 0.5em;
    color: white;
  }

  .existing-entity-items-warning{
    padding: 1em 0;
    > p{
      color: red;
      font-weight: bold;
      margin-block-end: 0.5em;
    }
    ul{
      max-height: 8em;
      overflow: auto;
    }
  }

  .buttons{
    @include display-flex(row, center, center);
    button{
      margin: 0.5em;
    }
  }
</style>
