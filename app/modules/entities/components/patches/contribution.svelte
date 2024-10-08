<script lang="ts">
  import Link from '#app/lib/components/link.svelte'
  import { imgSrc } from '#app/lib/handlebars_helpers/images'
  import { icon } from '#app/lib/icons'
  import { getISOTime, getLocalTimeString, timeFromNow } from '#app/lib/time'
  import { loadInternalLink } from '#app/lib/utils'
  import Operation from '#entities/components/patches/operation.svelte'
  import { getClaimValue } from '#entities/lib/entities'
  import { I18n, i18n } from '#user/lib/i18n'

  export let patch
  export let userContributionsContext = false

  const { _id: patchId, patchType, summary, timestamp, operations, user = {}, entity, invEntityHistoryPathname } = patch

  let showDetails = false

  function getSummaryValues (values) {
    if (values instanceof Array) {
      return values.map(getClaimValue)
    } else {
      return getClaimValue(values)
    }
  }
</script>

<div class="contribution">
  <div class="header">
    <button class="handle" on:click={() => showDetails = !showDetails}>
      <div class="togglers">
        {#if showDetails}
          <span>{@html icon('caret-down')}</span>
        {:else}
          <span>{@html icon('caret-right')}</span>
        {/if}
      </div>
      <span class="operation-type {patchType}">{patchType}</span>
    </button>
    {#if entity}
      <div class="entity">
        <a class="label link" href={entity.pathname} on:click={loadInternalLink}>{entity.label}</a>
        <div class="entity-meta">
          <span class="entity-type">{entity.type}</span>
          <span class="patch-id">{patchId}</span>
          <div class="icons">
            <Link
              icon="pencil"
              url={entity.editPathname}
              classNames="link"
              title={I18n('edit data')}
            />
            <Link
              icon="history"
              url={invEntityHistoryPathname}
              classNames="link"
              title={I18n('show entity history')}
            />
            <!-- Known case: merged entities -->
            {#if entity.historyPathname !== invEntityHistoryPathname}
              <Link
                icon="history"
                url={entity.historyPathname}
                classNames="link"
                title={I18n('show entity history')}
              />
            {/if}
          </div>
        </div>
      </div>
    {/if}
    {#if summary}
      <div class="summary">
        {#if summary.operationsCount === 1}
          <div class="property">
            <p class="property-label">{summary.propertyLabel}</p>
            {#if summary.property}<p class="property-uri">{summary.property}</p>{/if}
          </div>
          <div class="changes">
            {#if summary.removed}<p class="removed">{getSummaryValues(summary.removed)}</p>{/if}
            {#if summary.added}<p class="added">{getSummaryValues(summary.added)}</p>{/if}
          </div>
        {:else}
          <div>
            <span title={summary.touchedProperties}>{I18n('operations')}: {summary.operationsCount}</span>
          </div>
        {/if}
      </div>
    {/if}
    <div class="line-end">
      {#if !userContributionsContext}
        <a
          class="user"
          class:special={user.special}
          href={user.contributionsPathname}
          title={user.special ? i18n('bot') : user.roles?.join(' ') || ''}
          on:click={loadInternalLink}
        >
          <p class="username">{user.username}</p>
          {#if user.special}
            {@html icon('cogs')}
          {:else}
            <img src={imgSrc(user.picture, 32)} alt={user.username} loading="lazy" />
          {/if}
        </a>
      {/if}
      <p class="time" title={`${timeFromNow(timestamp)} | ${getISOTime(timestamp)}`}>{getLocalTimeString(timestamp)}</p>
    </div>
  </div>
  {#if showDetails}
    <div class="full-details">
      {#if !userContributionsContext}
        <ul class="stats">
          <li>
            <span class="stat-label">{i18n('user')}</span>
            <span class="stat-value">{user._id}</span>
          </li>
        </ul>
      {/if}
      <ul class="operations">
        {#each operations as operation}
          <Operation {operation} showContributionFilter={userContributionsContext} />
        {/each}
      </ul>
    </div>
  {/if}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .contribution{
    background-color: white;
    padding: 0.2em 0.5em;
    margin: 0.2em 0;
    flex: 1 0 0;
    @include display-flex(column);
  }
  .header{
    @include display-flex(row, center, flex-start);
    flex: 1 0 auto;
  }
  .handle{
    @include display-flex(row, center, center);
    cursor: pointer;
  }
  .entity{
    flex: 1 0 0;
  }
  .entity-meta{
    :global(.link){
      @include shy;
    }
  }
  .label{
    font-weight: bold;
    overflow: hidden;
    max-height: 1.4em;
    margin-inline-end: 0.5em;
  }
  .patch-id, .entity-type{
    color: $grey;
    font-size: 0.9em;
    margin-inline-end: 0.2em;
  }
  .entity-type{
    font-weight: bold;
  }
  .changes{
    flex: 1;
    p{
      line-height: 1em;
    }
  }
  .summary{
    flex: 1 0 10em;
    overflow-x: auto;
    padding: 0.5em;
    max-width: 40em;
    background-color: $off-white;
    @include display-flex(row, center, flex-start);
    white-space: nowrap;
    .property{
      flex: 0 0 6em;
      p{
        line-height: 1.2em;
      }
    }
    .property-uri{
      color: $grey;
      font-size: 0.9;
    }
    .changes{
      flex: 1;
      margin-inline-start: 0.5em;
    }
    .added{
      color: green;
      &::before{ content: "+ "; }
    }
    .removed{
      color: red;
      &::before{ content: "- "; }
    }
  }
  .line-end{
    margin-inline-start: auto;
    @include display-flex(row, center, flex-end);
  }
  .user{
    width: 8em;
    @include display-flex(row, center, flex-end);
    @include transition(background-color);
    @include radius;
    &:hover{
      background-color: $off-white;
    }
    padding: 0.2em;
    img{
      @include radius;
      margin-inline-start: 0.5em;
    }
    &.special{
      :global(.fa-cogs){
        width: 2em;
        margin-inline-start: 0.5em;
      }
    }
  }
  .time{
    color: $grey;
    padding-inline-start: 0.2em;
    width: 6em;
    text-align: end;
  }
  .togglers span{
    cursor: pointer;
  }
  .operation-type{
    padding: 0 0.2em;
    width: 5em;
    @include radius;
    margin-inline-end: 0.5em;
    border: 2px solid black;
    &.creation{ border-color: $green-tree; }
    &.add{ border-color: $success-color; }
    &.update{ border-color: $light-blue; }
    &.remove{ border-color: $soft-red; }
    &.redirect{ border-color: $yellow; }
    &.deletion{ border-color: $dark-grey; }
  }

  .full-details{
    .stats{
      padding: 0.5em;
      li{
        @include display-flex(row, center, flex-start);
      }
      .stat-label{
        min-width: 5em;
      }
    }
  }
  /* Small screens */
  @media screen and (width < $small-screen){
    .contribution{
      max-width: 98vw;
    }
    .handle{
      margin: 0.5em 0;
    }
    .header{
      flex-wrap: wrap;
      align-self: stretch;
    }
    .entity{
      min-width: min(20em, 80vw);
    }
    .summary{
      min-width: min(20em, 80vw);
      margin-inline-end: auto;
    }
  }
  /* Smaller screens */
  @media screen and (width < $smaller-screen){
    .user{
      // Force to wrap on the next line
      flex: 1 0 50%;
      margin: 1em 0;
    }
    .entity-meta{
      @include display-flex(row, center, flex-start, wrap);
      :global(.fa){
        margin: 0 0.5em;
        padding: 0.5em;
      }
    }
  }
  /* Large screens */
  @media screen and (width >= $smaller-screen){
    .entity{
      margin-inline-end: auto;
    }
    .entity-meta{
      @include display-flex(row, center, flex-start);
      :global(.fa){
        padding-inline: 0.5em;
        margin-inline-start: 0.2em;
      }
    }
    .entity-type{
      font-weight: bold;
      width: 4em;
    }
    .patch-id{
      width: 16em;
    }
  }
</style>
