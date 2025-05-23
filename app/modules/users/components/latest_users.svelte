<script lang="ts">
  import { API } from '#app/api/api'
  import Flash from '#app/lib/components/flash.svelte'
  import { getLocalStorageStore } from '#app/lib/components/stores/local_storage_stores'
  import { imgSrc } from '#app/lib/image_source'
  import preq from '#app/lib/preq'
  import { onChange } from '#app/lib/svelte/svelte'
  import { getISOTime, getSimpleTime } from '#app/lib/time'
  import { loadInternalLink } from '#app/lib/utils'
  import Spinner from '#components/spinner.svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import { serializeUser } from '#users/lib/users'

  let flash, fetching
  let users = []
  const limit = 10
  let offset = 0

  const withReportsOnly = getLocalStorageStore('display-latest-users-with-reports-only', false)

  async function fetchMore () {
    try {
      const filter = $withReportsOnly ? 'with-reports' : undefined
      fetching = preq.get(API.users.byCreationDate({ limit, offset, filter }))
      offset += limit
      const { users: newUsers } = await fetching
      users = users.concat(newUsers.map(serializeUser))
    } catch (err) {
      flash = err
    }
  }

  function resetUsers () {
    offset = 0
    users = []
    fetchMore()
  }

  $: onChange($withReportsOnly, resetUsers)
</script>

<h2>{i18n('Latest created users')}</h2>

<div class="controls-top">
  <label>
    <input type="checkbox" bind:checked={$withReportsOnly} />
    {i18n('Display only users with abuse reports')}
  </label>
</div>

<Flash state={flash} />

<ul>
  {#each users as user (user._id)}
    <li>
      <div class="user-top">
        <img src={imgSrc(user.picture, 64)} alt="" loading="lazy" />
        <div class="info">
          <div class="header">
            <span class="username">{user.username}</span>
            <span class="id">{user._id}</span>
            <span class="created">{getSimpleTime(user.created)}</span>
          </div>
          <p class="bio">{user.bio || ''}</p>
          <p class="links">
            <a class="link" on:click={loadInternalLink} href={user.pathname}>{I18n('profile')}</a> -
            <a class="link" target="_blank" href={`${user.pathname}.json`}>JSON</a> -
            <a class="link" on:click={loadInternalLink} href={user.contributionsPathname}>{I18n('contributions')}</a>
          </p>
        </div>
      </div>
      {#if user.reports?.length > 0}
        <div class="reports">
          <h4>{i18n('Abuse reports')}</h4>
          <ul>
            {#each user.reports as { type, text, timestamp }}
              <li>
                <span class="report-type">{type}</span>
                <span class="report-timestamp">{getISOTime(timestamp)}</span>
                <span class="report-text">{text}</span>
              </li>
            {/each}
          </ul>
        </div>
      {/if}
    </li>
  {/each}
</ul>

<div class="controls-bottom">
  {#await fetching}
    <Spinner center={true} />
  {:then}
    <button on:click={fetchMore} class="button">
      {i18n('Fetch more')}
    </button>
  {/await}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  h2{
    text-align: center;
    margin: 0.5em 0 0;
    display: flex;
    flex-direction: column;
    align-items: stretch;
    justify-content: center;
  }
  .controls-top, li{
    max-width: 50em;
  }
  li{
    margin: 0.5em auto;
    background-color: $light-grey;
    padding: 0.5em;
  }
  .controls-top, .controls-bottom{
    @include display-flex(row, center, center);
  }
  .controls-top{
    margin: 1rem auto;
    @include display-flex(row, center, flex-start);
    label{
      font-size: 1rem;
      padding: 0.5rem;
      flex: 1;
      @include bg-hover($lighter-grey, 5%);
    }
  }
  .controls-bottom{
    height: 5em;
  }
  .user-top{
    @include display-flex(row, flex-start, flex-start);
  }
  .info{
    position: relative;
    flex: 1;
  }
  .header{
    display: flex;
    flex-direction: row;
    width: 100%;
  }
  .id{
    margin: 0 0.5em;
    color: $grey;
  }
  .created{
    margin-inline-start: auto;
    color: $grey;
  }
  .links a{
    color: $grey;
  }
  img{
    flex: 0 0 3em;
    margin-inline-end: 0.5em;
    height: 3rem;
    object-fit: cover;
  }
  p, a{
    line-height: normal;
  }
  .bio{
    max-height: 8em;
    overflow: auto;
  }
  button{
    display: block;
  }
  .reports{
    background-color: #ddd;
    padding: 0.2rem;
    margin-block-start: 0.5rem;
    h4{
      font-size: 1rem;
      @include sans-serif;
      font-weight: bold;
      line-height: 1rem;
      margin: 0.2rem;
    }
    li{
      padding: 0.5rem;
      margin: 0.2rem 0;
      @include radius;
      background-color: $yellow;
    }
  }
  .report-type, .report-timestamp{
    padding: 0.2rem 0.4rem;
    margin-inline-end: 0.2rem;
    @include radius;
  }
  .report-type{
    background-color: $grey;
    font-weight: bold;
    color: white;
  }
  .report-timestamp{
    background-color: $light-grey;
  }
  .report-text{
    font-style: italic;
    &::before, &::after{
      content: '"'
    }
  }
</style>
