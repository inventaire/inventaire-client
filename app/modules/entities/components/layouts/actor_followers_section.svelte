<script lang="ts">
  // Could not find out why path "#activitypub" throw TS error
  import ActorFollowers from '#app/modules/activitypub/components/actor_followers.svelte'
  import { i18n } from '#user/lib/i18n'

  export let uri

  const actorName = uri.replace(':', '-')

  let followersCount = 0
</script>

<!-- Use class:hidden rather than a if block to let ActorFollowers fetch followers and update followersCount  -->
<div class="actor-followers-section" class:hidden={followersCount === 0}>
  <h4>{i18n('Fediverse followers')}</h4>
  <ActorFollowers {actorName} bind:followersCount />
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .actor-followers-section{
    @include display-flex(column, center);
    padding: 0.5em 0;
    background-color: $off-white;
    margin-block-end: 2em ;
    :global(ul){
      max-block-size: 70vh;
      overflow-y: auto;
    }
    :global(li){
      @include bg-hover(white, 5%);
    }
  }
  .hidden{
    display: none;
  }
</style>
