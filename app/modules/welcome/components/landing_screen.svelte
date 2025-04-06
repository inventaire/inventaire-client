<script lang="ts">
  import { config } from '#app/config'
  import { icon } from '#app/lib/icons'
  import { getCurrentLang, i18n, I18n } from '#user/lib/i18n'
  import { mainUser } from '#user/lib/main_user'

  const { instanceName, orgName, orgUrl } = config

  const isCanonicalName = instanceName === 'inventaire'
  const needNameExplanation = isCanonicalName && getCurrentLang() !== 'fr'
</script>

<section id="landingScreen" class="text-center">
  <div class="name">
    <h2 class="respect-case">
      {instanceName}
      {#if needNameExplanation}
        <span class="name-explaination">*{i18n('means "inventory" in French')}</span>
      {/if}
    </h2>
    {#if !isCanonicalName}
      <h3 class="subtitle">
        {#if orgName && orgUrl}
          {@html i18n('An [Inventaire](https://wiki.inventaire.io/wiki/Main_Page) instance managed by [%{orgName}](%{orgUrl})', { orgName, orgUrl })}
        {:else}
          {@html i18n('An [Inventaire](https://wiki.inventaire.io/wiki/Main_Page) instance')}
        {/if}
      </h3>
    {/if}
  </div>
  <!-- wrap the rest in the bottom div to push it down -->
  <div class="bottom">
    <ul class="pitch">
      <li>
        {@html icon('list')}
        <h3>{I18n('keep an inventory of your books')}</h3>
        <p>{i18n('and of what can be done with them:')} "<em>{i18n('this book I can lend, this book I can give, this one is for sale…')}</em>"</p>
      </li>
      <li>
        {@html icon('users')}
        <h3>{I18n('share it with your friends and communities')}</h3>
        <p>{i18n('Always dreamed of a collaborative library for your coworking / association / book club? Here it is!')}</p>
      </li>
      <li>
        {@html icon('exchange')}
        <h3>{I18n('Remember the books you lend or borrow')}</h3>
        <p>{i18n('The books you lend might actually come back now!')}</p>
      </li>
    </ul>
    <div id="loginButtons">
      {#if mainUser}
        <a class="showHome button dark-grey" href="/inventory">{i18n('back to your inventory')}</a>
      {:else}
        <a class="signupRequest button secondary bold" href="/signup">{i18n('sign up')}</a>
        <a class="loginRequest button success bold" href="/login">{i18n('login')}</a>
      {/if}
    </div>
  </div>
</section>

<style lang="scss">
  @import "#general/scss/utils";
  @import "#welcome/scss/welcome_layout_commons";

  $title-color: white;
  $pitch-text-color: rgba(darken($welcome-bg-filter, 15%), 0.9);
  $pitch-bg-color: rgba(white, 0.95);

  section#landingScreen{
    background-color: $welcome-bg-filter;
    @include display-flex(column, center, center);
    .name{
      @include display-flex(column, center, center);
      // Those margins are compensating for Safari bad flex support
      margin-block: 2em;
      h2{
        color: $title-color;
        font-weight: bold;
        font-size: 10em;
        line-height: 1em;
        margin: 0 auto;
        position: relative;
      }
      .subtitle{
        font-weight: bold;
        :global(.link){
          text-decoration: underline;
        }
      }
      .name-explaination{
        font-size: 1rem;
        position: absolute;
        inset-block-end: 0;
        inset-inline-end: 0;
        height: 1rem;
        line-height: 1rem;
        opacity: 0;
        @include transition(opacity);
      }
      &:hover{
        .name-explaination{
          opacity: 0.9;
        }
      }
    }
    .pitch{
      width: 100%;
      max-width: 95em;
      @include display-flex(row, stretch, space-between);
      li{
        flex: 1 0 0;
        background-color: $pitch-bg-color;
        @include radius(5px);
        padding: 1em 0.6em;
        margin: 0.5em;
        :global(.fa), h3, p{
          color: $pitch-text-color;
        }
        :global(.fa){
          font-size: 2.5em;
        }
        h3{
          font-size: 1.3em;
          font-weight: bold;
        }
        p{
          margin-block-start: auto;
          opacity: $shy-opacity;
        }
      }
    }
    #loginButtons{
      @include display-flex(row, center, center, wrap);
      // Those margins are compensating for Safari bad flex support
      margin-block: 1em;
      .button{
        min-width: 10em;
        // Reset radius
        @include radius(0);
      }
      @include radius-horizontal-group;
    }

    /* Small screens */
    @media screen and (width < $small-screen){
      .name{
        padding-block: 3em 2em;
        h2{
          font-size: 6em;
        }
        .name-explaination{
          inset-block-end: -1em;
        }
      }
      #loginButtons{
        margin: 0.5em;
        margin-block-end: 1em;
      }
    }

    /* Smaller screens */
    @media screen and (width < 800px){
      .pitch{
        flex-direction: column;
        align-items: stretch;
        li{
          max-width: 20em;
        }
      }
    }
    @media screen and (width < $smaller-screen){
      .name{
        h2{
          font-size: 3em;
        }
      }
    }

    /* Large screens */
    @media screen and (width >= $small-screen){
      height: 85vh;
      // prevent everything from overflowing on screens with a rather small height
      min-height: 650px;
      .name{
        flex: 4 0 auto;
      }
      .bottom{
        flex: 1 0 auto;
        @include display-flex(column, center, space-around);
        margin-block-end: 1em;
        // Required on Edge for some reason
        width: 100%;
      }
      #loginButtons{
        margin: auto;
      }
    }
  }
</style>
