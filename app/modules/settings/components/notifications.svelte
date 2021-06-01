<script>
  import { i18n, I18n } from 'modules/user/lib/i18n'
  import Toggler from 'lib/components/toggler.svelte'
  import Flash from 'lib/components/flash.svelte'

  const notificationData = app.user.get('settings.notifications')
  const days = []
  let num, hidePeriodicity, showFlashPeriodicity, hideFlashPeriodicity
  notificationData.inventories_activity_summary ? hidePeriodicity = '' : hidePeriodicity = 'hidden'

  let togglePeriodicity = togglerState => {
    togglerState ? hidePeriodicity = '' : hidePeriodicity = 'hidden'
  }
  for (num = 1; num <= 180; num++) {
    if ((num <= 30) || ((num % 10) === 0)) {
      days.push(num)
    }
  }
  const periodicity = app.user.get('summaryPeriodicity') || 20
  const updatePeriodicity = requestedPeriodicity => {
    hideFlashPeriodicity()
    const value = parseInt(requestedPeriodicity)
    try {
      return app.request('user:update', {
        attribute: 'summaryPeriodicity',
        value
      })
    } catch {
      showFlashPeriodicity({
        priority: 'error',
        message: I18n('something went wrong, try again later')
      })
    }
  }
</script>
<div class="wrapper">
  <h2 class="title first-title">{I18n('notifications')}</h2>
  <div class="note">{i18n('notifications_description')}</div>
  <!--  Choose how you receive email notifications. -->
  <div class="notification-border">
    <section class="first-section">
      <h3 class="label">{I18n('global')}</h3>
      <Toggler name="global" state={notificationData.global}/>
    </section>
    <section>
      <h3 class="label">{I18n('news')}</h3>
      <Toggler name="inventories_activity_summary" state={notificationData.inventories_activity_summary} bind:togglePeriodicity={togglePeriodicity}/>
      <div class={hidePeriodicity}>
        <span>{@html I18n('activity_summary_periodicity_tip')}</span>
        <select name="periodicity" on:blur="{e => updatePeriodicity(e.target.value)}" value={periodicity}>
          {#each days as day}
            <option value="{ day }">{ day }</option>
          {/each}
        </select>
      </div>
      <Flash bind:show={showFlashPeriodicity} bind:hide={hideFlashPeriodicity}/>
    </section>
    <section>
      <h3 class="label">{I18n('friends')}</h3>
      <div class="note">{i18n('email me when')}</div>
      <Toggler name="friendship_request" state={notificationData.friendship_request}/>
      <Toggler name="friend_accepted_request" state={notificationData.friend_accepted_request}/>
    </section>
    <section>
      <h3 class="label">{I18n('groups')}</h3>
      <div class="note">{i18n('email me when')}</div>
      <Toggler name="group_invite" state={notificationData.group_invite}/>
      <Toggler name="group_acceptRequest" state={notificationData.group_acceptRequest}/>
    </section>
    <section>
      <h3 class="label">{I18n('exchanges')}</h3>
      <div class="note">{i18n('email me when')}</div>
      <Toggler name="your_item_was_requested" state={notificationData.your_item_was_requested}/>
      <Toggler name="update_on_your_item" state={notificationData.update_on_your_item}/>
      <Toggler name="update_on_item_you_requested" state={notificationData.update_on_item_you_requested}/>
    </section>
  </div>
</div>

<style lang="scss">
  @import 'app/modules/general/scss/utils';
  @import 'app/modules/settings/scss/section_settings_svelte';
  .title{
    padding-bottom: 0.3em;
    margin-bottom: 0.5em;
  }
  .notification-border{
    margin-top: 1em;
    border: 1px solid #CCC;
    border-radius: 3px;
    :last-child {
      border-bottom: 0;
    }

  }
  .wrapper{
    margin: 0 1.5em;
  }
  section{
    border-bottom: 1px solid #CCC;
    padding: 1em;
    padding-top: 0;
  }
  .note{
    margin-bottom: 0
  }
  /*Small screens*/
  @media screen and (max-width: 470px) {
    .wrapper{
      margin: 0;
    }
  }
  .hidden{
    display: none;
  }

</style>
