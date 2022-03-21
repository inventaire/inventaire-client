<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import EntityMergeSection from '#entities/components/entity_merge_section.svelte'
  import { icon } from '#lib/handlebars_helpers/icons'
  import mergeEntities from '#entities/views/editor/lib/merge_entities'
  import Flash from '#lib/components/flash.svelte'
  import { entityTypeNameByType } from '#entities/lib/properties'
  import { pluralize } from '#entities/lib/types/type_key'
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
  $: if (!(from || to)) type = null
</script>

<div class="entityMergeLayout">
  <h2>{i18n('Merge entities')}</h2>

  {#if type}
    <section class="type" transition:slide={{ duration: 200 }}>
      <span class="label">{I18n('entity type')}:</span>
      <span class="type-name">{I18n(typeName)}</span>
    </section>
  {/if}

  <section>
    <!-- svelte-ignore a11y-label-has-associated-control -->
    <label>
      {i18n('The entity that should be merged')}
      <EntityMergeSection
        bind:uri={from}
        bind:type
      />
    </label>
  </section>

  <section>
    <!-- svelte-ignore a11y-label-has-associated-control -->
    <label>
      {i18n('The entity in which it should be merged')}
      <EntityMergeSection
        bind:uri={to}
        bind:type
      />
    </label>
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
  label, .label{
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
