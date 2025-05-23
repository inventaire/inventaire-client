<script lang="ts">
  import { debounce, uniq, indexBy } from 'underscore'
  import { isNonEmptyArray } from '#app/lib/boolean_tests'
  import Flash from '#app/lib/components/flash.svelte'
  import { onScrollToBottom } from '#app/lib/screen'
  import { onChange } from '#app/lib/svelte/svelte'
  import { forceArray } from '#app/lib/utils'
  import Spinner from '#components/spinner.svelte'
  import RelativeEntityLayout from '#entities/components/layouts/relative_entity_layout.svelte'
  import SectionLabel from '#entities/components/layouts/section_label.svelte'
  import { getEntitiesAttributesByUris, getReverseClaims, serializeEntity, type SerializedEntity } from '#entities/lib/entities'
  import { entityDataShouldBeRefreshed } from '#entities/lib/entity_refresh'
  import { addEntitiesImages } from '#entities/lib/types/work_alt'
  import type { PropertyUri } from '#server/types/entity'
  import { getCurrentLang, i18n } from '#user/lib/i18n'

  export let entity: SerializedEntity
  export let property: PropertyUri
  export let label: string
  export let claims = null

  let flash
  let uris

  const { uri } = entity

  async function getUris () {
    let allUris
    if (claims) {
      allUris = claims
    } else {
      const refresh = entityDataShouldBeRefreshed(uri)
      const properties = forceArray(property)
      allUris = await Promise.all(properties.map(property => {
        return getReverseClaims(property, uri, refresh)
      }))
    }
    uris = uniq(allUris.flat())
  }

  const waiting = getUris()

  async function getAndSerializeEntities (uris) {
    return getEntitiesAttributesByUris({
      uris,
      // TODO: also request 'popularity' to be able to use it to sort the entities
      attributes: [ 'info', 'labels', 'image' ],
      lang: getCurrentLang(),
    })
      .then(async res => {
        const entities = Object.values(res.entities).map(serializeEntity)
        await addEntitiesImages(entities)
        return indexBy(entities, 'uri')
      })
      .catch(err => flash = err)
  }

  let entitiesByUris = []
  let loadingMore, displayedUris

  async function getMissingEntities () {
    if (loadingMore) return
    if (uris?.length > 0) displayedUris = uris.slice(0, displayLimit)
    if (isNonEmptyArray(displayedUris)) {
      const missingUris = displayedUris.filter(uri => !entitiesByUris[uri])
      if (missingUris.length === 0) return
      loadingMore = getAndSerializeEntities(missingUris)
      const missingEntities = await loadingMore
      entitiesByUris = { ...entitiesByUris, ...missingEntities }
      loadingMore = null
    }
  }

  // Limit needs to be high enough for a large screen element to be scrollable
  // otherwise on:scroll wont be triggered
  let displayLimit = 45
  function displayMore () { displayLimit += 10 }
  const lazyDisplay = debounce(displayMore, 300)
  $: onChange(displayLimit, uris, getMissingEntities)
</script>

{#await waiting}
  <Spinner center={true} />
{:then}
  {#if displayedUris?.length > 0}
    <div class="relative-entities-list">
      <SectionLabel
        {label}
        {property}
        {uri}
        entitiesLength={uris.length}
      />
      <ul on:scroll={onScrollToBottom(lazyDisplay)}>
        {#each displayedUris as uri}
          <RelativeEntityLayout
            {uri}
            {entitiesByUris}
          />
        {/each}
        {#await loadingMore}
          <Spinner />
          {i18n('loading')}
        {/await}
      </ul>
    </div>
  {/if}
{/await}
<Flash state={flash} />

<style lang="scss">
  @import "#general/scss/utils";
  $card-height: 8rem;
  .relative-entities-list{
    padding: 0.5rem;
    background-color: $off-white;
  }
  ul{
    @include display-flex(row, center, null, wrap);
    max-block-size: calc($card-height * 2 + 3em);
    overflow-y: auto;
  }
</style>
