<script lang="ts">
  import { tick } from 'svelte'
  import { isString } from 'underscore'
  import { API } from '#app/api/api'
  import app from '#app/app'
  import { isNonEmptyString } from '#app/lib/boolean_tests'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import { getActionKey } from '#app/lib/key_events'
  import preq from '#app/lib/preq'
  import { onChange } from '#app/lib/svelte/svelte'
  import { alphabeticallySortedEntries } from '#entities/components/editor/lib/editors_helpers'
  import { findMatchingSerieLabel, getWorkSeriesLabels } from '#entities/components/editor/lib/title_tip'
  import getLangsData from '#entities/lib/editor/get_langs_data'
  import { getBestLangValue } from '#entities/lib/get_best_lang_value'
  import { typeHasName } from '#entities/lib/types/entities_types'
  import type { EntityUri, Label } from '#server/types/entity'
  import { i18n, I18n } from '#user/lib/i18n'
  import DisplayModeButtons from './display_mode_buttons.svelte'
  import EditModeButtons from './edit_mode_buttons.svelte'
  import OtherLanguage from './other_language.svelte'
  import type { WikimediaLanguageCode } from 'wikibase-sdk'

  export let entity
  export let favoriteLabel: string = null
  export let favoriteLabelLang: WikimediaLanguageCode = null
  export let inputLabel: string = null

  let editMode = false
  let input, flash, previousValue, previousLang

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
    if (favoriteLabelLang === currentLang && isString(currentValue)) {
      favoriteLabel = currentValue
    }
  }

  $: hasName = typeHasName(entity.type)
  $: deleteButtonDisable = Object.values(entity.labels).filter(isNonEmptyString).length < 2
  $: onChange(currentLang, resetState)

  function resetState () {
    previousValue = null
    if (previousLang && typeof entity.labels[previousLang] === 'symbol') {
      delete entity.labels[previousLang]
    }
    previousLang = currentLang
  }

  async function showEditMode () {
    editMode = true
    await tick()
    input?.focus()
  }

  function closeEditMode () { editMode = false }

  async function saveFromInput () {
    flash = null
    const value = input.value.trim()
    if (value === '') return removeLabel()
    save(value)
  }

  async function save (value: string) {
    labels[currentLang] = value
    triggerEntityRefresh()
    editMode = false
    if (creationMode) return
    return updateOrRemoveLabel(uri, currentLang, value)
  }

  async function removeLabel () {
    flash = null
    previousValue = labels[currentLang]
    labels[currentLang] = Symbol.for('removed')
    triggerEntityRefresh()
    editMode = false
    if (creationMode) return
    return updateOrRemoveLabel(uri, currentLang)
  }

  async function undo () {
    labels[currentLang] = previousValue
    return save(previousValue)
  }

  function updateOrRemoveLabel (uri: EntityUri, lang: WikimediaLanguageCode, value?: Label) {
    let promise
    if (value) {
      promise = preq.put(API.entities.labels.update, { uri, lang, value })
    } else {
      promise = preq.put(API.entities.labels.remove, { uri, lang })
    }
    return promise
      .catch(err => {
        labels[lang] = previousValue
        editMode = true
        flash = err
      })
  }

  function onInputKeyup (e) {
    const key = getActionKey(e)
    if (key === 'esc') {
      closeEditMode()
    } else if (e.ctrlKey && key === 'enter') {
      saveFromInput()
    } if (serieLabels) {
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
            value={isString(currentValue) ? currentValue : ''}
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
        <EditModeButtons
          on:cancel={closeEditMode}
          on:save={saveFromInput}
          on:delete={removeLabel}
          showDelete={labels[currentLang] != null}
          deleteButtonDisableMessage={deleteButtonDisable ? i18n('There should be at least one label') : null}
        />
      {:else}
        {#if currentValue === Symbol.for('removed')}
          <button
            class="undo"
            title={`${i18n('Recover previous value:')} ${previousValue}`}
            on:click={undo}
          >
            {@html icon('undo')}
            {I18n('undo')}
          </button>
        {:else}
          <button class="value-display" on:click={showEditMode} title={I18n('edit')}>
            {currentValue || ''}
          </button>
        {/if}
        <DisplayModeButtons on:edit={showEditMode} />
      {/if}
    </div>
  </div>

  <ul class="other-languages">
    {#each alphabeticallySortedEntries(labels) as [ lang, value ] (lang)}
      <OtherLanguage
        {lang}
        {value}
        {currentLang}
        on:editLanguageValue={e => editLanguageValue(e.detail)}
      />
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
    .input-wrapper, .value-display{
      flex: 1;
      font-weight: normal;
    }
    .value-display{
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
  }
  .undo{
    flex: 1;
    padding: 0.6em 0;
    margin: 0 0.5em;
    @include shy(0.9);
    @include bg-hover(#ddd);
  }

  /* Small screens */
  @media screen and (width < $smaller-screen){
    select{
      margin-block-end: 0.5em;
    }
    .language-values{
      @include display-flex(column, stretch, center);
    }
    .value{
      @include display-flex(column, center, center);
      .input-wrapper, .value-display{
        inline-size: 100%;
        margin: 0.5em 0;
        padding: 0.5em;
      }
      input{
        margin: 0;
      }
      .value-display{
        @include bg-hover($light-grey, 5%);
      }
    }
    .other-languages{
      display: none;
    }
  }
  /* Large screens */
  @media screen and (width >= $smaller-screen){
    select{
      inline-size: 10em;
      block-size: 100%;
    }
    .language-values{
      @include display-flex(row, stretch, center);
      min-block-size: 2.5em;
    }
    .value{
      @include display-flex(row, stretch);
      .input-wrapper, .value-display{
        block-size: 100%;
        margin: 0 1em;
      }
      .value-display{
        @include bg-hover(white, 5%);
      }
    }
  }
</style>
