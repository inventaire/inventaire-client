<script lang="ts">
  import { API } from '#app/api/api'
  import { buildPath } from '#app/lib/location'
  import { domain } from '#app/lib/urls'
  import { fixedEncodeURIComponent, loadInternalLink } from '#app/lib/utils'
  import { I18n } from '#user/lib/i18n'
  import { mainUser } from '#user/lib/main_user'
  import { getRequestedAccessRights } from '#user/lib/oauth'

  export let query
  export let client

  query.redirect_uri = fixedEncodeURIComponent(query.redirect_uri)
  const authorizeUrl = buildPath(API.oauth.authorize, query)
  const requestedAccessRights = getRequestedAccessRights(query.scope)

  const authorizationRequestContext = I18n('authorization_request_context', {
    name: client.name,
    username: $mainUser.username,
    domain,
  })
</script>

<div class="auth-menu">
  <div class="custom-cell authorize">
    <p class="context" dir="auto">{@html authorizationRequestContext}</p>
    <ul class="requested-access-rights">
      {#each requestedAccessRights as { label }}
        <li class="access-right">{I18n(label)}</li>
      {/each}
    </ul>
    <div class="buttons">
      <a href="/" class="cancel button soft-grey-button" on:click={loadInternalLink}>{I18n('cancel')}</a>
      <a href={authorizeUrl} class="button success-button">{I18n('allow')}</a>
    </div>
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  @import '#user/scss/auth_menu_commons';

  .auth-menu{
    @include central-column(40em);
  }
  .context{
    text-align: start;
  }
  .requested-access-rights{
    max-width: 30em;
    text-align: start;
    margin: 1em auto;
  }
  .access-right{
    list-style-type: disc;
    margin: 0.2em 1em;
  }
  .buttons{
    display: flex;
    flex-direction: row;
    align-items: stretch;
    justify-content: center;
  }
  .button{
    margin: 0.5em;
  }
</style>
