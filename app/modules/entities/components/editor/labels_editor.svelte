<script lang="ts">
  import { tick } from 'svelte'
  import { isString } from 'underscore'
  import { assertString } from '#app/lib/assert_types'
  import { isNonEmptyString } from '#app/lib/boolean_tests'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import { getActionKey } from '#app/lib/key_events'
  import { getLangsData } from '#app/lib/languages'
  import { onChange } from '#app/lib/svelte/svelte'
  import { alphabeticallySortedEntries } from '#entities/components/editor/lib/editors_helpers'
  import { findMatchingSerieLabel, getWorkSeriesLabels } from '#entities/components/editor/lib/title_tip'
  import { updateLabel, removeLabel } from '#entities/lib/entities'
  import { getBestLangValue } from '#entities/lib/get_best_lang_value'
  import { typeHasName } from '#entities/lib/types/entities_types'
  import type { EntitySearchResult } from '#server/controllers/search/lib/normalize_result'
  import type { EntityUri, Label } from '#server/types/entity'
  import { getCurrentLang, i18n, I18n } from '#user/lib/i18n'
  import EntityAutocompleteSelector from '../entity_autocomplete_selector.svelte'
  import DisplayModeButtons from './display_mode_buttons.svelte'
  import LabelEditor from './label_editor.svelte'
  import OtherLanguage from './other_language.svelte'
  import type { WikimediaLanguageCode } from 'wikibase-sdk'

  export let entity
  export let favoriteLabel: string = null
  export let favoriteLabelLang: WikimediaLanguageCode = null
  export let inputLabel: string = null

  let editMode = false
  let labelEditorInput, flash, previousValue, previousLang

  const { uri, labels } = entity
  const creationMode = uri == null
  const userLang = getCurrentLang()
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
    labelEditorInput?.focus()
  }

  function closeEditMode () { editMode = false }

  async function saveFromInput () {
    flash = null
    const value = labelEditorInput.value.trim()
    if (value === '') return deleteLabel()
    save(value)
  }

  async function save (value: string) {
    labels[currentLang] = value
    triggerEntityRefresh()
    editMode = false
    if (creationMode) return
    return updateOrRemoveLabel(uri, currentLang, value)
  }

  async function deleteLabel () {
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
      promise = updateLabel(uri, lang, value)
    } else {
      promise = removeLabel(uri, lang)
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
      const { value } = labelEditorInput
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

  let arbitraryLanguageCode, arbitraryLanguageUri, arbitraryLanguageLabel

  async function selectLanguage (entity: EntitySearchResult) {
    arbitraryLanguageUri = entity.uri
    arbitraryLanguageLabel = entity.label
    arbitraryLanguageCode = entity.claims['wdt:P424'][0]
    assertString(arbitraryLanguageCode)
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
        <LabelEditor
          currentValue={labels[arbitraryLanguageCode]}
          {matchingSerieLabel}
          {serieUri}
          showDelete={labels[arbitraryLanguageCode] != null}
          {deleteButtonDisable}
          bind:input={labelEditorInput}
          {onInputKeyup}
          {closeEditMode}
          {saveFromInput}
          {deleteLabel}
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

  <div class="arbitrary-lang">
    {#if arbitraryLanguageCode}
      <div class="lang-info">
        <span class="lang-label">{arbitraryLanguageLabel}</span>
        <span class="lang-code">{arbitraryLanguageCode}</span>
      </div>
      <LabelEditor
        currentValue={labels[arbitraryLanguageCode]}
        {matchingSerieLabel}
        {serieUri}
        showDelete={labels[arbitraryLanguageCode] != null}
        {deleteButtonDisable}
        bind:input={labelEditorInput}
        {onInputKeyup}
        {closeEditMode}
        {saveFromInput}
        {deleteLabel}
      />
    {:else}
      <div class="arbitrary-lang-selector">
        <EntityAutocompleteSelector
          searchTypes={[ 'languages' ]}
          claimFilter="wdt:P424"
          placeholder={i18n('Select label language')}
          bind:currentEntityLabel={arbitraryLanguageLabel}
          bind:currentEntityUri={arbitraryLanguageUri}
          on:select={e => selectLanguage(e.detail)}
        />
      </div>
    {/if}
  </div>

  <Flash bind:state={flash} />
</div>

<style lang="scss">
  @import "#entities/scss/entity_editors_commons";

  .editor-section{
    flex-direction: column;
  }
  select{
    border-color: #ddd;
  }
  .value{
    flex: 1;
    :global(.label-editor-input), .value-display{
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

  .arbitrary-lang{
    @include display-flex(row);
  }
  .arbitrary-lang-selector{
    :global(.image), :global(.description), :global(.uri){
      display: none;
    }
    :global(.suggestions .right){
      padding: 0.4rem 0.2rem;
    }
    :global(.suggestions .top){
      flex-direction: column;
      line-height: 1.2rem;
    }
    :global(.claim){
      align-self: stretch;
      text-align: start;
      color: $grey;
    }
  }
  .lang-info{
    @include display-flex(column);
  }

  /* Smaller screens */
  @media screen and (width < $smaller-screen){
    select, .lang-info{
      margin-block-end: 0.5em;
    }
    .language-values{
      @include display-flex(column, stretch, center);
    }
    .value{
      @include display-flex(column, center, center);
      :global(.label-editor-input), .value-display{
        inline-size: 100%;
        margin: 0.5em 0;
        padding: 0.5em;
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
    select, .arbitrary-lang-selector, .lang-info{
      inline-size: 10em;
      block-size: 100%;
    }
    .lang-info{
      padding-inline-start: 0.7rem;
      font-size: 0.9rem;
    }
    .language-values{
      @include display-flex(row, stretch, center);
      min-block-size: 2.5em;
    }
    .value{
      @include display-flex(row, stretch);
      :global(.label-editor-input), .value-display{
        block-size: 100%;
        margin: 0 1em;
      }
      .value-display{
        @include bg-hover(white, 5%);
      }
    }
  }
</style>
