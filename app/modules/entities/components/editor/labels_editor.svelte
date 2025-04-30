<script lang="ts">
  import { tick } from 'svelte'
  import { isNonEmptyString } from '#app/lib/boolean_tests'
  import Flash from '#app/lib/components/flash.svelte'
  import { wait } from '#app/lib/promises'
  import { alphabeticallySortedEntries, getEditableLabels } from '#entities/components/editor/lib/editors_helpers'
  import { getWorkSeriesLabels } from '#entities/components/editor/lib/title_tip'
  import type { SerializedEntity } from '#entities/lib/entities'
  import { typeHasName } from '#entities/lib/types/entities_types'
  import type { EntitySearchResult } from '#server/controllers/search/lib/normalize_result'
  import { getCurrentLang, i18n, I18n } from '#user/lib/i18n'
  import EntityAutocompleteSelector from '../entity_autocomplete_selector.svelte'
  import LanguageLabel from '../language_label.svelte'
  import LabelDisplay from './label_display.svelte'
  import LabelEditor from './label_editor.svelte'
  import type { WikimediaLanguageCode } from 'wikibase-sdk'

  export let entity: SerializedEntity
  export let inputLabel: string = null

  let flash, labels

  const { uri } = entity
  $: labels = getEditableLabels(entity.labels)

  $: hasName = typeHasName(entity.type)
  $: deleteButtonDisable = Object.values(entity.labels).filter(isNonEmptyString).length < 2

  let arbitraryLanguageValue = ''
  let arbitraryLanguageCode, editedLanguageCode, languagesLabelsListEl, arbitraryLangSelectorText

  const entityCreationMode = uri == null
  if (entityCreationMode) {
    arbitraryLanguageCode = getCurrentLang()
    if (inputLabel) arbitraryLanguageValue = inputLabel
  }

  function editLanguageValue (lang: string) {
    editedLanguageCode = lang
  }

  let serieUri, serieLabels
  if (entity.type === 'work' || entity.type === 'serie') {
    getWorkSeriesLabels(entity)
      .then(res => {
        if (!res) return
        serieUri = res.uri
        serieLabels = res.labels
      })
      .catch(err => flash = err)
  }

  async function selectArbitraryLanguage (entity: EntitySearchResult) {
    editedLanguageCode = null
    arbitraryLanguageCode = entity.claims['wdt:P424'][0]
    if (isNonEmptyString(labels[arbitraryLanguageCode])) {
      editedLanguageCode = arbitraryLanguageCode
      arbitraryLangSelectorText = ''
      arbitraryLanguageCode = null
    }
  }

  let lastAddedLang

  async function done (lang: WikimediaLanguageCode, updatedValue?: string | symbol) {
    if (updatedValue) {
      // @ts-expect-error allow to set a symbol value
      entity.labels[lang] = updatedValue
    }
    if (lang === arbitraryLanguageCode) {
      arbitraryLangSelectorText = ''
      arbitraryLanguageValue = ''
      arbitraryLanguageCode = null
      await highlightNewLabel(lang)
    }
    if (updatedValue !== Symbol.for('removed')) {
      editedLanguageCode = null
    }
  }

  async function highlightNewLabel (lang: WikimediaLanguageCode) {
    await tick()
    const displayEl = languagesLabelsListEl.querySelector(`[data-lang=${lang}`)
    if (!displayEl) return
    displayEl.scrollIntoView({ block: 'end', inline: 'nearest', behavior: 'smooth' })
    // There is no easy way to know when scrollIntoView is done, cf https://github.com/w3c/csswg-drafts/issues/3744
    await wait(200)
    lastAddedLang = lang
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

  <ul class="languages-labels" bind:this={languagesLabelsListEl}>
    {#each alphabeticallySortedEntries(labels) as [ lang, value ] (lang)}
      {#if lang === editedLanguageCode}
        <li class="edited-label">
          <LanguageLabel {lang} />
          <LabelEditor
            {uri}
            {lang}
            value={labels[editedLanguageCode]}
            {serieLabels}
            {serieUri}
            showDelete={labels[editedLanguageCode] != null}
            {deleteButtonDisable}
            on:done={e => done(lang, e.detail)}
          />
        </li>
      {:else}
        <LabelDisplay
          {lang}
          {value}
          {lastAddedLang}
          on:editLanguageValue={e => editLanguageValue(e.detail)}
        />
      {/if}
    {/each}
  </ul>

  <hr />

  <div class="arbitrary-lang">
    {#if arbitraryLanguageCode}
      {#if labels[arbitraryLanguageCode] == null || labels[arbitraryLanguageCode] === Symbol.for('removed')}
        <div>
          <LanguageLabel lang={arbitraryLanguageCode} />
        </div>
        <LabelEditor
          {uri}
          lang={arbitraryLanguageCode}
          bind:value={arbitraryLanguageValue}
          {serieLabels}
          {serieUri}
          showDelete={false}
          on:done={e => done(arbitraryLanguageCode, e.detail)}
        />
      {/if}
    {:else}
      <div class="arbitrary-lang-selector">
        <EntityAutocompleteSelector
          searchTypes={[ 'languages' ]}
          claimFilter="wdt:P424"
          placeholder={i18n('Select label language')}
          autofocus={false}
          bind:currentEntityLabel={arbitraryLangSelectorText}
          on:select={e => selectArbitraryLanguage(e.detail)}
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
  .languages-labels{
    max-block-size: 14em;
    overflow: auto;
    margin-block: 0.2rem;
    li{
      margin: 0.5rem 0;
    }
  }
  .arbitrary-lang{
    :global(.label-editor-input){
      flex: 1;
    }
  }
  .arbitrary-lang-selector{
    :global(.image), :global(.description), :global(.uri){
      display: none;
    }
    :global(.suggestions .right){
      padding: 0.4rem 0.2rem;
    }
  }
  hr{
    margin: 0 0 1rem;
  }

  /* Smaller screens */
  @media screen and (width < $smaller-screen){
    .arbitrary-lang{
      @include display-flex(column, stretch);
    }
    .languages-labels{
      display: none;
    }
  }
  /* Large screens */
  @media screen and (width >= $smaller-screen){
    .arbitrary-lang{
      @include display-flex(row, center);
    }
    .arbitrary-lang-selector{
      inline-size: 10rem;
      block-size: 100%;
    }
    .edited-label{
      @include display-flex(row, center);
      :global(.label-editor-input){
        flex: 1;
      }
    }
  }
</style>
