<script lang="ts">
  import { API } from '#app/api/api'
  import app from '#app/app'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import preq from '#app/lib/preq'
  import { getLocalTimeString, timeFromNow } from '#app/lib/time'
  import { loadLink } from '#app/lib/utils'
  import InfiniteScroll from '#components/infinite_scroll.svelte'
  import Contribution from '#entities/components/patches/contribution.svelte'
  import { serializePatches } from '#entities/lib/patches'
  import { mainUserHasAdminAccess } from '#modules/user/lib/main_user'
  import { i18n, I18n } from '#user/lib/i18n'
  import type { SerializedContributor } from '#users/lib/users'

  export let contributor: SerializedContributor = null
  export let filter = null

  let contributions = []
  const userContributionsContext = contributor != null

  let fetching = false
  let limit = 10
  let offset = 0
  let flash, hasMore, total

  async function fetchMore () {
    limit = Math.min(limit * 2, 500)
    const acct = contributor?.acct
    const { patches, continue: continu, total: _total } = await preq.get(API.entities.contributions({
      acct,
      limit,
      offset,
      filter,
    }))
    hasMore = continu != null
    offset = continu
    total = _total
    contributions = contributions.concat(await serializePatches(patches))
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

  function removeFilter () {
    app.navigateAndLoad(contributor.contributionsPathname)
  }
</script>

<div class="contributions">
  <h3>
    {#if contributor}
      {I18n('contributions_by', { username: contributor.handle || contributor.acct })}
    {:else}
      {I18n('recent changes')}
    {/if}
    {#if filter}
      <span class="filter">
        {filter}
        <button class="remove-filter" title={I18n('remove filter')} on:click={removeFilter}>&#215;</button>
      </span>
    {/if}
  </h3>

  {#if contributor}
    <ul class="stats">
      {#if !contributor.special}
        {#if contributor.pathname}
          <li class="profile">
            <span class="stat-label">{i18n('profile')}</span>
            <a class="link" href={contributor.pathname} on:click={loadLink}>{contributor.username || contributor.acct}</a>
            <div class="user-status">
              {#if contributor.deleted}
                <span class="deleted">{@html icon('times')} {i18n('deleted')}</span>
              {:else if !contributor.found}
                <span class="not-found">{@html icon('times')} {i18n('not found')}</span>
              {:else if contributor.settings.contributions.anonymize}
                <span class="anonymized">{@html icon('user-secret')} {i18n('anonymized')}</span>
              {:else}
                <span class="public">{@html icon('globe')} {i18n('public contributions')}</span>
              {/if}
            </div>
          </li>
        {/if}
        {#if mainUserHasAdminAccess() && contributor._id}
          <li>
            <span class="stat-label">id</span>
            <span class="stat-value">{contributor._id}</span>
          </li>
        {/if}
        <li>
          <span class="stat-label">{i18n('account uri')}</span>
          <span class="stat-value">{contributor.acct}</span>
        </li>
        {#if contributor.roles?.length > 0}
          <li>
            <span class="stat-label">{i18n('roles')}</span>
            <span class="stat-value">{contributor.roles}</span>
          </li>
        {/if}
      {/if}
      {#if contributor?.found && total != null}
        <li>
          <span class="stat-label">{i18n('contributions')}</span>
          <span class="stat-value total">{total}</span>
        </li>
      {/if}
      {#if contributor?.created}
        <li>
          <span class="stat-label">{i18n('created')}</span>
          <p class="stat-value">
            <span class="time-from-now">{timeFromNow(contributor.created)}</span>
            <span class="precise-time">{getLocalTimeString(contributor.created)}</span>
          </p>
        </li>
      {/if}
    </ul>
  {/if}
</div>

<Flash state={flash} />

<InfiniteScroll {keepScrolling} showSpinner={true}>
  <ul class="contributions-list">
    {#each contributions as patch}
      <Contribution {patch} {userContributionsContext} />
    {/each}
  </ul>
</InfiniteScroll>

<style lang="scss">
  @import "#general/scss/utils";

  .contributions, .contributions-list{
    margin: 0 auto;
    max-width: 100em;
    overflow: hidden;
    @include display-flex(column, center, center);
  }
  h3{
    text-align: center;
    @include display-flex(row, center, center);
    .filter{
      margin: 0 1em;
      @include display-flex(row, center, center);
      @include sans-serif;
      background-color: $light-blue;
      padding-inline-start: 0.2rem;
      font-size: 1rem;
      border-radius: $global-radius;
      color: white;
    }
    .remove-filter{
      @include tiny-button($light-blue);
      font-size: 1.5rem;
      line-height: 1rem;
      padding: 0.5rem;
      align-self: stretch;
    }
  }
  .profile{
    @include display-flex(row, center, flex-start);
  }
  .user-status{
    @include display-flex(row, center, flex-start);
    span{
      margin: 0 0.5rem;
      background-color: white;
      padding: 0 0.5rem 0 0.2rem;
      @include radius;
    }
    .deleted, .not-found{
      background-color: $warning-color;
      color: white;
    }
    .anonymized{
      background-color: $dark-grey;
      color: white;
    }
  }
  .stats{
    padding: 1em;
    background-color: $light-grey;
    .stat-label{
      display: inline-block;
      min-width: 10em;
      color: #777;
    }
  }
  .stat-value{
    display: inline-block;
  }
  .precise-time{
    margin-inline-start: 0.5em;
    color: $grey;
  }
  .contributions-list{
    margin-block-start: 1em;
    align-self: stretch;
    @include display-flex(column, stretch, center);
  }
</style>
