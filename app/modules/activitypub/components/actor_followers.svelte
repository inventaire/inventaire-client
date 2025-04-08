<script lang="ts">
  import { API } from '#app/api/api'
  import Flash from '#app/lib/components/flash.svelte'
  import preq from '#app/lib/preq'
  import ActorFollower from '#app/modules/activitypub/components/actor_follower.svelte'
  import InfiniteScroll from '#components/infinite_scroll.svelte'
  import { i18n } from '#user/lib/i18n'

  export let actorName: string
  export let actorLabel: string = null
  export let standalone = false
  export let followersCount: number = 0

  let flash, fetching
  let hasMore = true
  let remoteFollowers = []
  const limit = 10
  let offset = 0
  if (!actorLabel) actorLabel = actorName

  async function fetchMore () {
    try {
      fetching = true
      const { orderedItems: remoteFollowersBatch } = await preq.get(API.activitypub.followers({
        limit,
        offset,
        name: actorName,
        'with-actors-info': true,
      }))
      const newUsers = remoteFollowersBatch.filter(newUser => !remoteFollowers.includes(newUser))
      if (newUsers.length === 0) hasMore = false
      remoteFollowers = [ ...remoteFollowers, ...newUsers ]
      fetching = false
      offset += limit
    } catch (err) {
      flash = err
    }
  }
  async function keepScrolling () {
    if (fetching || hasMore === false) return false
    fetching = true
    try {
      await fetchMore()
      return true
    } catch (err) {
      flash = err
      return false
    } finally {
      fetching = false
    }
  }

  fetchMore()

  $: followersCount = remoteFollowers.length
</script>

{#if standalone}
  <h2>{i18n('Fediverse followers of %{actorName}', { actorName })}</h2>
{/if}

<Flash state={flash} />

<InfiniteScroll {keepScrolling} showSpinner={true}>
  <ul>
    {#each remoteFollowers as follower (follower.id)}
      <ActorFollower {follower} />
    {/each}
  </ul>
</InfiniteScroll>

<style lang="scss">
  @use "#general/scss/utils";
  h2{
    @include display-flex(column, stretch, center);
    margin: 0.5em 0;
    text-align: center;
  }
  ul{
    margin: auto;
    @include display-flex(row, center, flex-start, wrap);
    :global(li){
      flex: 1;
      min-width: min(25em, 90vw);
    }
  }
</style>
