<script lang="ts">
  import { flip } from 'svelte/animate'
  import { pluck } from 'underscore'
  import app from '#app/app'
  import { isNonEmptyArray } from '#app/lib/boolean_tests'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import InfiniteScroll from '#components/infinite_scroll.svelte'
  import EntityAutocompleteSelector from '#entities/components/entity_autocomplete_selector.svelte'
  import { getEntitiesAttributesByUris, serializeEntity } from '#entities/lib/entities'
  import { addEntitiesImages } from '#entities/lib/types/work_alt'
  import Spinner from '#general/components/spinner.svelte'
  import { addElement, removeElement, reorder } from '#listings/lib/listings'
  import { i18n, I18n } from '#user/lib/i18n'
  import ListingElement from './listing_element.svelte'
  import Reorder from './reorder.svelte'

  export let elements = [], listingId, isEditable, isReorderMode, hasSeveralElements

  let flash, inputValue = '', showSuggestions

  let paginatedElements = []
  const paginationSize = 15
  let offset = 0
  let fetching, reordering

  const assignEntitiesToElements = async elements => {
    const uris = pluck(elements, 'uri')
    const res = await getEntitiesAttributesByUris({
      uris,
      attributes: [ 'info', 'labels', 'descriptions', 'image' ],
      lang: app.user.lang,
    })
    const entitiesByUris = res.entities
    const entities = Object.values(entitiesByUris).map(serializeEntity)
    await addEntitiesImages(entities)
    for (const element of elements) {
      element.entity = entitiesByUris[element.uri]
    }
  }

  const onRemoveElement = async element => {
    removeElement(listingId, element.uri)
      .then(() => {
        // Enhancement: after remove, have an "undo" button
        const index = paginatedElements.indexOf(element)
        paginatedElements.splice(index, 1)
        paginatedElements = paginatedElements
        elements.splice(index, 1)
        elements = elements
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
          message: i18n('This work is already in the list'),
        }
      }
      // Re fetch entities with fitting attributes.
      await assignEntitiesToElements(createdElements)
      paginatedElements = [ ...paginatedElements, ...createdElements ]
      elements = [ ...elements, ...createdElements ]
      return flash = {
        type: 'success',
        message: i18n('Added to the list'),
      }
    } catch (err) {
      flash = err
    }
  }

  $: hasMore = elements.length >= offset
  $: hasSeveralElements = elements.length > 1

  const fetchMore = async () => {
    const nextBatchElements = elements.slice(offset, offset + paginationSize)
    await assignEntitiesToElements(nextBatchElements)
    if (isNonEmptyArray(nextBatchElements)) {
      offset += paginationSize
      paginatedElements = [ ...paginatedElements, ...nextBatchElements ]
    }
  }

  function cancelReorderMode () {
    isReorderMode = false
  }

  function resetPagination () {
    offset = 0
    paginatedElements = []
    fetchMore()
  }

  const waitingForEntities = fetchMore()

  async function keepScrolling () {
    if (fetching || hasMore === false) return false
    await fetchMore()
    return true
  }

  const onReorder = async () => {
    reordering = true
    const uris = pluck(paginatedElements, 'uri')
    try {
      await reorder(listingId, uris)
      resetPagination()
      isReorderMode = false
    } catch (err) {
      flash = err
    }
    reordering = false
  }
</script>
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
      <div class="reorder-actions-wrapper">
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
        <button
          on:click={cancelReorderMode}
          class="tiny-button"
          disabled={reordering}
        >
          {@html icon('ban')}
          {I18n('cancel')}
        </button>
      </div>
    {/if}

    <InfiniteScroll {keepScrolling} showSpinner={true}>
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
                  class="tiny-button soft-grey"
                  on:click={() => onRemoveElement(element)}
                >
                  {i18n('remove')}
                </button>
              </div>
            {/if}
            {#if isReorderMode && !reordering}
              <div class="reorder-wrapper">
                <Reorder
                  bind:elements={paginatedElements}
                  elementId={element._id}
                />
              </div>
            {/if}
          </li>
        {:else}
          <li class="nothing-here">{i18n('nothing here')}</li>
        {/each}
      </ul>
    </InfiniteScroll>
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
    :global(.infinite-scroll-wrapper){
      width: 100%;
    }
  }
  .listing-elements{
    @include display-flex(column, center);
    @include radius;
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
    margin-inline-start: auto;
    margin-inline-end: 1em;
    padding: 0.2em 0.6em;
    margin-block-start: 1em;
    white-space: nowrap;
    line-height: 1.6em;
  }

  .entities-selector{
    width: 100%;
  }
  label{
    cursor: auto;
  }
  .reorder-actions-wrapper{
    @include display-flex(row, flex-end);
    width: 100%;
  }
  .nothing-here{
    width: unset;
    padding-inline-start: 0.5em;
  }
  /* Large screens */
  @media screen and (width > 40em){
    .entities-listing-section{
      width: 40em;
    }
  }
  /* Small screens */
  @media screen and (width < $small-screen){
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
