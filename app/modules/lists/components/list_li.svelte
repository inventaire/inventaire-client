<script>
  import { i18n } from '#user/lib/i18n'
  import Link from '#lib/components/link.svelte'
  import ImagesCollage from '#components/images_collage.svelte'
  import { getEntitiesAttributesByUris } from '#entities/lib/entities'

  export let list
  const { _id } = list
  let imagesUrls

  const onClick = listId => e => {
    app.navigateAndLoad(`/lists/${listId}`)
  }

  const getSelectionsImages = async () => {
    const allSelectionsUris = list.selections.map(_.property('uri'))
    // TODO: make it fast by paginating entities: check if they hava enough images for the collage, and fetch more if not.
    const selectionsUris = allSelectionsUris.slice(0, 15)
    const { entities } = await getEntitiesAttributesByUris({
      uris: selectionsUris,
      attributes: [ 'image' ]
    })
    imagesUrls = _.compact(Object.values(entities).map(entity => entity.image.url))
  }

  const waitingForImages = getSelectionsImages()
</script>
<div
  class="list-li"
  on:click={onClick(_id)}
>
  {#await waitingForImages then}
    <div class="collage-wrapper">
      <ImagesCollage
        imagesUrls={imagesUrls}
        limit={6}
      />
    </div>
  {/await}
  <span class="info">
    <Link
      url={`/lists/${_id}`}
      text={list.name}
    />
    <p class="list-counter">
      {i18n('list_element_count', { count: list.selections.length })}
    </p>
  </span>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .list-li{
    @include display-flex(column, flex-start, flex-start, wrap);
    width: 20em;
    display: block;
    @include bg-hover($light-grey);
    height: 12em;
    padding: 0.5em;
    margin: 0.2em;
    cursor: pointer;
    @include radius;
  }
  .info{
    max-height: 3.5rem;
    overflow: hidden;
  }
  .list-counter{
    color: $grey;
  }

  .collage-wrapper{
    margin-bottom: 0.3em;
    :global(.images-collage){
      width: 100%;
      height: 5em;
    }
  }
</style>
