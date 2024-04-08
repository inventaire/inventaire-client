<script lang="ts">
  import app from '#app/app'
  import { loadInternalLink } from '#lib/utils'
  import { i18n } from '#user/lib/i18n'

  const { loggedIn } = app.user
</script>

{#if !loggedIn}
  <section class="embedded-welcome">
    <div>
      <h2>{i18n('Welcome to Inventaire')}</h2>
      <span class="tagline">
        {i18n('the library of your friends and communities')}
      </span>
    </div>
    <a
      href="/welcome"
      class="showWelcome button secondary bold radius"
      on:click={loadInternalLink}
    >
      {i18n('learn more')}
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
