<script lang="ts">
  import { API } from '#app/api/api'
  import app from '#app/app'
  import Link from '#app/lib/components/link.svelte'
  import { icon } from '#app/lib/icons'
  import { apiDoc } from '#app/lib/urls'
  import { mainUserHasWikidataOauthTokens } from '#app/modules/user/lib/main_user'
  import { i18n, I18n } from '#user/lib/i18n'
  import ContributionAnonymizationToggler from './contribution_anonymization_toggler.svelte'

  export let user
  const csvExportUrl = API.items.export({ format: 'csv' })
  const inventoryJsonUrl = API.items.byUsers({ ids: user.id, limit: 100000 })

  const wikidataOauth = API.auth.oauth.wikidata + '&redirect=/settings/data'
</script>

<form>
  <fieldset>
    <h2 class="first-title">{I18n('data exports')}</h2>

    <h3>{i18n('Inventory')}</h3>
    <p class="note">{I18n('download your inventory and its associated data (authors, works, publishers, etc.)')}</p>
    <a class="light-blue-button" href={csvExportUrl} download="inventory.csv">{I18n('download CSV')}</a>
    <a class="light-blue-button" href={inventoryJsonUrl} download="inventory.json">{I18n('download JSON')}</a>

    <h3>{I18n('user profile')}</h3>
    <p class="note">{I18n('your profile contains information about you')}</p>
    <a class="light-blue-button" href="/api/user" download="profile.json">{I18n('download JSON')}</a>
  </fieldset>
  <fieldset>
    <h2 class="first-title">{i18n('Bibliographic data contributions')}</h2>
    <p class="note">{@html i18n('Bibliographic data are data about works, editions, authors, publishers, etc. In Inventaire, those data are known as [entities](https://wiki.inventaire.io/wiki/Glossary#Entity).')}</p>
    <p class="note">{@html i18n('Inventaire primarily finds its bibliographic data in [Wikidata](https://www.wikidata.org/), an open collaborative database built to support Wikipedia and the other [Wikimedia](https://www.wikimedia.org/) projects.')}</p>
    <p class="note">{@html i18n('Inventaire also hosts a local bibliographic database to extend Wikidata. To stay compatible with Wikidata, this database is also published under a [CC0 license](https://creativecommons.org/publicdomain/zero/1.0/).')}</p>
    <p class="note">{@html i18n('Helping to improve Wikidata thus also improves Inventaire, and many other projects using those same data! [Learn More](https://wiki.inventaire.io/wiki/Entities_data).')}</p>

    <p>
      <Link
        url={app.user.contributionsPathname}
        text={i18n('See your contributions to the local bibliographic database')}
        classNames="link"
      />
    </p>

    <ContributionAnonymizationToggler />

    <div class="wikidata-oauth">
      {#if mainUserHasWikidataOauthTokens()}
        {@html icon('check')}
        {@html icon('wikidata-colored')}
        {i18n('Your Wikidata account is connected')}
        <!-- TODO: allow to disconnect wikidata account -->
      {:else}
        <a href={wikidataOauth} class="button success">
          {@html icon('wikidata-colored')}
          {i18n('Connect your Wikidata account')}
          {@html icon('plug')}
        </a>
      {/if}
    </div>
  </fieldset>
  <fieldset>
    <h2>{i18n('API')}</h2>
    <a
      href={apiDoc}
      target="_blank"
      rel="noreferrer"
      class="link">
      {I18n('check the documentation')}
      {@html icon('link')}
    </a>
  </fieldset>
</form>

<style lang="scss">
  @import "#settings/scss/common_settings";
  .link, form :global(.link){
    text-decoration: underline;
  }
  .light-blue-button{
    display: inline-block;
    margin: 0.5em 1em 0.5em 0;
    color: white;
  }
  h3{
    @include settings-h3;
  }
  .note{
    color: $grey;
    font-size: 1rem;
    margin-block-end: 1em;
  }
  .wikidata-oauth{
    margin: 1em 0;
  }
</style>
