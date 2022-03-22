<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import getLangsData from '#entities/lib/editor/get_langs_data'
  import DisplayModeButtons from './display_mode_buttons.svelte'
  import Flash from '#lib/components/flash.svelte'
  import EditModeButtons from './edit_mode_buttons.svelte'
  import getActionKey from '#lib/get_action_key'
  import preq from '#lib/preq'
  import getBestLangValue from '#entities/lib/get_best_lang_value'

  export let entity, favoriteLabel, favoriteLabelLang
  let editMode = false
  let input, flash

  const { uri, type, labels } = entity
  const hasName = type === 'human' || type === 'publisher'
  const userLang = app.user.lang
  const languages = getLangsData(userLang, labels)
  const bestLangData = getBestLangValue(userLang, null, labels)
  let currentLang = bestLangData.lang

  let currentValue
  $: {
    currentValue = labels[currentLang] || userLang
    if (favoriteLabelLang === currentLang) {
      favoriteLabel = currentValue
    }
  }

  function showEditMode () {
    editMode = true
    input.focus()
  }

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
        >
        <EditModeButtons showDelete={false} on:cancel={closeEditMode} on:save={save}/>
      {:else}
        <button class="value-display" on:click={showEditMode} title="{I18n('edit')}">
          {currentValue || ''}
        </button>
        <DisplayModeButtons on:edit={showEditMode} />
      {/if}
    </div>
  </div>

  <Flash bind:state={flash}/>
</div>


<style lang="scss">
  @import '#entities/scss/entity_editors_commons';
  .editor-section{
    flex-direction: column;
  }
  select{
    border-color: #ddd;
  }
  .value{
    flex: 1;
    input, button{
      flex: 1;
      font-weight: normal;
    }
    button{
      cursor: pointer;
      text-align: left;
      @include bg-hover(white, 5%);
      user-select: text;
    }
  }
  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    select{
      margin-bottom: 0.5em;
    }
    .language-values{
      @include display-flex(column, stretch, center);
    }
    .value{
      @include display-flex(column, center, center);
      input, button{
        width: 100%;
        margin: 0.5em 0;
        padding: 0.5em;
      }
      button{
        @include bg-hover($light-grey, 5%);
      }
    }
  }
  /*Large screens*/
  @media screen and (min-width: $smaller-screen) {
    select{
      width: 10em;
      height: 100%;
    }
    .language-values{
      @include display-flex(row, stretch, center);
      min-height: 2.5em;
    }
    .value{
      @include display-flex(row, stretch);
      input, button{
        height: 100%;
        margin: 0 0.5em;
      }
      button{
        @include bg-hover(white, 5%);
      }
    }
  }
</style>
