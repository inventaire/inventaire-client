<script lang="ts">
  import app from '#app/app'
  import { icon } from '#app/lib/icons'
  import { imgSrc } from '#app/lib/image_source'
  import { isOpenedOutside } from '#app/lib/utils'
  import { i18n, I18n } from '#user/lib/i18n'
  import { mainUserStore } from '#user/lib/main_user'

  export let section

  function selectTab (e) {
    if (isOpenedOutside(e)) return
    section = e.currentTarget.id.replace('Tab', '')
    if (section === 'user') app.navigate($mainUserStore.pathname)
    else app.navigate(`users/${section}`)
    e.preventDefault()
  }
</script>

<div id="tabs" class="tab-selected-{section}">
  <a
    id="userTab"
    href={$mainUserStore.pathname}
    class:selected={section === 'user'}
    on:click={selectTab}
  >
    <img class="avatar" alt="{$mainUserStore.username} avatar" src={imgSrc($mainUserStore.picture, 40)} />
    <span class="label">{$mainUserStore.username}</span>
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
    @include display-flex(row, center, center);
    margin-block-end: 0.5em;
    .avatar, :global(.fa){
      margin: 0 0.5em;
    }
    :global(.fa){
      font-size: 1.4em;
    }
  }
  a{
    flex: 1 0 0;
    @include bg-hover-from-to(darken($light-grey, 10%), lighten($light-grey, 2%));
    font-weight: bold;
    padding: 0.5em;
    align-self: stretch;
    @include display-flex(row, center, center);
    white-space: nowrap;
    text-overflow: ellipsis;
  }
  .avatar{
    height: 2.5em;
    flex: 0 0 2.5em;
  }
  .selected{
    @include bg-hover($inventory-nav-grey, 0);
    color: $dark-grey;
  }

  /* Large screens */
  @media screen and (width >= $small-screen){
    #tabs{
      @include radius-horizontal-group;
    }
  }

  /* Small screens */
  @media screen and (width < $small-screen){
    #tabs{
      margin-block-start: 0.5em;
    }
    a{
      max-width: 34%;
      height: 3em;
      padding: 0.5em;
    }
  }

  /* Very Small screens */
  @media screen and (width < 500px){
    .label{
      display: none;
    }
  }
</style>
