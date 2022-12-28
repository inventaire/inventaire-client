<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import EntityMergeSection from '#entities/components/entity_merge_section.svelte'
  import { icon } from '#lib/handlebars_helpers/icons'
  import mergeEntities from '#entities/views/editor/lib/merge_entities'
  import Flash from '#lib/components/flash.svelte'
  import { entityTypeNameByType, pluralize } from '#entities/lib/types/entities_types'
  import { isWikidataItemUri } from '#lib/boolean_tests'
  import { slide } from 'svelte/transition'

  export let from, to, type

  let flash, typeName

  async function merge () {
    try {
      await mergeEntities(from, to)
      from = null
      to = null
      flash = {
        type: 'success',
        message: I18n('success')
      }
    } catch (err) {
      flash = err
    }
  }

  $: if (type) typeName = entityTypeNameByType[pluralize(type)]
  $: {
    if (!(from || to)) type = null
    else if (isWikidataItemUri(from) && to && !isWikidataItemUri(to)) {
      [ from, to ] = [ to, from ]
    }
  }
</script>

<div class="entityMergeLayout">
  <h2>{i18n('Merge entities')}</h2>

  <p class="help">
    {i18n('Entities can be merged when one is a duplicate of the other.')}
  </p>

  {#if type}
    <section class="type" transition:slide={{ duration: 200 }}>
      <span class="label">{I18n('entity type')}:</span>
      <span class="type-name">{I18n(typeName)}</span>
    </section>
  {/if}

  <section>
    <!-- Not using a <label> to avoid getting a false positive a11y-label-has-associated-control warning from Svelte
         See https://github.com/sveltejs/svelte/issues/6469 -->
    <h3>{i18n('The entity that should be merged')}</h3>
    <EntityMergeSection
      bind:uri={from}
      bind:type
    />
  </section>

  <section>
    <h3>{i18n('The entity in which it should be merged')}</h3>
    <EntityMergeSection
      bind:uri={to}
      bind:type
    />
  </section>

  <Flash bind:state={flash}/>

  <button
    disabled={!(from && to)}
    class="success-button"
    on:click={merge}
    >
    {@html icon('compress')}
    {I18n('merge')}
  </button>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .entityMergeLayout{
    max-width: 50em;
    margin: 1em auto;
  }
  .help{
    margin-bottom: 1em;
  }
  .type{
    margin: 1em 0;
  }
  .type-name{
    display: block;
  }
  h2{
    text-align: center;
    margin-top: 0;
  }
  h3{
    font-size: 1rem;
    @include sans-serif;
  }
  h3, .label{
    font-size: 1rem;
    color: $grey;
  }
  section{
    margin-bottom: 1em;
    background-color: white;
    padding: 1em;
    @include radius;
  }
  .success-button{
    display: block;
    margin: 1em auto;
  }
</style>
