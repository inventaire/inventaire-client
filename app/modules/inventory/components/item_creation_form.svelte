<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { icon, loadInternalLink } from '#lib/utils'
  import Spinner from '#components/spinner.svelte'
  import { addNext, cancel, guessTransaction } from '#inventory/components/lib/item_creation_helpers'
  import TransactionSelector from '#inventory/components/transaction_selector.svelte'
  import VisibilitySelector from '#components/visibility_selector.svelte'
  import SelectShelves from '#inventory/components/importer/select_shelves.svelte'
  import Flash from '#lib/components/flash.svelte'
  import ItemRow from '#inventory/components/item_row.svelte'

  export let entity

  const { uri, label, pathname, image } = entity

  let flash

  let existingEntityItems
  const waitForExistingInstances = app.request('item:main:user:entity:items', uri)
    .then(itemsModels => existingEntityItems = itemsModels.map(model => model.toJSON()))
    .catch(err => flash = err)

  let transaction = guessTransaction()
  let visibility, shelvesIds, details, notes

  if (shelvesIds == null) shelvesIds = app.request('last:shelves:get')

  async function createItem () {
    try {
      app.execute('last:shelves:set', shelvesIds)
      await app.request('item:create', {
        entity: uri,
        transaction,
        visibility,
        details,
        notes,
        shelves: shelvesIds,
      })
    } catch (err) {
      flash = err
    }
  }

  async function validate () {
    await createItem()
    if (shelvesIds.length > 0) {
      app.execute('show:shelf', shelvesIds[0])
    } else {
      app.execute('show:inventory:main:user')
    }
  }

  async function validateAndAddNext () {
    await createItem()
    addNext()
  }
</script>

<div class="item-creation">
  <div class="entity-preview">
    {#if image.url}
      <div class="cover">
        <img src="{imgSrc(image.url, 300)}" alt="{label} {i18n('cover')}">
      </div>
    {/if}

    <div class="data">
      <h2><a href={pathname} on:click={loadInternalLink} class="link">{label}</a></h2>
      <p class="uri">{uri}</p>
      <!-- {PARTIAL 'entities:clamped_extract' this} -->
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
            <ItemRow {item} />
          {/each}
        </ul>
      </div>
    {/if}
  {/await}

  <form class="panel">
    <TransactionSelector bind:transaction />
    <VisibilitySelector bind:visibility />
    <SelectShelves bind:shelvesIds/>

    <label class="details">
      {I18n('details')}
      <textarea bind:value={details} placeholder="{I18n("details_placeholder")}"></textarea>
    </label>

    <label class="notes">
      {I18n('notes')}
      <span class="indicator" title="{I18n('notes_placeholder')}">{@html icon('lock')}</span>
      <textarea bind:value={notes} placeholder="{I18n('notes_placeholder')}"></textarea>
    </label>

    <div class="buttons">
      <button
        class="button grey"
        on:click={cancel}
        >
        {@html icon('ban')}
        {I18n('cancel')}
      </button>
      <button
        class="button success"
        on:click={validate}
        >
        {@html icon('check')}
        {I18n('validate')}
      </button>
      <button
        class="button secondary"
        on:click={validateAndAddNext}
        >
        {@html icon('plus')}
        {I18n('validate and add another book')}
      </button>
    </div>
  </form>

  <Flash state={flash} />
</div>

<style lang="scss">
  @import '#general/scss/utils';

  .item-creation{
    max-width: 50em;
    margin: 0 auto;
    /*Large screens*/
    @media screen and (min-width: $small-screen) {
      padding: 0em 1em 1em 1em;
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
    padding: 0.2em 1em 0.5em 1em;
    color: white;
  }

  .existing-entity-items-warning{
    padding: 1em 0;
    > p{
      color: red;
      font-weight: bold;
      margin-bottom: 0.5em;
    }
    ul{
      max-height: 8em;
      overflow: auto;
    }
  }

  .buttons{
    @include display-flex(row, center, center);
    button{
      margin: 0 0.5em;
    }
  }
</style>