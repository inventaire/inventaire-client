<script>
  import { I18n } from '#user/lib/i18n'
  import ItemsCascade from '#inventory/components/items_cascade.svelte'
  import app from '#app/app'
  import Spinner from '#components/spinner.svelte'
  import { screen } from '#lib/components/stores/screen'
  import ItemsTable from '#inventory/components/items_table.svelte'

  const params = {
    lang: app.user.lang,
    assertImage: true,
    items: [],
  }

  const waiting = app.request('items:getRecentPublic', params)
</script>

<section>
  <h3>{I18n('some of the last books listed')}</h3>
  {#await waiting}
    <Spinner center={true} />
  {:then}
    {#if $screen.isSmallerThan('$smaller-screen')}
      <ItemsTable items={params.items} {waiting} haveSeveralOwners={true} />
    {:else}
      <ItemsCascade items={params.items} {waiting} />
    {/if}
  {/await}
</section>

<style lang="scss">
  @import "#welcome/scss/welcome_layout_commons";

  section{
    background-color: $off-white;
    overflow: hidden;
    max-height: 150vh;
    overflow-y: hidden;
  }
  /* Large screens */
  @media screen and (min-width: $smaller-screen){
    section{
      padding: 0 1em;
    }
  }
  // Do not override item_card style
  h3:not(.title){
    text-align: center;
    font-size: 1.2em;
    margin-top: 0.5em;
  }
</style>
