<script>
  import { I18n } from '#user/lib/i18n'
  import { linksClaimsPropertiesByCategory, linksSettings } from '#entities/lib/entity_links'
  const { bibliographicDatabases, socialNetworks } = linksClaimsPropertiesByCategory
</script>

<fieldset>
  <legend>{I18n('bibliographic databases')}</legend>
  {#each bibliographicDatabases as option}
    <label>
      <input type="checkbox" bind:group={$linksSettings} value={option.property}>
      {option.label}
    </label>
  {/each}
</fieldset>
<fieldset>
  <legend>{I18n('social networks')}</legend>
  {#each socialNetworks as option}
    <label>
      <input type="checkbox" bind:group={$linksSettings} value={option.property}>
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
