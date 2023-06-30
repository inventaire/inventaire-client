<script>
  import TopBarLanguagePicker from '#components/top_bar_language_picker.svelte'
  import { I18n } from '#user/lib/i18n'
  import { screen } from '#lib/components/stores/screen'
  import { loadInternalLink } from '#lib/utils'
  import GlobalSearchBar from '#search/components/global_search_bar.svelte'
  import TopBarButtons from '#components/top_bar_buttons.svelte'
  import { locationStore } from '#lib/location'
  const { loggedIn } = app.user

  let displayConnectionButtons = false

  $: smallScreen = $screen.isSmallerThan('$small-screen')

  $: {
    const { section } = $locationStore
    const onConnectionPage = (section === 'signup') || (section === 'login')
    displayConnectionButtons = !(smallScreen && onConnectionPage)
  }
</script>

<nav>
  <h1 class="respect-case">
    <a id="home" href="/" on:click={loadInternalLink}>{#if smallScreen}inv{:else}inventaire{/if}</a>
  </h1>

  <!-- svelte-ignore a11y-missing-content -->
  <a id="goToMain" href="#main" title={I18n('skip to main content')} />

  <GlobalSearchBar />

  <TopBarLanguagePicker />

  {#if loggedIn}
    <TopBarButtons />
  {:else if displayConnectionButtons}
    <a
      class="signup-request"
      href="/signup"
      on:click={loadInternalLink}
    >
      {I18n('sign up')}
    </a>
    <a
      class="login-request"
      href="/login"
      on:click={loadInternalLink}
    >
      {I18n('login')}
    </a>
  {/if}
</nav>

<style lang="scss">
  @import "#general/scss/utils";

  nav{
    // Screens that have enough vertical space to display the full top bar menu,
    // without needing to scroll
    @media screen and (min-height: $top-bar-fixed-threshold){
      // Use position:fixed to make the top-bar stick to the screen top
      @include position(fixed, 0, 0, null, 0);
    }
    @include display-flex(row, center, flex-start);
    background-color: $topbar-bg-color;
  }
  h1{
    font-size: 2rem;
    font-weight: bold;
    line-height: 2rem;
    // /!\ Defines the top-bar height
    padding: 0.1rem 0.5rem;
  }
  a#home{
    color: white;
    font-weight: bold;
  }
  .signup-request, .login-request{
    font-weight: bold;
    color: white;
    white-space: nowrap;
    @include display-flex(row, center, center);
    align-self: stretch;
    padding: 0 1em;
  }
  .signup-request{
    @include bg-hover($secondary-color, 5%);
    color: $dark-grey;
  }
  .login-request{
    @include bg-hover($success-color, 5%);
    color: white;
  }

  /* Large screens */
  @media screen and (min-width: $small-screen){
    .signup-request{
      // Push away the #language-picker
      margin-inline-start: 1em;
    }
  }

  /* Small screens */
  @media screen and (max-width: $small-screen){
    nav{
      padding: 0.2em 0;
    }
    h1{
      flex: 0 0 auto;
      font-size: 1.1rem;
      background-color: $light-blue;
      @include radius;
      width: 1.8em;
      height: 1.8em;
      padding: 0;
      text-align: center;
      margin-inline-start: 0.2em;
      margin-inline-end: 0.4em;
    }
    // Showing signup and login button at the bottom of the screen
    .signup-request, .login-request{
      position: fixed;
      inset-block-end: 0;
      height: $smallscreen-connection-buttons-height;
    }
    .signup-request{
      inset-inline-start: 0;
      inset-inline-end: 50vw;
    }
    .login-request{
      inset-inline-start: 50vw;
      inset-inline-end: 0;
    }
  }
</style>
