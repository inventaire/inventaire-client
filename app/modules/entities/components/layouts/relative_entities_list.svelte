<script>
  import Spinner from '#components/spinner.svelte'
  import { getEntitiesAttributesByUris, getReverseClaims, serializeEntity } from '#entities/lib/entities'
  import { addEntitiesImages } from '#entities/lib/types/work_alt'
  import Flash from '#lib/components/flash.svelte'
  import ImagesCollage from '#components/images_collage.svelte'
  import { forceArray, loadInternalLink } from '#lib/utils'
  import { uniq } from 'underscore'

  export let entity, property, label, claims

  let flash, entities

  const { uri, image } = entity

  async function getUris () {
    let uris
    if (claims) {
      uris = claims
    } else {
      const properties = forceArray(property)
      uris = await Promise.all(properties.map(property => {
        return getReverseClaims(property, uri)
      }))
    }
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

<div class="relative-entities-list" class:not-empty={entities?.length > 0}>
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
              data-data={JSON.stringify(image)}
            >
              <ImagesCollage imagesUrls={[ entity.image.url ]}
              />
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
  $card-width: 6rem;
  $card-height: 8rem;
  .relative-entities-list.not-empty{
    padding: 0.5rem;
    background-color: $off-white;
    margin-bottom: 0.5em;
  }
  h3{
    font-size: 1.1rem;
  }
  ul{
    @include display-flex(row, null, null, wrap);
    max-height: calc($card-height * 2 + 3em);
    overflow-y: auto;
  }
  li{
    margin: 0.2em;
  }
  a{
    display: block;
    width: $card-width;
    height: $card-height;
    background-size: cover;
    background-position: center center;
    @include display-flex(column, stretch, flex-end);
    :global(.images-collage){
      width: $card-width;
      height: $card-height;
    }
    &:hover{
      @include shadow-box;
    }
  }
  .label-wrapper{
    @include display-flex(column, stretch, center);
    background-color: #eaeaea;
  }
  .label{
    text-align: center;
    padding: 0.2em 0.1em;
    line-height: 1.1rem;
  }
</style>
