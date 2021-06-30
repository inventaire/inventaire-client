<script>
  import { i18n, I18n } from 'modules/user/lib/i18n'
  import preq from 'lib/preq'
  import Spinner from 'modules/general/components/spinner.svelte'
  import { isOpenedOutside } from 'lib/utils'
  let usersData
  let highest = 0
  export let title, period

  const getContributionsData = async () => {
    const res = await preq.get(app.API.entities.usersContributions(period))
    usersData = await addUsersData(res)
  }

  const addUsersData = async res => {
    let { contributions: contributionRows } = res
    if (contributionRows.length === 0) return []
    contributionRows = contributionRows.slice(0, 10)
    const usersIds = contributionRows.map(_.property('user'))
    const { users } = await preq.get(app.API.users.byIds(usersIds))
    // assuming contributions are already sorted
    highest = contributionRows[0].contributions
    contributionRows.forEach(row => row.user = users[row.user])
    return contributionRows
  }

  const showUserContributions = (e, user) => {
    if (!isOpenedOutside(e)) {
      app.execute('show:user:contributions', user._id)
    }
  }
</script>

<section>
  <h2>{I18n(title)}</h2>
  {#await getContributionsData()}
    <p class="loading">Loading... <Spinner/></p>
  {:then}
    <div class="row">
      <div class="cell title">{i18n('user')}</div>
      <div class="cell title right">{i18n('contributions')}</div>
    </div>
    {#each usersData as userData}
    <div class="row">
      <div class="cell user {userData.user.deleted ? 'deleted' : ''}">
        <a href="/u/{userData.user._id}/contributions" class="link" on:click="{e => showUserContributions(e, userData.user)}">{userData.user.username}</a>
      </div>
      <div class="histogram">
        <div class="contributions">
          {userData.contributions}
        </div>
        <div class="bar" style="width: {userData.contributions * 100.0 / highest}px;"></div>
      </div>
    </div>
    {:else}
      no contributions
    {/each}
  {/await}
</section>

<style lang="scss">
  @import 'app/modules/general/scss/utils';
  section{
    min-width: 20em;
    max-width: 50em;
    background-color: white;
    padding: 1em;
    margin: 0.5em;
  }
  .contributions {
    padding: 0 0.5em;
    position: absolute;
    flex: 2 0 auto;
  }
  .row{
    display: flex;
    flex-direction: row;
  }
  .histogram{
    min-width: 100px;
    margin: 0.1em 0.2em;
  }
  .bar{
    background-color: $light-grey;
    height: 100%;
  }
  .cell{
    flex: 1 0 auto;
    background-color: $light-grey;
    padding: 0 0.5em;
    margin: 0.1em 0;
  }
  .deleted{
    color: red;
  }
  .right{
    text-align: right;
  }
  .title{
    background-color: white;
  }
</style>
