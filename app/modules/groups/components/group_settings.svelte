<script lang="ts">
  import { slide } from 'svelte/transition'
  import { debounce } from 'underscore'
  import app from '#app/app'
  import { autosize } from '#app/lib/components/actions/autosize'
  import Flash from '#app/lib/components/flash.svelte'
  import { imgSrc } from '#app/lib/handlebars_helpers/images'
  import { icon } from '#app/lib/icons'
  import { wait } from '#app/lib/promises'
  import { onChange } from '#app/lib/svelte/svelte'
  import Modal from '#components/modal.svelte'
  import PicturePicker from '#components/picture_picker.svelte'
  import Spinner from '#components/spinner.svelte'
  import GroupOpenness from '#groups/components/group_openness.svelte'
  import GroupSearchability from '#groups/components/group_searchability.svelte'
  import GroupUrl from '#groups/components/group_url.svelte'
  import { leaveGroup, serializeGroup, updateGroupSetting } from '#groups/lib/groups'
  import PositionPicker from '#map/components/position_picker.svelte'
  import { i18n, I18n } from '#user/lib/i18n'

  export let group

  let { _id: groupId, name, description, searchable, open, picture, position, mainUserIsAdmin, pathname } = group

  $: userIsLastUser = (group.admins.length + group.members.length) === 1
  $: userCanLeave = !mainUserIsAdmin || group.admins.length > 1 || group.members.length === 0

  let nameFlash, savingName
  async function saveName () {
    try {
      group.name = name = name.trim()
      savingName = updateGroupSetting({ groupId, attribute: 'name', value: name })
      const res = await savingName
      nameFlash = { type: 'success', message: I18n('saved'), duration: 1000 }
      const { slug } = res.update
      group.slug = slug
      group = serializeGroup(group, { refresh: true })
      app.navigate(group.settingsPathname, { preventScrollTop: true })
      savingName = null
    } catch (err) {
      nameFlash = err
    }
  }

  let descriptionFlash, savingDescription
  async function saveDescription () {
    try {
      savingDescription = updateGroupSetting({ groupId, attribute: 'description', value: description })
      await savingDescription
      group.description = description
      // Leave the check mark visible for 0.5s
      await wait(500)
      savingDescription = null
    } catch (err) {
      descriptionFlash = err
    }
  }

  let savingSearchable
  async function saveSearchable () {
    await savingSearchable
    if (searchable === group.searchable) return
    savingSearchable = updateGroupSetting({ groupId, attribute: 'searchable', value: searchable })
    await savingSearchable
    savingSearchable = null
    group.searchable = searchable
  }
  const lazySaveSearchable = debounce(saveSearchable, 500)
  $: onChange(searchable, lazySaveSearchable)

  let savingOpenness
  async function saveOpenness () {
    await savingOpenness
    if (open === group.open) return
    savingOpenness = updateGroupSetting({ groupId, attribute: 'open', value: open })
    await savingOpenness
    savingOpenness = null
    group.open = open
  }
  const lazySaveOpenness = debounce(saveOpenness, 500)
  $: onChange(open, lazySaveOpenness)

  let showPicturePicker, showPositionPicker

  async function savePicture (imageHash) {
    const updatedPictureUrl = `/img/groups/${imageHash}`
    group.picture = picture = updatedPictureUrl
    await updateGroupSetting({ groupId, attribute: 'picture', value: updatedPictureUrl })
  }

  async function deletePicture () {
    group.picture = picture = null
    await updateGroupSetting({ groupId, attribute: 'picture', value: null })
  }

  async function savePosition (latLng) {
    group.position = position = latLng
    await updateGroupSetting({ groupId, attribute: 'position', value: latLng })
  }

  async function deleteGroup () {
    app.execute('ask:confirmation', {
      confirmationText: i18n('delete_group_confirmation', { groupName: name }),
      warningText: i18n('cant_undo_warning'),
      action: async () => {
        await leaveGroup({ groupId })
        // Change page as staying on the same page would just display
        // the group as empty but accepting a join request
        app.execute('show:inventory:network')
      },
    })
  }

  async function _leaveGroup () {
    app.execute('ask:confirmation', {
      confirmationText: i18n('leave_group_confirmation', { groupName: name }),
      warningText: i18n('leave_group_warning'),
      action: async () => {
        await leaveGroup({ groupId })
        app.navigateAndLoad(pathname)
      },
    })
  }
</script>

{#if mainUserIsAdmin}
  <section>
    <label for="edit-name-field">{I18n('group name')}</label>
    <div class="input-group">
      <input
        type="text"
        id="edit-name-field"
        bind:value={name}
        maxlength="80"
      />
      <button
        class="button success postfix"
        on:click={saveName}
        disabled={savingName != null || name === group.name}
        title={name === group.name ? i18n('"%{name}" is already the group name', { name }) : ''}
      >
        {#await savingName}
          <Spinner light={true} />
        {:then}
          {@html icon('check')}
        {/await}
        {I18n('save')}
      </button>
    </div>
    <GroupUrl {name} {groupId} bind:flash={nameFlash} />
    <Flash state={nameFlash} />
  </section>
  <hr />

  <section>
    <label for="editDescription">{I18n('description')}</label>
    <textarea
      id="editDescription"
      placeholder={I18n('help other users to understand what this group is about')}
      bind:value={description}
      maxlength="5000"
      use:autosize
    />
    {#if description !== group.description}
      <div class="textarea-buttons" transition:slide>
        <button
          class="cancelButton"
          on:click={() => description = group.description}
          disabled={savingDescription != null}
        >
          {@html icon('times')}
          {I18n('cancel')}
        </button>
        <button
          class="saveButton"
          on:click={saveDescription}
          disabled={savingDescription != null}
        >
          {#await savingDescription}
            <Spinner light={true} />
          {:then}
            {@html icon('check')}
          {/await}
          {I18n('save')}
        </button>
      </div>
    {/if}
    <Flash state={descriptionFlash} />
  </section>
  <hr />

  <GroupSearchability bind:searchable />

  <hr />

  <GroupOpenness bind:open />

  <hr />

  <section>
    <div class="changePicture">
      {#if picture}
        <img src={imgSrc(picture, 250, 250)} alt={i18n('Group picture')} />
      {/if}

      <button class="button grey" on:click={() => showPicturePicker = true}>
        {@html icon('camera')}
        {#if picture}
          {I18n('change picture')}
        {:else}
          {I18n('add a picture')}
        {/if}
      </button>
    </div>
  </section>
  <hr />

  <h4>{I18n('geolocation')}</h4>
  <div class="position-status">
    {#if position != null}
      {i18n('the group has a position set')}
      {@html icon('check')}
      <p class="coordinates">{position.join(', ')}</p>
    {:else}
      {i18n("the group's position isn't set yet")}
    {/if}
  </div>
  <div class="group-position-setting">
    <button class="button light-blue radius" on:click={() => showPositionPicker = true}>
      {@html icon('map-marker')}
      {I18n("set the group's position")}
    </button>
  </div>
  <hr />
{/if}

<section class="group-controls">
  {#if userCanLeave}
    {#if userIsLastUser}
      <button class="destroy" on:click={deleteGroup}>
        {@html icon('trash')} {I18n('delete group')}
      </button>
    {:else}
      <button class="leave" on:click={_leaveGroup}>
        {@html icon('sign-out')} {I18n('leave group')}
      </button>
    {/if}
  {:else}
    <span class="leave disabled" title={I18n('leave_button_disabled')}>
      {@html icon('ban')} {I18n('leave group')}
    </span>
    <p class="reason">{I18n('leave_button_disabled')}</p>
  {/if}
</section>

{#if showPicturePicker}
  <Modal on:closeModal={() => showPicturePicker = false}>
    <PicturePicker
      {picture}
      imageContainer="groups"
      aspectRatio={1.5}
      {savePicture}
      {deletePicture}
      on:close={() => showPicturePicker = false}
    />
  </Modal>
{/if}

{#if showPositionPicker}
  <Modal size="large" on:closeModal={() => showPositionPicker = false}>
    <PositionPicker
      type="group"
      {position}
      {savePosition}
      on:positionPickerDone={() => showPositionPicker = false}
    />
  </Modal>
{/if}

<style lang="scss">
  @import "#general/scss/utils";

  input, textarea{
    // sections already have padding/margin
    margin: 0 0 0.2em;
  }
  label, h4{
    text-align: start;
    font-size: 1em;
    color: black;
    @include sans-serif;
  }
  .group-controls{
    padding-block: 2em;
    text-align: center;
  }
  .leave, .destroy{
    @include dangerous-button;
    @include radius;
    font-weight: bold;
  }
  .leave{
    &.disabled{
      cursor: not-allowed;
      &:hover{
        // disabling dangerous-button hover behaviour
        background-color: $grey;
      }
    }
  }
  .reason{
    // hacky compensation of the weird positioning
    // that would overlap the button if there wasn't that padding
    padding-block-start: 1em;
  }
  .position-status{
    background-color: #ddd;
    @include radius;
    margin: auto;
    padding: 1em;
    text-align: center;
    :global(.fa){
      font-size: 0.8em;
      padding-inline-start: 0.6em;
      opacity: 0.6;
    }
    .coordinates{
      opacity: 0.6;
    }
  }
  .group-position-setting{
    @include display-flex(row, center, center);
    padding-block: 1em;
  }

  label, .postfix{
    font-size: 1rem;
  }
  button:disabled{
    opacity: 0.8;
  }
  .input-group{
    button{
      font-weight: normal;
      min-width: 8em;
    }
  }
  .textarea-buttons{
    @include display-flex(row, center, center);
    button{
      margin: 0.5em 0.2em 0;
    }
  }

  .changePicture{
    margin: 0 auto;
    max-width: 15em;
    @include display-flex(column, stretch);
    img{
      @include radius-top;
    }
    button{
      @include radius-bottom;
      @include radius-top(0);
    }
  }

  /* Large screens */
  @media screen and (min-width: $small-screen){
    .changePicture{
      img{
        max-width: 20vw;
      }
    }
  }
</style>
