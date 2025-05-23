<script lang="ts">
  import { slide } from 'svelte/transition'
  import { isWikidataItemUri } from '#app/lib/boolean_tests'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import Spinner from '#components/spinner.svelte'
  import EntityMergeSection from '#entities/components/entity_merge_section.svelte'
  import { mergeEntities } from '#entities/lib/editor/merge_entities'
  import { entityTypeNameByType, pluralize } from '#entities/lib/types/entities_types'
  import type { EntityType, EntityUri } from '#server/types/entity'
  import { i18n, I18n } from '#user/lib/i18n'

  export let from: EntityUri = null
  export let to: EntityUri = null
  export let type: EntityType = null

  let flash, typeName, merging, taskId

  async function merge () {
    flash = null
    try {
      merging = true
      const res = await mergeEntities(from, to)
      from = null
      buildFlashMessage(res, to)
    } catch (err) {
      flash = err
    } finally {
      merging = false
    }
  }

  function buildFlashMessage (res, lastMergeTargetUri) {
    flash = {
      type: 'success',
    }
    taskId = res.taskId
    if (taskId) {
      flash.message = I18n('A merge request has been created')
    } else {
      flash.message = I18n('done')
      flash.link = {
        url: `/entity/${lastMergeTargetUri}`,
        text: i18n('View result'),
      }
    }
    return flash
  }

  $: if (type) typeName = entityTypeNameByType[pluralize(type)]
  $: {
    if (!(from || to)) type = null
    else if (isWikidataItemUri(from) && to && !isWikidataItemUri(to)) {
      [ from, to ] = [ to, from ]
    }
  }
</script>

<div class="entity-merge-layout">
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

  <Flash bind:state={flash} />

  <button
    disabled={(!(from && to)) || merging}
    class="success-button"
    on:click={merge}
  >
    {#if merging}
      <Spinner />
    {:else}
      {@html icon('compress')}
    {/if}
    {I18n('merge')}
  </button>
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .entity-merge-layout{
    max-inline-size: 50em;
    margin: 1em auto;
  }
  .help{
    margin-block-end: 1em;
  }
  .type{
    margin: 1em 0;
  }
  .type-name{
    display: block;
  }
  h2{
    text-align: center;
    margin-block-start: 0;
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
    margin-block-end: 1em;
    background-color: white;
    padding: 1em;
    @include radius;
  }
  .success-button{
    display: block;
    margin: 1em auto;
  }
</style>
