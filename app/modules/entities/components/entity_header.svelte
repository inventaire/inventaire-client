<script>
  import { I18n } from '#user/lib/i18n'
  import getFavoriteLabel from '#entities/lib/get_favorite_label'
  import Link from '#lib/components/link.svelte'
  import { buildAltUri } from './lib/entities'

  export let entity
  export let standalone = false

  const { uri, _id, type } = entity

  const altUri = buildAltUri(uri, _id)

  $: favoriteLabel = getFavoriteLabel(entity)
</script>

<div class="header-main">
  <h2>
    {#if standalone}
      {favoriteLabel}
    {:else}
      <Link
        url={`/entity/${uri}`}
        text={favoriteLabel}
        dark={true}
      />
    {/if}
  </h2>
  <p class="type">{I18n(type)}</p>
  {#if !standalone}
    <p class="uri">
      - {uri}
      {#if altUri}
         - {altUri}
      {/if}
    </p>
  {/if}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  h2{
    margin-bottom: 0;
  }
  .uri{
    @include sans-serif;
    font-size: 0.8rem;
  }
  .header-main{
    margin-right: 2em;
    width: 100%;
  }
  /*Large screens*/
  @media screen and (min-width: $small-screen) {
    .header-main{
      @include display-flex(column, center, center);
    }
  }
</style>
