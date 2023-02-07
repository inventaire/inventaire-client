<script>
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { loadInternalLink } from '#lib/utils'
  import { currentRoute } from '#lib/location'

  export let user

  const { username, picture } = user
</script>
<div class="item-user-box">
  {#if currentRoute().includes(username)}
    <img alt="{username} avatar" src={imgSrc(picture, 48)} />
    <strong class="username">{username}</strong>
  {:else}
    <a
      href={user.pathname}
      on:click|stopPropagation={loadInternalLink}
    >
      <img alt="{username} avatar" src={imgSrc(picture, 48)} />
      <strong class="username">{username}</strong>
    </a>
  {/if}
</div>
<style lang="scss">
  @import "#general/scss/utils";
  .item-user-box{
    max-height: $user-box-heigth;
    @include display-flex(row, center, flex-start);
  }
  a{
    @include bg-hover(white);
  }
  .username{
    margin-left: 0.4em;
  }
  img{
    height: 2.8em;
    background-color: white;
  }
</style>
