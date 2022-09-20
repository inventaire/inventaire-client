<script>
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { i18n, I18n } from '#user/lib/i18n'
  import Flash from '#lib/components/flash.svelte'
  import Spinner from '#general/components/spinner.svelte'
  import { getEntitiesAttributesByUris, serializeEntity } from '#entities/lib/entities'
  import { addElement, removeElement } from '#listings/lib/listings'
  import ListingElement from './listing_element.svelte'
  import EntityAutocompleteSelector from '#entities/components/entity_autocomplete_selector.svelte'
  import { pluck } from 'underscore'
  import { addEntitiesImages } from '#entities/lib/types/work_alt'

  export let elements, listingId, isEditable

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
      attributes: [ 'type', 'labels', 'descriptions', 'image' ],
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
    addingAnElement = addElement(listingId, entity.uri)
      .then(element => {
        if (isNonEmptyArray(element.alreadyInList)) {
          return flash = {
            type: 'info',
            message: I18n('entity is already in list')
          }
        }
        entities = [ entity, ...entities ]
      })
      .catch(err => flash = err)
  }

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
      const screenBottom = windowScrollY + window.visualViewport.height
      if (screenBottom + 100 > listingBottomEl.offsetTop) fetchMore()
    }
  }

  $: hasMore = entities.length >= offset
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
            searchTypes={'works'}
            placeholder={i18n('Search a work by title, author, or series')}
            autofocus={false}
            bind:currentEntityLabel={inputValue}
            bind:showSuggestions
            on:select={e => addUriAsElement(e.detail)}
          />
        </label>
        <Flash bind:state={flash}/>
      </div>
    {/if}

    <ul class="listing-elements">
      {#await addingAnElement}
        <li class="loading">{I18n('loading')}<Spinner/></li>
      {/await}
      <!-- TODO: iterate on elements docs to be able to pass other metadata (ids, comments, etc) -->
      {#each entities as entity, index (entity.uri)}
        <ListingElement
          {entity}
          {isEditable}
          on:removeElement={() => onRemoveElement(index)}
        />
      {:else}
        <li>{i18n('nothing here')}</li>
      {/each}
    </ul>
    {#if hasMore}
      <p bind:this={listingBottomEl}>
        {I18n('loading')}
        <Spinner/>
      </p>
    {/if}
  </section>
{/await}

<style lang="scss">
  @import '#general/scss/utils';
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
  .entities-selector{
    width: 100%;
    padding: 0 0.5em;
  }
  label{
    cursor:auto;
  }
  /*Large (>40em) screens*/
  @media screen and (min-width: 40em) {
    .entities-listing-section{
      width: 40em;
    }
  }
  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    .entities-listing-section{
      padding: 0;
    }
  }
</style>
