<script lang="ts">
  import { pluck } from 'underscore'
  import app from '#app/app'
  import { isNonEmptyArray } from '#app/lib/boolean_tests'
  import Flash from '#app/lib/components/flash.svelte'
  import { getViewportHeight } from '#app/lib/screen'
  import EntityAutocompleteSelector from '#entities/components/entity_autocomplete_selector.svelte'
  import { getEntitiesAttributesByUris, serializeEntity } from '#entities/lib/entities'
  import { addEntitiesImages } from '#entities/lib/types/work_alt'
  import Spinner from '#general/components/spinner.svelte'
  import { addElement, removeElement } from '#listings/lib/listings'
  import { i18n, I18n } from '#user/lib/i18n'
  import ListingElement from './listing_element.svelte'

  export let elements = [], listingId, isEditable

  let flash, inputValue = '', showSuggestions

  let paginatedElements = []
  const paginationSize = 15
  let offset = 0
  let fetching
  let windowScrollY = 0
  let listingBottomEl

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
      return flash = {
        type: 'success',
        message: i18n('Added to the list'),
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
    await assignEntitiesToElements(nextBatchElements)
    if (isNonEmptyArray(nextBatchElements)) {
      offset += paginationSize
      paginatedElements = [ ...paginatedElements, ...nextBatchElements ]
    }
    fetching = false
  }

  const waitingForEntities = fetchMore()

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

    <ul class="listing-elements">
      {#await addingAnElement}
        <li class="loading">{I18n('loading')}<Spinner /></li>
      {/await}
      {#each paginatedElements as element (element.uri)}
        <ListingElement
          entity={element.entity}
          {isEditable}
          on:removeElement={() => onRemoveElement(element)}
        />
      {:else}
        <li>{i18n('nothing here')}</li>
      {/each}
    </ul>
    {#if hasMore && isNonEmptyArray(elements)}
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
  @media screen and (width < $small-screen){
    .entities-listing-section{
      padding: 0;
    }
  }
</style>
