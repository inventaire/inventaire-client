<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { userGroups } from '#user/user_groups_store'
  import { uniq } from 'underscore'
  import { getGroupVisibilityKey, isNotGroupVisibilityKey } from '#general/lib/visibility'

  export let visibility = []
  let checked = visibility
  $: allGroupsVisibilityKeys = $userGroups.map(getGroupVisibilityKey)
  $: checked != null && updateVisibility()
  $: allGroups = visibility.includes('groups')

  function updateVisibility () {
    if (checked.includes('groups')) {
      visibility = checked.filter(isNotGroupVisibilityKey)
    } else {
      visibility = checked
    }
  }

  function onAllGroupsClick (e) {
    if (e.target.checked) {
      checked = uniq(checked.concat([ 'groups', ...allGroupsVisibilityKeys ]))
    } else {
      checked = checked.filter(key => isNotAllGroupsKey(key) && isNotGroupVisibilityKey(key))
    }
  }

  function onGroupClick (e) {
    if (!e.target.checked) {
      checked = checked.filter(key => isNotAllGroupsKey(key) && key !== e.target.value)
    }
  }

  const isNotAllGroupsKey = key => key !== 'groups'
</script>

<fieldset>
  <legend>{I18n('visibility')}</legend>

  <label>
    <input type="checkbox" value="public" bind:group={checked}>
    {i18n('public')}
  </label>

  <label>
    <input type="checkbox" value="friends" bind:group={checked}>
    {i18n('friends')}
  </label>

  <label>
    <input
      type="checkbox"
      value="groups"
      bind:group={checked}
      on:click={onAllGroupsClick}
    >
    {i18n('groups')}
  </label>

  {#each $userGroups as group}
    <label
      class="indent"
      class:inferred={allGroups}
      >
      <input
        type="checkbox"
        value="group:{group._id}"
        bind:group={checked}
        on:click={onGroupClick}
      >
      {group.name}
    </label>
  {/each}
</fieldset>

<style lang="scss">
  @import '#general/scss/utils';
  label{
    font-size: 1rem;
  }
  .indent{
    margin-left: 1.4em;
  }
  .inferred:not(:hover){
    opacity: 0.7;
  }
</style>
