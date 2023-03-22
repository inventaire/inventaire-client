<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { icon, isOpenedOutside } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { user } from '#user/user_store'

  export let section

  function selectTab (e) {
    if (isOpenedOutside(e)) return
    section = e.currentTarget.id.replace('Tab', '')
    if (section === 'user') app.navigate($user.inventoryPathname)
    else app.navigate(`users/${section}`)
    e.preventDefault()
  }
</script>

<div id="tabs" class="tab-selected-{section}">
  <a
    id="userTab"
    href={$user.pathname}
    class:selected={section === 'user'}
    on:click={selectTab}
  >
    <img class="avatar" alt="{$user.username} avatar" src={imgSrc($user.picture, 40)} />
    <span class="label">{$user.username}</span>
  </a>
  <a
    id="networkTab"
    href="/users/network"
    class:selected={section === 'network'}
    on:click={selectTab}
  >
    {@html icon('users')}
    <span class="label">{i18n('Friends & Groups')}</span>
  </a>
  <a
    id="publicTab"
    href="/users/public"
    class:selected={section === 'public'}
    on:click={selectTab}
  >
    {@html icon('map-marker')}
    <span class="label">{I18n('public')}</span>
  </a>
</div>

<style lang="scss">
  @import "#general/scss/utils";
  #tabs{
    @include display-flex(row, center, center, wrap);
    margin-bottom: 0.5em;
    .avatar, :global(.fa){
      margin: 0 0.5em;
    }
    :global(.fa){
      font-size: 1.4em;
    }
  }
  a{
    flex: 1 0 auto;
    @include bg-hover-from-to(darken($light-grey, 10%), lighten($light-grey, 2%));
    font-weight: bold;
    padding: 0.5em;
    align-self: stretch;
    @include display-flex(row, center, center);
  }
  .avatar{
    height: 2.5em;
  }
  .selected{
    @include bg-hover($inventory-nav-grey, 0);
    color: $dark-grey;
  }

  /* Large screens */
  @media screen and (min-width: $small-screen){
    #tabs{
      @include radius-horizontal-group;
    }
  }

  /* Small screens */
  @media screen and (max-width: $small-screen){
    #tabs{
      margin-top: 0.5em;
    }
    a{
      height: 3em;
      flex-direction: column;
    }
  }

  /* Very Small screens */
  @media screen and (max-width: 500px){
    .label{
      display: none;
    }
  }
</style>
