<script lang="ts">
  import { wait } from '#app/lib/promises'
  import type { SerializedItem } from '#server/types/item'
  import LandingPageFooter from '#welcome/components/landing_page_footer.svelte'
  import LandingScreen from '#welcome/components/landing_screen.svelte'
  import PublicMap from '#welcome/components/public_map.svelte'
  import SomePublicBooks from '#welcome/components/some_public_books.svelte'

  let items: SerializedItem[] = []
  // Give a delay before PublicMap redefines it
  let waitingForItems = wait(500)
</script>

<div class="welcome-layout">
  <LandingScreen />
  <PublicMap bind:items bind:waitingForItems />
  <SomePublicBooks {items} {waitingForItems} />
  <LandingPageFooter />
  <div class="background-cover"></div>
</div>

<style lang="scss">
  @use "#general/scss/utils";
  .welcome-layout{
    :global(h3){
      margin-block-start: 0.5em;
      color: $dark-grey;
    }
  }
  .background-cover{
    @include position(fixed, 0, 0, 0, 0, -10);
    // Webpack will not be able to transform the asset path in development
    // as emitCss=false in Svelte dev config, so the image will only appear
    // when building for production.
    // Photo attribution in https://wiki.inventaire.io/wiki/Credits#Images: Brittany Stevens
    @include multidef-bg-cover("brittanystevens.jpg", "hd");
  }
</style>
