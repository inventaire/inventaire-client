<script>
  import { flip } from 'svelte/animate'
  import { pluck } from 'underscore'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { i18n, I18n } from '#user/lib/i18n'
  import Flash from '#lib/components/flash.svelte'
  import Spinner from '#general/components/spinner.svelte'
  import { getEntitiesAttributesByUris, serializeEntity } from '#entities/lib/entities'
  import { addElement, removeElement } from '#listings/lib/listings'
  import ListingElement from './listing_element.svelte'
  import Reorder from './reorder.svelte'
  import EntityAutocompleteSelector from '#entities/components/entity_autocomplete_selector.svelte'
  import { addEntitiesImages } from '#entities/lib/types/work_alt'
  import { getViewportHeight } from '#lib/screen'
  import { icon } from '#lib/handlebars_helpers/icons'

  export let elements, listingId, isEditable, isReorderMode

  let flash, inputValue = '', showSuggestions
  let entities = []

  const paginationSize = 15
  let offset = paginationSize
  let fetching
  let windowScrollY = 0
  let listingBottomEl

  const getElementsEntities = async elements => {
    const uris = pluck(elements, 'uri')
    const res = await getEntitiesAttributesByUris({
      uris,
      attributes: [ 'info', 'labels', 'descriptions', 'image' ],
      lang: app.user.lang
    })
    const serializedEntities = Object.values(res.entities).map(serializeEntity)
    await addEntitiesImages(serializedEntities)
    return serializedEntities
  }

  const getInitialElementsEntities = async () => {
    const firstElements = elements.slice(0, paginationSize)
    entities = await getElementsEntities(firstElements)
  }

  const waitingForEntities = getInitialElementsEntities()

  const onRemoveElement = async index => {
    // TODO: replace the array index by the element doc _id
    const entity = entities[index]
    removeElement(listingId, entity.uri)
      .then(() => {
        // Enhancement: after remove, have an "undo" button
        entities.splice(index, 1)
        entities = entities
      })
      .catch(err => flash = err)
  }

  let addingAnElement
  const addUriAsElement = async entity => {
    flash = null
    inputValue = ''
    showSuggestions = false
    addingAnElement = _addUriAsElement(listingId, entity)
  }

  const _addUriAsElement = async (listingId, entity) => {
    try {
      const element = await addElement(listingId, entity.uri)
      if (isNonEmptyArray(element.alreadyInList)) {
        return flash = {
          type: 'info',
          message: i18n('This work is already in the list')
        }
      }
      entities = [ entity, ...entities ]
    } catch (err) {
      flash = err
    }
  }

  $: hasMore = entities.length >= offset

  const fetchMore = async () => {
    if (fetching || hasMore === false) return
    fetching = true
    const nextBatchElements = elements.slice(offset, offset + paginationSize)
    const nextEntities = await getElementsEntities(nextBatchElements)
    if (isNonEmptyArray(nextEntities)) {
      offset += paginationSize
      entities = [ ...entities, ...nextEntities ]
    }
    fetching = false
  }

  $: {
    if (listingBottomEl != null && hasMore) {
      const screenBottom = windowScrollY + getViewportHeight()
      if (screenBottom + 100 > listingBottomEl.offsetTop) fetchMore()
    }
  }
</script>
<svelte:window bind:scrollY={windowScrollY} />
{#await waitingForEntities}
  <Spinner center={true} />
{:then}
  <section class="entities-listing-section">
    {#if isEditable}
      <div class="entities-selector">
        <label for={inputValue}>
          {i18n('Add a work to this list')}
          <EntityAutocompleteSelector
            searchTypes={[ 'works', 'series' ]}
            placeholder={i18n('Search for works or series')}
            autofocus={false}
            bind:currentEntityLabel={inputValue}
            bind:showSuggestions
            on:select={e => addUriAsElement(e.detail)}
          />
        </label>
        <Flash bind:state={flash} />
      </div>
    {/if}

    {#if isReorderMode}
      <button
        on:click={() => isReorderMode = false}
        class="success-button tiny-button"
      >
        {@html icon('check')}
        {i18n('Reorder done')}
      </button>
    {/if}

    <ul class="listing-elements">
      {#await addingAnElement}
        <li class="loading">{I18n('loading')}<Spinner /></li>
      {/await}
      <!-- TODO: iterate on elements docs to be able to pass other metadata (ids, comments, etc) -->
      {#each entities as entity, index (entity.uri)}
        <li animate:flip={{ duration: 300 }}>
          <ListingElement {entity} />
          {#if isEditable && !isReorderMode}
            <div class="status">
              <button
                class="tiny-button"
                on:click={() => onRemoveElement(index)}
              >
                {i18n('remove')}
              </button>
            </div>
          {/if}
          {#if isReorderMode}
            <div class="reorder-wrapper">
              <Reorder
                bind:entities
                elementId={entity.uri}
                {index}
              />
            </div>
          {/if}
        </li>
      {:else}
        <li>{i18n('nothing here')}</li>
      {/each}
    </ul>
    {#if hasMore}
      <p bind:this={listingBottomEl}>
        {I18n('loading')}
        <Spinner />
      </p>
    {/if}
  </section>
{/await}

<style lang="scss">
  @import "#general/scss/utils";
  .entities-listing-section{
    flex: 1;
    align-self: center;
    @include display-flex(column, center);
    width: 100%;
    padding: 0 1em;
  }
  .listing-elements{
    @include display-flex(column, center);
    @include radius;
    width: 100%;
    margin: 1em 0;
    overflow: hidden;
  }
  li{
    @include display-flex(row, center);
    padding-inline-end: 0.5em;
    width: 100%;
    border-block-end: 1px solid $light-grey;
    @include bg-hover(white);
  }
  .success-button{
    margin-left: auto;
    padding: 0.2em 0.6em;
    margin-top: 1em;
    white-space: nowrap;
    line-height: 1.6em;
  }

  .entities-selector{
    width: 100%;
  }
  label{
    cursor: auto;
  }
  /* Large (>40em) screens */
  @media screen and (width >= 40em){
    .entities-listing-section{
      width: 40em;
    }
  }
  /* Small screens */
  @media screen and (max-width: $small-screen){
    .entities-listing-section{
      padding: 0;
    }
  }
  /* Very small screens */
  @media screen and (max-width: $very-small-screen){
    li{
      @include display-flex(column, flex-start);
    }
    .reorder-wrapper{
      width: 100%;
      align-items: center;
    }
  }
</style>
