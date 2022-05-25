<script>
  import { I18n } from '#user/lib/i18n'
  import { loadInteralLink } from '#lib/utils'
  import getFavoriteLabel from '#entities/lib/get_favorite_label'

  export let entity
  export let standalone = false

  const { uri } = entity

  $: favoriteLabel = getFavoriteLabel(entity)
</script>

<div class="header-main">
  <h2>
    {#if standalone}
      {favoriteLabel}
    {:else}
      <a href="/entity/{uri}" on:click={loadInteralLink}>
        {favoriteLabel}
      </a>
    {/if}
  </h2>
  <p class="type">{I18n(entity.type)}</p>
  {#if !standalone}
    <p class="uri">{uri}</p>
  {/if}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  h2{
    margin-bottom: 0;
    a{
      @include link-dark;
    }
  }
  .type{
    color: $grey;
    font-size: 1rem;
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
