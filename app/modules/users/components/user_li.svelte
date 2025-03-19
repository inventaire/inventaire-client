<script lang="ts">
  import { imgSrc } from '#app/lib/handlebars_helpers/images'
  import { loadInternalLink } from '#app/lib/utils'
  import { type SerializedUser } from '#users/lib/users'

  export let user: SerializedUser
  export let showEmail = false

  const { picture, username, pathname } = user
  const email = 'email' in user ? user.email : null
</script>

<li>
  <a href={pathname} on:click={loadInternalLink}>
    <img src={imgSrc(picture, 48)} alt={username} loading="lazy" />
    <span class="username">{username}</span>
    {#if showEmail && email}
      <span class="email">({email})</span>
    {/if}
  </a>
  <div class="user-menu">
    <slot />
  </div>
</li>

<style lang="scss">
  @import "#general/scss/utils";
  $user-height: 3em;
  $user-bg: #ddd;
  li{
    background-color: white;
    @include radius;
    @include display-flex(row, center);
    &:not(:first-child){
      margin-block-start: 0.5rem;
    }
  }
  img{
    margin-inline-start: 0;
    height: $user-height;
    width: $user-height;
    overflow: hidden;
    @include radius;
  }
  .username{
    margin-inline-start: 0.3em;
  }
  .user-menu{
    margin-inline-start: auto;
    @include display-flex(row, center, center);
  }
</style>
