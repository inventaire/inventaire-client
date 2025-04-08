<script lang="ts">
  import { API } from '#app/api/api'
  import Link from '#app/lib/components/link.svelte'
  import { icon } from '#app/lib/icons'
  import { loadInternalLink } from '#app/lib/utils'
  import { getWdWikiUrl } from '#app/lib/wikimedia/wikidata'
  import type { SerializedEntity } from '#entities/lib/entities'
  import { i18n, I18n } from '#user/lib/i18n'
  import { mainUser } from '#user/lib/main_user'

  export let entity: SerializedEntity

  const { label, editPathname, isWikidataEntity } = entity
  let wikidataOauth, wikiUrl
  const { wdId } = entity
  if (isWikidataEntity) {
    wikidataOauth = API.auth.oauth.wikidata + `&redirect=${editPathname}`
    wikiUrl = getWdWikiUrl(wdId)
  }

  function login (e) {
    loadInternalLink(e)
  }
</script>

<div class="wikidata-edit-intro">
  <div class="header">
    {@html icon('wikidata-colored')}
    <h3>Wikidata</h3>
  </div>
  <p class="edit-intro">
    {#if isWikidataEntity}
      {@html i18n('wikidata_edit_intro', { label })}
    {:else}
      {@html i18n('wikidata_move_intro', { label })}
    {/if}
  </p>
  <div class="actions">
    {#if isWikidataEntity}
      <a
        href={wikiUrl}
        target="_blank"
        rel="noreferrer"
        class="button grey">{@html icon('pencil')}{I18n('edit on Wikidata')}</a>
    {/if}
    {#if mainUser}
      <a href={wikidataOauth} class="button success">{@html icon('plug')}{i18n('Connect Wikidata account')}</a>
    {:else}
      <!-- TODO: check that the modal is correctly closed when clicking on this button -->
      <a href="/login" class="button success loginRequest" on:click={login}>
        {@html icon('plug')}
        {i18n('Login & connect your Wikidata account')}
      </a>
    {/if}
  </div>
  <p>
    <Link url="https://www.wikidata.org/wiki/Wikidata:Introduction" text={i18n('Learn more about Wikidata')} />
  </p>
</div>

<style lang="scss">
  @use '#general/scss/utils';
  .wikidata-edit-intro{
    text-align: center;
    margin: 1em auto;
    padding: 1em;
    max-width: 40em;
    :global(.link){
      color: $grey;
      text-decoration-color: $grey;
    }
    :global(.icon){
      max-height: 5em;
    }
  }
  .header{
    @include display-flex(column, center, center);
    h3{
      font-weight: bold;
    }
  }
  .edit-intro{
    padding: 1em;
  }
  .actions{
    @include display-flex(row, center, center, wrap);
  }
  .button{
    font-weight: bold;
    @include radius;
    margin: 0.5em;
    flex: 1 0 0;
    padding: 1em 0.5em;
  }
</style>
