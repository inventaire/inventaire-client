<script>
  import { I18n } from '#user/lib/i18n'
  import { createEventDispatcher } from 'svelte'
  import { getLang, hasSelectedLang } from '#entities/components/lib/claims_helpers'
  import EditionsListActions from './editions_list_actions.svelte'
  import EntitiesList from './entities_list.svelte'
  import EditionCreation from './edition_creation.svelte'

  const dispatch = createEventDispatcher()

  export let someInitialEditions,
    someEditions,
    editions,
    publishersByUris,
    parentEntity,
    initialEditions,
    usersSize

  let userLang = app.user.lang
  let selectedLangs = [ userLang ]
  let editionsLangs

  const filterEditionByLang = _ => {
    if (selectedLangs.length === editionsLangs.length) {
      return editions = initialEditions
    }
    editions = initialEditions.filter(hasSelectedLang(selectedLangs))
  }

  const prioritizeMainUserLang = langs => {
    if (langs.includes(userLang)) {
      const userLangIndex = langs.indexOf(userLang)
      langs.splice(userLangIndex, 1)
      langs.unshift(userLang)
    }
    return langs
  }

  $: {
    if (initialEditions) {
      let rawEditionsLangs = _.compact(_.uniq(initialEditions.map(getLang)))
      editionsLangs = prioritizeMainUserLang(rawEditionsLangs)
    }
  }
  $: selectedLangs && filterEditionByLang(initialEditions)
</script>
<div class="editions-section">
  <div class="editions-list-title">
    <h5>
      {I18n('editions')}
    </h5>
  </div>
  <EditionsListActions
    bind:selectedLangs={selectedLangs}
    bind:editionsLangs={editionsLangs}
    {someInitialEditions}
    {someEditions}
    {usersSize}
    on:scrollToItemsList={() => dispatch('scrollToItemsList')}
    on:showMap={() => { dispatch('showMap') }}
  />
  {#if someEditions}
    <EntitiesList
      entities={editions}
      relatedEntities={publishersByUris}
      {parentEntity}
      type='editions'
    />
  {:else}
    <div class="no-edition-wrapper">
      {I18n('no editions found')}
    </div>
  {/if}
  <EditionCreation
    work={parentEntity}
    bind:editions={initialEditions}
  />
</div>
<style lang="scss">
  @import '#general/scss/utils';

  .editions-section{
    @include display-flex(column, center);
    @include radius;
    padding: 0.5em;
    width: 100%;
    background-color: $off-white;
  }
  .editions-list-title{
    @include display-flex(row, center, center);
  }
  .no-edition-wrapper{
    @include display-flex(row, center, center);
    color: $grey;
    margin-top: 1em;
  }
</style>
