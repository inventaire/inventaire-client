<script lang="ts">
  import { autosize } from '#app/lib/components/actions/autosize'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import { wait } from '#app/lib/promises'
  import { commands } from '#app/radio'
  import Spinner from '#components/spinner.svelte'
  import GroupOpenness from '#groups/components/group_openness.svelte'
  import GroupSearchability from '#groups/components/group_searchability.svelte'
  import GroupUrl from '#groups/components/group_url.svelte'
  import { i18n, I18n } from '#user/lib/i18n'
  import { createGroup as _createGroup } from '../lib/groups_data'

  commands.execute('modal:open', 'medium')

  let name, nameFlash, description, descriptionFlash, searchable = true, open = false, position, creationFlash

  let creating, created
  async function createGroup () {
    try {
      creating = true
      const group = await _createGroup({
        name,
        description,
        searchable,
        open,
        position,
      })
      creating = false
      created = true
      creationFlash = { type: 'success', message: I18n('done') }
      await wait(500)
      commands.execute('show:group:board', group)
      commands.execute('modal:close')
    } catch (err) {
      creationFlash = err
      creating = false
    }
  }
</script>

<form class="create-group">
  <h2>{I18n('create a new group')}</h2>

  <label for="nameField">{I18n('group name')}</label>
  <input
    id="nameField"
    type="text"
    bind:value={name}
    placeholder={i18n('ex: the secret club of Proustian experts')}
    maxlength="80"
  />
  <GroupUrl {name} bind:flash={nameFlash} />
  <Flash state={nameFlash} />

  <label for="editDescription">{I18n('description')}</label>
  <textarea
    id="editDescription"
    placeholder={I18n('help other users to understand what this group is about')}
    bind:value={description}
    maxlength="5000"
    use:autosize
  ></textarea>
  <Flash state={descriptionFlash} />

  <hr />

  <GroupSearchability bind:searchable />

  <hr />

  <GroupOpenness bind:open />

  <!-- TODO: add picture selector -->
  <!-- TODO: add position selector -->

  <button
    id="createGroup"
    class="button light-blue"
    on:click={createGroup}
    disabled={creating || created}
  >
    {#if creating}
      <Spinner />
    {:else}
      {@html icon('plus')}
    {/if}
    {I18n('create group')}
  </button>

  <Flash state={creationFlash} />
</form>

<style lang="scss">
  @import '#general/scss/utils';

  .create-group{
    @include display-flex(column, stretch, center);
  }
  h2{
    text-align: center;
    font-size: 1.4em;
  }
  label{
    color: black;
    text-align: start;
    font-size: 1em;
  }
  #createGroup{
    margin: 1em auto;
  }
</style>
