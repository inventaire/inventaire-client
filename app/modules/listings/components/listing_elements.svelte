<script>
  import { flip } from 'svelte/animate'
  import { pluck } from 'underscore'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { i18n, I18n } from '#user/lib/i18n'
  import Flash from '#lib/components/flash.svelte'
  import Spinner from '#general/components/spinner.svelte'
  import { getEntitiesAttributesByUris, serializeEntity } from '#entities/lib/entities'
  import { addElement, removeElement, reorder } from '#listings/lib/listings'
  import ListingElement from './listing_element.svelte'
  import Reorder from './reorder.svelte'
  import EntityAutocompleteSelector from '#entities/components/entity_autocomplete_selector.svelte'
  import { addEntitiesImages } from '#entities/lib/types/work_alt'
  import { getViewportHeight } from '#lib/screen'
  import { icon } from '#lib/handlebars_helpers/icons'

  export let elements = [], listingId, isEditable, isReorderMode

  let flash, inputValue = '', showSuggestions
  let paginatedElements = []

  const paginationSize = 15
  let offset = paginationSize
  let fetching, reordering
  let windowScrollY = 0
  let listingBottomEl

  const serializeElements = async elements => {
    const uris = pluck(elements, 'uri')
    const res = await getEntitiesAttributesByUris({
      uris,
      attributes: [ 'info', 'labels', 'descriptions', 'image' ],
      lang: app.user.lang
    })
    const serializedEntities = Object.values(res.entities).map(serializeEntity)
    await addEntitiesImages(serializedEntities)
    elements.forEach(assignEntityToElement(serializedEntities))
  }

  const getInitialElementsEntities = async () => {
    const firstElements = elements.slice(0, paginationSize)
    await serializeElements(firstElements)
    paginatedElements = firstElements
  }

  const assignEntityToElement = entities => element => {
    const entity = entities.find(entity => entity.uri === element.uri)
    if (entity) element.entity = entity
  }

  const waitingForEntities = getInitialElementsEntities()

  const onRemoveElement = async element => {
    removeElement(listingId, element.uri)
      .then(() => {
        // Enhancement: after remove, have an "undo" button.
        // But it needs to find a way to retrieve the deleted doc
        // especially if other data belong to the element (ie. comments)
        // Having confirmation modal may be easier.
        const index = paginatedElements.indexOf(element)
        paginatedElements.splice(index, 1)
        paginatedElements = paginatedElements
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
      const { createdElements, alreadyInList } = await addElement(listingId, entity.uri)
      if (isNonEmptyArray(alreadyInList)) {
        return flash = {
          type: 'info',
          message: i18n('This work is already in the list')
        }
      }
      await serializeElements(createdElements)
      paginatedElements = [ ...paginatedElements, ...createdElements ]
      return flash = {
        type: 'success',
        message: i18n('Successfully added to the list')
      }
    } catch (err) {
      flash = err
    }
  }

  $: hasMore = elements.length >= offset

  const fetchMore = async () => {
    if (fetching || hasMore === false) return
    fetching = true
    const nextBatchElements = elements.slice(offset, offset + paginationSize)
    await serializeElements(nextBatchElements)
    if (isNonEmptyArray(nextBatchElements)) {
      offset += paginationSize
      paginatedElements = [ ...paginatedElements, ...nextBatchElements ]
    }
    fetching = false
  }

  const onReorder = async () => {
    reordering = true
    const uris = pluck(paginatedElements, 'uri')
    try {
      await reorder(listingId, uris)
      isReorderMode = false
    } catch (err) {
      flash = err
    }
    reordering = false
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
        on:click={onReorder}
        class="success-button tiny-button"
        disabled={reordering}
      >
        {#if reordering}
          {I18n('loading')}
          <Spinner />
        {:else}
          {@html icon('check')}
          {i18n('Done')}
        {/if}
      </button>
    {/if}

    <ul class="listing-elements">
      {#await addingAnElement}
        <li class="loading">{I18n('loading')}<Spinner /></li>
      {/await}
      {#each paginatedElements as element (element.uri)}
        <li animate:flip={{ duration: 300 }}>
          <ListingElement entity={element.entity} />
          {#if isEditable && !isReorderMode}
            <div class="status">
              <button
                class="tiny-button"
                on:click={() => onRemoveElement(element)}
              >
                {i18n('remove')}
              </button>
            </div>
          {/if}
          {#if isReorderMode}
            <div class="reorder-wrapper">
              <Reorder
                bind:elements={paginatedElements}
                elementId={element._id}
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
  /* Large screens */
  @media screen and (width > 40em){
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
