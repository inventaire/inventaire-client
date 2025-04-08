<script lang="ts">
  // Could not find out why path "#app/modules/activitypub" throw TS error
  import ActorFollowers from '#app/modules/activitypub/components/actor_followers.svelte'
  import { i18n } from '#user/lib/i18n'

  export let uri

  const actorName = uri.replace(':', '-')

  let followersCount = 0
</script>

<!-- Use class:hidden rather than a if block to let ActorFollowers fetch followers and update followersCount  -->
<div class="actor-followers-section" class:hidden={followersCount === 0}>
  <h3>
    {i18n('Fediverse followers')}
    <span class="counter">{followersCount}</span>
  </h3>
  <ActorFollowers {actorName} bind:followersCount />
</div>

<style lang="scss">
  @use "#general/scss/utils";
  .actor-followers-section{
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
  h3{
    font-size: 1.1rem;
    @include sans-serif;
    margin: 0 0.5rem;
  }
  .counter{
    @include counter-commons;
    background-color: white;
    font-size: 1rem;
    margin-inline-start: 0.5em;
  }
</style>
