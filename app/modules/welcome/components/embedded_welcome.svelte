<script lang="ts">
  import { config } from '#app/config'
  import { loadInternalLink } from '#app/lib/utils'
  import { I18n, i18n } from '#user/lib/i18n'
  import { mainUser } from '#user/lib/main_user'

  const { instanceName, orgName, orgUrl } = config

</script>

{#if !mainUser}
  <section class="embedded-welcome">
    <div>
      <h2>{i18n('Welcome to %{instanceName}', { instanceName })}</h2>
      <span class="tagline">
        {#if instanceName.toLowerCase() === 'inventaire'}
          {I18n('the library of your friends and communities')}
        {:else}
          {@html i18n('An [Inventaire](https://wiki.inventaire.io/wiki/Main_Page) instance managed by [%{orgName}](%{orgUrl})', { orgName, orgUrl })}
        {/if}
      </span>
    </div>
    <a
      href="/welcome"
      class="button secondary bold radius"
      on:click={loadInternalLink}
    >
      {I18n('learn more')}
    </a>
  </section>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .embedded-welcome{
    padding-block-start: 2em;
    padding-block-end: 2em;
    width: 100%;
    @include display-flex(column, center, center);
    @include multidef-bg-cover("brittanystevens.jpg", "hd");
  }
  div{
    @include radius;
    text-align: center;
    background-color: $green-tree;
    margin: 1em;
    padding: 0.5em 1em;
  }
  h2{
    font-size: 1.6em;
    color: white;
    font-weight: bold;
    line-height: 1em;
  }
  .tagline{
    color: white;
    padding: 0.4em;
    margin-block-end: 0.5em;
  }
  .button{
    margin-block-end: 1em;
  }
</style>
