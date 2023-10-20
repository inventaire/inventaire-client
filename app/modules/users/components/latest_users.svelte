<script>
  import Spinner from '#components/spinner.svelte'
  import Flash from '#lib/components/flash.svelte'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import preq from '#lib/preq'
  import { loadInternalLink, simpleTime } from '#lib/utils'
  import { I18n, i18n } from '#user/lib/i18n'
  import { serializeUser } from '#users/lib/users'

  let flash
  let users = []
  let limit = 10
  let offset, fetching
  async function fetchMore () {
    try {
      offset = offset == null ? 0 : offset += limit
      fetching = preq.get(app.API.users.byCreationDate({ limit, offset }))
      const { users: newUsers } = await fetching
      users = users.concat(newUsers.map(serializeUser))
    } catch (err) {
      flash = err
    }
  }

  fetchMore()
</script>

<h2>{i18n('Latest created users')}</h2>

<Flash state={flash} />

<ul>
  {#each users as user (user._id)}
    <li>
      <img src={imgSrc(user.picture, 64)} alt="" loading="lazy" />
      <div class="info">
        <div class="header">
          <span class="username">{user.username}</span>
          <span class="id">{user._id}</span>
          <span class="created">{simpleTime(user.created)}</span>
        </div>
        <p class="bio">{user.bio || ''}</p>
        <p class="links">
          <a class="link" on:click={loadInternalLink} href={user.pathname}>{I18n('profile')}</a> -
          <a class="link" target="_blank" href={`${user.pathname}.json`}>{I18n('json')}</a> -
          <a class="link" on:click={loadInternalLink} href={user.contributionsPathname}>{I18n('contributions')}</a>
        </p>
      </div>
    </li>
  {/each}
</ul>

{#await fetching}
  <Spinner center={true} />
{:then}
  <button on:click={fetchMore} class="button">
    {i18n('Fetch more')}
  </button>
{/await}

<style lang="scss">
  @import "#general/scss/utils";
  h2{
    text-align: center;
    margin: 0.5em;
    display: flex;
    flex-direction: column;
    align-items: stretch;
    justify-content: center;
  }
  li{
    display: flex;
    flex-direction: row;
    align-items: flex-start;
    justify-content: flex-start;
    max-width: 50em;
    background-color: $light-grey;
    padding: 0.5em;
    margin: 0.5em auto;
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
    margin-top: 0.5em;
    margin-right: 0.5em;
  }
  .bio{
    max-height: 8em;
    overflow: auto;
  }
  button{
    display: block;
    margin: 2em auto;
  }
</style>
