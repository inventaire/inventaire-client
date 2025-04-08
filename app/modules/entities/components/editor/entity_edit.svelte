<script lang="ts">
  import { icon } from '#app/lib/icons'
  import { onChange } from '#app/lib/svelte/svelte'
  import { loadInternalLink } from '#app/lib/utils'
  import { getTypePropertiesPerCategory } from '#entities/components/editor/lib/editors_properties'
  import PropertyCategory from '#entities/components/editor/property_category.svelte'
  import type { SerializedEntity } from '#entities/lib/entities'
  import { getBestLangValue } from '#entities/lib/get_best_lang_value'
  import { typesPossessiveForms } from '#entities/lib/types/entities_types'
  import { getCurrentLang, i18n, I18n } from '#user/lib/i18n'
  import EntityEditMenu from './entity_edit_menu.svelte'
  import LabelsEditor from './labels_editor.svelte'

  export let entity: SerializedEntity

  const { uri, wdUri, invUri, type, labels } = entity
  const goToEntityPageLabel = `Go to the ${typesPossessiveForms[type]} page`
  const altInvUri = (invUri && invUri !== uri) ? invUri : null

  let typePropertiesPerCategory, hasMonolingualTitle, favoriteLabel

  function onEntityChange () {
    typePropertiesPerCategory = getTypePropertiesPerCategory(entity)
    hasMonolingualTitle = typePropertiesPerCategory.general['wdt:P1476'] != null
    if (hasMonolingualTitle) {
      favoriteLabel = entity.claims['wdt:P1476']?.[0]
    } else {
      favoriteLabel = getBestLangValue(getCurrentLang(), null, labels).value
    }
  }

  $: onChange(entity, onEntityChange)
</script>

<div class="entity-edit">
  <div class="header">
    <div class="header-main">
      <h2>
        <a href="/entity/{uri}" on:click={loadInternalLink}>
          {favoriteLabel}
        </a>
      </h2>
      <p class="type">{I18n(entity.type)}</p>
      <p class="uri">
        {uri}
        {#if wdUri && wdUri !== uri} - {wdUri}{/if}
        <!-- Use an intermediary `altInvUri` variable to workaround the TS2367 error otherwise produced
             with {#if invUri && invUri !== uri} -->
        {#if altInvUri} - {invUri}{/if}
      </p>
    </div>

    <EntityEditMenu {entity} />
  </div>

  {#if hasMonolingualTitle === false}
    <LabelsEditor bind:entity bind:favoriteLabel />
  {/if}

  {#if typePropertiesPerCategory}
    {#each Object.entries(typePropertiesPerCategory) as [ category, categoryProperties ]}
      <PropertyCategory bind:entity {category} {categoryProperties} />
    {/each}
  {/if}

  <div class="next">
    <a
      href="/entity/{uri}"
      on:click={loadInternalLink}
      class="light-blue-button"
    >
      {@html icon('arrow-right')}
      {i18n(goToEntityPageLabel)}
    </a>
  </div>
</div>

<style lang="scss">
  @use "#general/scss/utils";
  .entity-edit{
    @include display-flex(column, stretch, center);
    max-inline-size: 50em;
    margin: 0 auto;
  }
  .header{
    position: relative;
  }
  h2{
    margin-block-end: 0;
    a{
      @include link-dark;
    }
  }
  .type{
    color: $grey;
    font-size: 1rem;
  }
  .uri{
    @include sans-serif;
    font-size: 0.8rem;
  }
  .next{
    @include display-flex(row, center, center);
    margin: 1em auto;
  }

  /* Small screens */
  @media screen and (width < $small-screen){
    .header{
      @include display-flex(row, center, space-between, wrap);
    }
    .header-main{
      margin: 0 0.5em;
    }
  }
  /* Larger screens */
  @media screen and (width >= $small-screen){
    .header-main{
      @include display-flex(column, center, center);
    }
  }
</style>
