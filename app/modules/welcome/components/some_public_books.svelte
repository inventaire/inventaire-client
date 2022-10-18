<script>
  import { I18n } from '#user/lib/i18n'
  import ItemsCascade from '#inventory/components/items_cascade.svelte'
  import app from '#app/app'
  import Spinner from '#components/spinner.svelte'

  const params = {
    lang: app.user.lang,
    assertImage: true,
    items: [],
  }

  const waiting = app.request('items:getRecentPublic', params)
</script>

<section>
  <h3 class="text-center">{I18n('some of the last books listed')}</h3>
  {#await waiting}
    <Spinner center={true} />
  {:then}
    <ItemsCascade items={params.items} {waiting} />
  {/await}
</section>

<style lang="scss">
  @import '#welcome/scss/welcome_layout_commons';

  section{
    background-color: $off-white;
    padding: 0 1em 0em 1em;
    overflow: hidden;
    max-height: 150vh;
    overflow-y: hidden;
  }
  // Do not override item_card style
  h3:not(.title){
    font-size: 1.4em;
    margin-top: 0.5em;
    color: $dark-grey;
  }
</style>
