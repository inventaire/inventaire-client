<script>
  import { I18n } from '#user/lib/i18n'
  import { userGroups } from '#user/user_groups_store'
  import { uniq, without } from 'underscore'
  import { getGroupVisibilityKey, isNotGroupVisibilityKey, commonVisibilityKeys } from '#general/lib/visibility'
  import { onChange } from '#lib/svelte'

  export let visibility = []

  // Needs to be above reactive call to initCheckedGroupKeys
  $: allGroupsVisibilityKeys = $userGroups.map(getGroupVisibilityKey)

  // Group keys will be added to 'checked' once $userGroups will have been populated
  let checked = visibility[0] === 'public' ? commonVisibilityKeys : visibility
  $: onChange($userGroups, initCheckedGroupKeys)

  function initCheckedGroupKeys () {
    if (visibility.includes('public') || visibility.includes('groups')) checkAllGroups()
  }

  function updateCheckedGroupsKeys (allGroupsChecked) {
    if (allGroupsChecked) checkAllGroups()
    else uncheckAllGroups()
  }

  function checkAllGroups () {
    checked = uniq([ ...checked, 'groups', ...allGroupsVisibilityKeys ])
  }

  function uncheckAllGroups () {
    checked = without(checked, 'public', 'groups', ...allGroupsVisibilityKeys)
  }

  function onPublicClick (e) {
    if (e.target.checked) {
      checked = commonVisibilityKeys.concat(allGroupsVisibilityKeys)
    }
  }

  function onFriendsClick (e) {
    if (!e.target.checked) {
      checked = without(checked, 'public', 'friends')
    }
  }

  function onGroupsClick (e) {
    updateCheckedGroupsKeys(e.target.checked)
  }

  function onSingleGroupClick (e) {
    if (!e.target.checked) {
      checked = without(checked, 'public', 'groups', e.target.value)
    }
  }

  $: onChange(checked, updateVisibility)

  function updateVisibility () {
    if (checked.includes('public')) {
      visibility = [ 'public' ]
    } else if (checked.includes('groups')) {
      visibility = checked.filter(isNotGroupVisibilityKey)
    } else {
      visibility = checked
    }
  }
</script>

<fieldset>
  <legend>{I18n('visibility')}</legend>

  <div class="options">
    <label>
      <input
        type="checkbox"
        value="public"
        on:click={onPublicClick}
        bind:group={checked}
        >
      {I18n('public')}
    </label>

    <label
      class:inferred={visibility.includes('public')}
      >
      <input
        type="checkbox"
        value="friends"
        on:click={onFriendsClick}
        bind:group={checked}
      >
      {I18n('friends')}
    </label>

    <label
      class:inferred={visibility.includes('public')}
      >
      <input
        type="checkbox"
        value="groups"
        on:click={onGroupsClick}

        bind:group={checked}
      >
      {I18n('groups')}
    </label>

    {#each $userGroups as group}
      <label
        class="indent"
        class:inferred={visibility.includes('public') || visibility.includes('groups')}
        >
        <input
          type="checkbox"
          value="group:{group._id}"
          on:click={onSingleGroupClick}

          bind:group={checked}
        >
        {group.name}
      </label>
    {/each}
  </div>
</fieldset>

<style lang="scss">
  @import '#general/scss/utils';
  .options{
    max-height: 25em;
    overflow-y: auto;
  }
  label{
    padding: 0.2em 0.5em;
    font-size: 1rem;
    color: $dark-grey;
    &:hover{
      background-color: $light-grey;
    }
  }
  .indent{
    margin-left: 1.3em;
  }
  .inferred:not(:hover){
    opacity: 0.7;
  }
</style>
