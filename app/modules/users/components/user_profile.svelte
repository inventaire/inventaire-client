<script>
  import { i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { userContent } from '#lib/handlebars_helpers/user_content'
  import Flash from '#lib/components/flash.svelte'
  import { screen } from '#lib/components/stores/screen'
  import UserProfileButtons from '#users/components/user_profile_buttons.svelte'

  export let user

  const { username, bio, picture, inventoryLength, shelvesCount } = user

  let flash
</script>

<div class="user-profile">
  <div class="user-card">
    <div class="avatar-wrapper">
      <img class="avatar" src={imgSrc(picture, 150, 150)} alt="{username} avatar">
    </div>
    <div class="info">
      <h2 class="username respect-case">{username}</h2>
      <ul class="data">
        {#if inventoryLength != null}
          <li class="inventoryLength">
            <span>{@html icon('book')}{i18n('books')}</span>
            <span class="count">{inventoryLength}</span>
          </li>
        {/if}
        {#if shelvesCount != null}
          <li class="showShelvesList shelvesLength">
            <span>{@html icon('server')}{i18n('shelves')}</span>
            <span class="count">{shelvesCount}</span>
          </li>
        {/if}
      </ul>
      {#if $screen.isLargerThan('$smaller-screen')}
        {#if bio}
          <p class="bio-wrapper">{@html userContent(bio)}</p>
        {/if}
      {/if}
    </div>
  </div>

  {#if $screen.isSmallerThan('$smaller-screen')}
    {#if bio}
      <p class="bio-wrapper">{@html userContent(bio)}</p>
    {/if}
  {/if}

  <UserProfileButtons {user} bind:flash />
</div>

<Flash state={flash} />

<style lang="scss">
  @import '#general/scss/utils';
  .user-profile{
    background-color: #eee;
    @include display-flex(row);
    margin: 0.5em 0;
  }
  .user-card{
    flex: 1;
    @include display-flex(row);
  }
  .avatar{
    background-color: #eee;
  }
  .info{
    position: relative;
  }
  .username{
    @include sans-serif;
    margin: 0;
  }
  .data{
    @include display-flex(row, flex-start);
    color: #666;
    margin-bottom: 0.5em;
    li{
      margin-right: 1em;
    }
  }
  .inventoryLength, .showShelvesList{
    .count{
      padding-left: 0.5em;
    }
  }
  .bio-wrapper{
    @include radius;
    margin-bottom: 2em;
    max-width: 50em;
    overflow: auto;
  }

  /*Large screens*/
  @media screen and (min-width: $smaller-screen) {
    .avatar-wrapper{
      flex: 0 0 auto;
    }
    .info{
      flex: 1 0 0;
      padding: 0.8em 1em;
    }
  }

  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .user-profile{
      @include display-flex(column, center, center);
    }
    .user-card{
      flex-wrap: wrap;
      align-self: stretch;
      margin: 0 0.5em;
    }
    .avatar-wrapper{
      flex: 1 0 0;
      max-width: 30%;
      min-width: 4em;
    }
    .info{
      flex: 2 0 0;
      min-width: min(10em, 90vw);
    }
    .username{
      text-align: center;
    }
    .data{
      li {
        margin: 0 0 0.5em 0;
      }
      flex-direction: column;
      align-items: center;
    }
    .bio-wrapper{
      max-height: 10em;
      margin: 0.5em;
    }
  }
</style>
