<script>
  import { i18n, I18n } from 'modules/user/lib/i18n'
  import Toggler from 'lib/components/notification_toggler.svelte'
  import Flash from 'lib/components/flash.svelte'
  import { user } from 'app/modules/user/user_store'
  import { range } from 'underscore'

  let flashPeriodicity
  const days = range(1, 180).filter(num => num <= 30 || num % 10 === 0)

  const updatePeriodicity = async periodicity => {
    flashPeriodicity = null
    try {
      await app.request('user:update', {
        attribute: 'summaryPeriodicity',
        value: parseInt(periodicity)
      })
    } catch (err) {
      flashPeriodicity = err
    }
  }

  $: notificationData = $user.settings.notifications || {}
</script>

<div class="wrapper">
  <h2 class="first-title">{I18n('notifications')}</h2>
  <div class="note">{I18n('notifications_description')}</div>
  <div class="notification-border">
    <section class="first-section">
      <h3>{I18n('global')}</h3>
      <Toggler name="global" value={notificationData.global}/>
    </section>
    {#if notificationData.global}
      <section>
        <h3>{I18n('news')}</h3>
        <Toggler name="inventories_activity_summary" value={notificationData.inventories_activity_summary}/>
        {#if notificationData.inventories_activity_summary}
          <div>
            <span>{@html I18n('activity_summary_periodicity_tip')}</span>
            <select name="periodicity" value={$user.summaryPeriodicity} on:change={e => updatePeriodicity(e.target.value)}>
              {#each days as day}
                <option value="{day}">{day}</option>
              {/each}
            </select>
          </div>
        {/if}
        <Flash bind:value={flashPeriodicity}/>
      </section>
      <section>
        <h3>{I18n('friends')}</h3>
        <div class="note">{i18n('email me when')}</div>
        <Toggler name="friendship_request" value={notificationData.friendship_request}/>
        <Toggler name="friend_accepted_request" value={notificationData.friend_accepted_request}/>
      </section>
      <section>
        <h3>{I18n('groups')}</h3>
        <div class="note">{i18n('email me when')}</div>
        <Toggler name="group_invite" value={notificationData.group_invite}/>
        <Toggler name="group_acceptRequest" value={notificationData.group_acceptRequest}/>
      </section>
      <section>
        <h3>{I18n('exchanges')}</h3>
        <div class="note">{i18n('email me when')}</div>
        <Toggler name="your_item_was_requested" value={notificationData.your_item_was_requested}/>
        <Toggler name="update_on_your_item" value={notificationData.update_on_your_item}/>
        <Toggler name="update_on_item_you_requested" value={notificationData.update_on_item_you_requested}/>
      </section>
    {/if}
  </div>
</div>

<style lang="scss">
  @import 'app/modules/settings/scss/common_settings';
  .notification-border{
    margin-top: 1em;
    border: 1px solid #CCC;
    border-radius: 3px;
    section:last-child {
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
    color: $grey;
    font-size: 90%;
    margin-bottom: 0
  }
  h3{
    margin-top: 1em;
    margin-bottom: 0.2em;
    font: sans-serif;
    font-size: 110%;
    font-weight: 600;
  }
  /*Small screens*/
  @media screen and (max-width: 470px) {
    .wrapper{
      margin: 0;
    }
  }
</style>
