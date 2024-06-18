<script lang="ts">
  import { flip } from 'svelte/animate'
  import { pluck } from 'underscore'
  import app from '#app/app'
  import { isNonEmptyArray } from '#app/lib/boolean_tests'
  import Flash from '#app/lib/components/flash.svelte'
  import InfiniteScroll from '#components/infinite_scroll.svelte'
  import EntityAutocompleteSelector from '#entities/components/entity_autocomplete_selector.svelte'
  import { getEntitiesAttributesByUris, serializeEntity } from '#entities/lib/entities'
  import { addEntitiesImages } from '#entities/lib/types/work_alt'
  import Spinner from '#general/components/spinner.svelte'
  import { addElement } from '#listings/lib/listings'
  import { i18n, I18n } from '#user/lib/i18n'
  import ListingElement from './listing_element.svelte'

  export let elements = [], listingId, isEditable

  let flash, inputValue = '', showSuggestions

  let paginatedElements = []
  const paginationSize = 15
  let offset = 0
  let fetching, isReordering

  const assignEntitiesToElements = async elements => {
    const uris = pluck(elements, 'uri')
    const res = await getEntitiesAttributesByUris({
      uris,
      attributes: [ 'info', 'labels', 'claims', 'image' ],
      lang: app.user.lang,
    })
    const entitiesByUris = res.entities
    const entities = Object.values(entitiesByUris).map(serializeEntity)
    await addEntitiesImages(entities)
    for (const element of elements) {
      element.entity = entitiesByUris[element.uri]
    }
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
      elements = [ ...elements, ...createdElements ]
      fetchMore(true)
      return flash = {
        type: 'success',
        message: i18n('Added to the list'),
      }
    } catch (err) {
      flash = err
    }
  }

  $: hasMore = elements.length >= offset

  const fetchMore = async (isReset = false) => {
    fetching = true
    if (isReset) offset = 0
    const nextBatchElements = elements.slice(offset, offset + paginationSize)
    await assignEntitiesToElements(nextBatchElements)
    if (isNonEmptyArray(nextBatchElements)) {
      offset += paginationSize
      paginatedElements = isReset ? nextBatchElements : [ ...paginatedElements, ...nextBatchElements ]
    }
    fetching = false
  }

  const waitingForEntities = fetchMore()

  async function keepScrolling () {
    if (fetching || hasMore === false) return false
    await fetchMore()
    return true
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

    <InfiniteScroll {keepScrolling} showSpinner={true}>
      <ul class="listing-elements">
        {#await addingAnElement}
          <li class="loading">{I18n('loading')}<Spinner /></li>
        {/await}
        {#each paginatedElements as element (element.uri)}
          <li animate:flip={{ duration: 300 }}>
            <ListingElement
              {isEditable}
              bind:isReordering
              {element}
              {elements}
              {listingId}
              bind:paginatedElements
            />
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
  label{
    cursor: auto;
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
    .entities-selector{
      padding: 0 0.5em;
    }
    .entities-listing-section{
      padding: 0;
    }
  }
</style>
