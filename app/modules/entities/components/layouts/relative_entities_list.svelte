<script>
  import { i18n } from '#user/lib/i18n'
  import { onChange } from '#lib/svelte/svelte'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { forceArray } from '#lib/utils'
  import { uniq, indexBy } from 'underscore'
  import Spinner from '#components/spinner.svelte'
  import { getEntitiesAttributesByUris, getReverseClaims, serializeEntity } from '#entities/lib/entities'
  import { addEntitiesImages } from '#entities/lib/types/work_alt'
  import Flash from '#lib/components/flash.svelte'
  import SectionLabel from '#entities/components/layouts/section_label.svelte'
  import RelativeEntityLayout from '#entities/components/layouts/relative_entity_layout.svelte'

  export let entity, property, label, claims

  let flash
  let uris

  const { uri } = entity

  async function getUris () {
    let allUris
    if (claims) {
      allUris = claims
    } else {
      const properties = forceArray(property)
      allUris = await Promise.all(properties.map(property => {
        return getReverseClaims(property, uri)
      }))
    }
    uris = uniq(allUris.flat())
  }

  const waiting = getUris()

  async function getAndSerializeEntities (uris) {
    return getEntitiesAttributesByUris({
      uris,
      // TODO: also request 'popularity' to be able to use it to sort the entities
      attributes: [ 'type', 'labels', 'image' ],
      lang: app.user.lang,
    })
      .then(async res => {
        const entities = Object.values(res.entities).map(serializeEntity)
        await addEntitiesImages(entities)
        return indexBy(entities, 'uri')
      })
      .catch(err => flash = err)
  }

  let entitiesByUris = []
  let loadMore, displayedUris

  async function getMissingEntities () {
    let missingUris = displayedUris.filter(uri => !entitiesByUris[uri])
    if (isNonEmptyArray(missingUris)) {
      loadMore = true
      const missingEntities = await getAndSerializeEntities(missingUris)
      loadMore = false
      entitiesByUris = { ...entitiesByUris, ...missingEntities }
    }
  }

  function onEntitiesScroll (e) {
    const { scrollTop, scrollTopMax } = e.currentTarget
    if (scrollTopMax < 100) return
    if (scrollTop + 100 > scrollTopMax) displayLimit += 10
  }

  // Limit needs to be high enough for a large screen element to be scrollable
  // otherwise on:scroll wont be triggered
  let displayLimit = 45
  let scrollableElement
  $: anyUris = uris?.length > 0
  $: if (anyUris) displayedUris = uris.slice(0, displayLimit)
  $: if (displayedUris) onChange(displayedUris, getMissingEntities)
</script>

{#await waiting}
  <Spinner center={true} />
{:then}
  {#if anyUris}
    <div class="relative-entities-list">
      <SectionLabel
        {label}
        {property}
        {uri}
        entitiesLength={uris.length}
      />
      <ul
        on:scroll={onEntitiesScroll}
        bind:this={scrollableElement}
      >
        {#each displayedUris as uri}
          <RelativeEntityLayout
            {uri}
            {entitiesByUris}
          />
        {/each}
        {#if loadMore}
          <Spinner />
          {i18n('loading')}
        {/if}
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
    margin-bottom: 0.5em;
  }
  ul{
    @include display-flex(row, center, null, wrap);
    max-height: calc($card-height * 2 + 3em);
    overflow-y: auto;
  }
</style>
