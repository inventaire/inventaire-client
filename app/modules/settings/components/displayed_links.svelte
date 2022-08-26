<script>
  import { I18n } from '#user/lib/i18n'
  import { getLocalStorageStore } from '#lib/components/stores/local_storage_stores'

  const links = getLocalStorageStore('settings:display:links', [])

  const alphabetically = (a, b) => a.label > b.label ? 1 : -1

  const bibliographicDatabases = [
    { property: 'wdt:P268', label: 'BNF' },
    { property: 'wdt:P648', label: 'OpenLibrary' },
  ].sort(alphabetically)

  const socialNetworks = [
    { property: 'wdt:P2002', label: 'Twitter' },
    { property: 'wdt:P2013', label: 'Facebook' },
    { property: 'wdt:P2003', label: 'Instagram' },
    { property: 'wdt:P2397', label: 'YouTube' },
    { property: 'wdt:P4033', label: 'Mastodon' },
  ].sort(alphabetically)
</script>

<fieldset>
  <legend>{I18n('bibliographic databases')}</legend>
  {#each bibliographicDatabases as option}
    <label>
      <input type="checkbox" bind:group={$links} value={option.property}>
      {option.label}
    </label>
  {/each}
</fieldset>

<fieldset>
  <legend>{I18n('social networks')}</legend>
  {#each socialNetworks as option}
    <label>
      <input type="checkbox" bind:group={$links} value={option.property}>
      {option.label}
    </label>
  {/each}
</fieldset>

<style lang="scss">
  @import '#general/scss/utils';
  fieldset{
    @include display-flex(row, null, null, wrap);
  }
  label{
    width: 10em;
    padding: 0.5em;
    margin: 0.1em;
    cursor: pointer;
  }
</style>
