<script>
  import Spinner from '#components/spinner.svelte'
  import { getEntitiesAttributesByUris, getReverseClaims, serializeEntity } from '#entities/lib/entities'
  import { addEntitiesImages } from '#entities/lib/types/work_alt'
  import Flash from '#lib/components/flash.svelte'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { forceArray, loadInternalLink } from '#lib/utils'
  import { uniq } from 'underscore'
  export let entity, property, label

  let flash, entities

  const { uri } = entity

  const properties = forceArray(property)

  async function getUris () {
    const uris = await Promise.all(properties.map(property => {
      return getReverseClaims(property, uri)
    }))
    return uniq(uris.flat())
  }

  const waiting = getUris()
    .then(async uris => {
      const res = await getEntitiesAttributesByUris({
        uris,
        // TODO: also request 'popularity' to be able to use it to sort the entities
        attributes: [ 'type', 'labels', 'image' ],
        lang: app.user.lang,
      })
      entities = Object.values(res.entities).map(serializeEntity)
      await addEntitiesImages(entities)
    })
    .catch(err => flash = err)
</script>

<div class="relative-entities-list">
  {#await waiting}
    <Spinner center={true} />
  {:then}
    {#if entities?.length > 0}
      <h3>{label}</h3>
      <ul>
        {#each entities as entity (entity.uri)}
          <li>
            <a
              href={entity.pathname}
              on:click={loadInternalLink}
              style:background-image={entity.images.length > 0 ? `url(${imgSrc(entity.images[0], 200)})` : null}
              class:has-image={entity.images.length > 0}
              data-data={JSON.stringify(entity.image)}
              >
              <div class="label-wrapper">
                <span class="label">{entity.label}</span>
              </div>
            </a>
          </li>
        {/each}
      </ul>
    {/if}
  {/await}
  <Flash state={flash} />
</div>

<style lang="scss">
  @import '#general/scss/utils';
  ul{
    @include display-flex(row, null, null, wrap)
  }
  li{
    margin: 0.2em;
  }
  a{
    display: block;
    width: 6rem;
    height: 8rem;
    background-size: cover;
    background-position: center center;
    @include display-flex(column, stretch, flex-end);
    &:not(.has-image) {
      .label-wrapper{
        flex: 1;
      }
    }
    &:hover{
      @include shadow-box;
    }
  }
  .label-wrapper{
    @include display-flex(column, stretch, center);
    background-color: #dcdcdc;
  }
  .label{
    text-align: center;
    padding: 0.2em 0.1em;
    line-height: 1.1rem;
  }
</style>
