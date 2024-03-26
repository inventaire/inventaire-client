<script>
  import { tick } from 'svelte'
  import app from '#app/app'
  import { alphabeticallySortedEntries, getNativeLangName } from '#entities/components/editor/lib/editors_helpers'
  import { findMatchingSerieLabel, getWorkSeriesLabels } from '#entities/components/editor/lib/title_tip'
  import getLangsData from '#entities/lib/editor/get_langs_data'
  import getBestLangValue from '#entities/lib/get_best_lang_value'
  import { typeHasName } from '#entities/lib/types/entities_types'
  import Flash from '#lib/components/flash.svelte'
  import { getActionKey } from '#lib/key_events'
  import preq from '#lib/preq'
  import { i18n, I18n } from '#user/lib/i18n'
  import DisplayModeButtons from './display_mode_buttons.svelte'
  import EditModeButtons from './edit_mode_buttons.svelte'

  export let entity, favoriteLabel, favoriteLabelLang, inputLabel
  let editMode = false
  let input, flash

  const { uri, labels } = entity
  const creationMode = uri == null
  const userLang = app.user.lang
  const languages = getLangsData(userLang, labels)
  const bestLangData = getBestLangValue(userLang, null, labels)
  let currentLang = bestLangData.lang || userLang

  let currentValue
  $: {
    currentValue = labels[currentLang]
    if (currentValue == null) {
      editMode = true
      if (inputLabel) currentValue = inputLabel
    }
    if (favoriteLabelLang === currentLang) {
      favoriteLabel = currentValue
    }
  }

  $: hasName = typeHasName(entity.type)

  async function showEditMode () {
    editMode = true
    await tick()
    input?.focus()
  }

  function closeEditMode () { editMode = false }

  async function save () {
    const { value } = input
    labels[currentLang] = value
    triggerEntityRefresh()
    editMode = false
    if (creationMode) return
    app.execute('invalidate:entities:cache', uri)
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
    if (serieLabels) {
      const { value } = input
      matchingSerieLabel = findMatchingSerieLabel(value, serieLabels)
    }
  }

  const triggerEntityRefresh = () => entity = entity

  function editLanguageValue (lang) {
    currentLang = lang
    showEditMode()
  }

  let serieUri, serieLabels, matchingSerieLabel
  if (entity.type === 'work' || entity.type === 'serie') {
    getWorkSeriesLabels(entity)
      .then(res => {
        if (!res) return
        serieUri = res.uri
        serieLabels = res.labels
      })
      .catch(err => flash = err)
  }
</script>

<div class="editor-section">
  <h3 class="editor-section-header">
    {#if hasName}
      {I18n('name')}
    {:else}
      {I18n('title')}
    {/if}
  </h3>

  <div class="language-values">
    <select name={i18n('language selector')} bind:value={currentLang}>
      {#each languages as { code, native }}
        <option value={code}>
          {code}
          {#if native !== code} - {native}{/if}
        </option>
      {/each}
    </select>
    <div class="value">
      {#if editMode}
        <div class="input-wrapper">
          <input
            type="text"
            value={currentValue || ''}
            on:keyup={onInputKeyup}
            bind:this={input}
          />
          {#if matchingSerieLabel}
            <p class="tip">
              {@html I18n('title_matches_serie_label_tip', {
                pathname: `/entity/${serieUri}/edit`,
              })}
            </p>
          {/if}
        </div>
        <EditModeButtons showDelete={false} on:cancel={closeEditMode} on:save={save} />
      {:else}
        <button class="value-display" on:click={showEditMode} title={I18n('edit')}>
          {currentValue || ''}
        </button>
        <DisplayModeButtons on:edit={showEditMode} />
      {/if}
    </div>
  </div>

  <ul class="other-languages">
    {#each alphabeticallySortedEntries(labels) as [ lang, value ]}
      {@const native = getNativeLangName(lang)}
      {#if lang !== currentLang}
        <li>
          <button on:click={() => editLanguageValue(lang)}
          >
            <span class="lang">{lang} {#if native}- {native}{/if}</span>
            <span class="other-value">{value}</span>
          </button>
        </li>
      {/if}
    {/each}
  </ul>

  <Flash bind:state={flash} />
</div>

<style lang="scss">
  @import "#entities/scss/entity_editors_commons";
  @import "#entities/scss/title_tip";
  .editor-section{
    flex-direction: column;
  }
  select{
    border-color: #ddd;
  }
  .value{
    flex: 1;
    .input-wrapper, button{
      flex: 1;
      font-weight: normal;
    }
    button{
      cursor: pointer;
      text-align: start;
      @include bg-hover(white, 5%);
      user-select: text;
    }
  }
  .input-wrapper{
    position: relative;
  }
  .other-languages{
    max-block-size: 10em;
    overflow: auto;
    margin-block-start: 1em;
    button{
      inline-size: 100%;
      margin: 0.5em 0;
      padding: 0.5em 0;
      @include display-flex(row, center, flex-start);
      @include bg-hover(white, 5%);
      text-align: start;
    }
  }
  .other-value{
    user-select: text;
  }

  /* Small screens */
  @media screen and (max-width: $smaller-screen){
    select{
      margin-block-end: 0.5em;
    }
    .language-values{
      @include display-flex(column, stretch, center);
    }
    .value{
      @include display-flex(column, center, center);
      .input-wrapper, button{
        inline-size: 100%;
        margin: 0.5em 0;
        padding: 0.5em;
      }
      input{
        margin: 0;
      }
      button{
        @include bg-hover($light-grey, 5%);
      }
    }
    .other-languages{
      display: none;
    }
  }
  /* Large screens */
  @media screen and (min-width: $smaller-screen){
    select, .other-languages .lang{
      inline-size: 10em;
      block-size: 100%;
    }
    .lang{
      padding: 0 1rem;
      font-size: 0.9rem;
    }
    .other-value{
      margin: 0 1.1em;
    }
    .language-values{
      @include display-flex(row, stretch, center);
      min-block-size: 2.5em;
    }
    .value{
      @include display-flex(row, stretch);
      .input-wrapper, button{
        block-size: 100%;
        margin: 0 0.5em;
      }
      button{
        @include bg-hover(white, 5%);
      }
    }
  }
</style>
