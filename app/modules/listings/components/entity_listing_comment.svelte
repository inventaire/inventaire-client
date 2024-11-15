<script lang="ts">
  import app from '#app/app'
  import { i18n } from '#user/lib/i18n'

  export let listing, uri

  const { name, creator, elements } = listing

  const { comment } = elements?.find(el => el.uri === uri)

  let username

  const getCreator = async () => {
    ;({ username } = await app.request('get:user:data', creator))
  }

  const waitingForUserdata = getCreator()
</script>

{#if comment}
  <div class="entity-listing-comment-layout">
    <div class="first-row">
      <div class="element-comment">
        {comment}
      </div>
      <div class="creator-info" aria-label={i18n('list_created_by', { username })}>
        {#await waitingForUserdata then}
          <span class="username">{username}</span>
        {/await}
      </div>
    </div>

    <div class="last-row">
      <div class="listing-name">
        {name}
      </div>
    </div>
  </div>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .entity-listing-comment-layout{
    @include display-flex(column);
    width: 100%;
    overflow-y: auto;
  }
  .first-row, .last-row{
    @include display-flex(row, center, space-between);
  }
</style>
