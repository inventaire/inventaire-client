<script>
  import { i18n, I18n } from 'modules/user/lib/i18n'
  import getLangsData from 'modules/entities/lib/editor/get_langs_data'
  import DisplayModeButtons from './display_mode_buttons.svelte'
  import Flash from 'lib/components/flash.svelte'
  import EditModeButtons from './edit_mode_buttons.svelte'
  import { autofocus } from 'lib/components/actions/autofocus'
  import getActionKey from 'lib/get_action_key'
  import preq from 'lib/preq'
  import getBestLangValue from 'modules/entities/lib/get_best_lang_value'

  export let entity
  let editMode = false
  let input, flash

  const { uri, type, labels } = entity
  const hasName = type === 'human' || type === 'publisher'
  const userLang = app.user.lang
  const languages = getLangsData(userLang, labels)
  const bestLangData = getBestLangValue(userLang, null, labels)
  let currentLang = bestLangData.lang
  $: currentValue = labels[currentLang] || userLang

  function showEditMode () { editMode = true }
  function closeEditMode () { editMode = false }
  async function save () {
    const { value } = input
    labels[currentLang] = value
    editMode = false
    preq.put(app.API.entities.labels.update, { uri, lang: currentLang, value })
    .catch(err => {
      editMode = true
      flash = err
    })
  }
  function onInputKeyup (e) {
    const key = getActionKey(e)
    if (key === 'esc') closeEditMode()
    else if (e.ctrlKey && key === 'enter') save()
  }
</script>

<div class="editor-section">
  <h3 class="editor-section-header">
    {#if hasName}
      {I18n('name')}gd
    {:else}
      {I18n('title')}
    {/if}
  </h3>

  <div class="language-values">
    <select name="{i18n('language selector')}" bind:value={currentLang}>
      {#each languages as { code, native }}
        <option value="{code}">{code} - {native}</option>
      {/each}
    </select>
    <div class="value">
      {#if editMode}
        <input type="text"
          value={currentValue || ''}
          on:keyup={onInputKeyup}
          bind:this={input}
          use:autofocus
        >
        <EditModeButtons showDelete={false} on:cancel={closeEditMode} on:save={save}/>
      {:else}
        <button class="value-display" on:click={showEditMode} title="{i18n('edit')}">
          {currentValue || ''}
        </button>
        <DisplayModeButtons on:edit={showEditMode} />
      {/if}
    </div>
  </div>

  <Flash bind:state={flash}/>
</div>


<style lang="scss">
  @import 'app/modules/entities/scss/entity_editors_commons';
  .language-values{
    @include display-flex(row, stretch, center);
    height: 2.5em;
  }
  select{
    border-color: #ddd;
    width: 10em;
    height: 100%;
  }
  .value{
    flex: 1;
    @include display-flex(row, stretch);
    input, button{
      flex: 1;
      height: 100%;
      font-weight: normal;
      margin: 0 0.5em;
    }
    button{
      cursor: pointer;
      text-align: left;
      @include bg-hover(white, 5%);
      user-select: text;
    }
  }
</style>
