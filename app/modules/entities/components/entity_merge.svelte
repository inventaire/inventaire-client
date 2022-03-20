<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import EntityMergeSection from '#entities/components/entity_merge_section.svelte'
  import { icon } from '#lib/handlebars_helpers/icons'
  import mergeEntities from '#entities/views/editor/lib/merge_entities'
  import Flash from '#lib/components/flash.svelte'

  export let from, to, type

  let flash

  async function merge () {
    try {
      await mergeEntities(from, to)
    } catch (err) {
      flash = err
    }
  }
</script>

<div class="entityMergeLayout">
  <h2>{i18n('Merge entities')}</h2>

  <section>
    <!-- svelte-ignore a11y-label-has-associated-control -->
    <label>
      {i18n('The entity that should be merged')}
      <EntityMergeSection
        bind:uri={from}
        {type}
        on:select={e => from = e.detail}
      />
    </label>
  </section>

  <section>
    <!-- svelte-ignore a11y-label-has-associated-control -->
    <label>
      {i18n('The entity in which it should be merged')}
      <EntityMergeSection
        bind:uri={to}
        {type}
        on:select={e => to = e.detail}
      />
    </label>
  </section>

  <button
    disabled={!(from && to)}
    class="success-button"
    on:click={merge}
    >
    {@html icon('compress')}
    {I18n('merge')}
  </button>

  <Flash bind:state={flash}/>
</div>


<style lang="scss">
  @import '#general/scss/utils';
  .entityMergeLayout{
    max-width: 50em;
    margin: 1em auto;
    padding: 1em 2em;
    @include radius;
    background-color: white;
  }
  h2{
    text-align: center;
    margin-top: 0;
  }
  label{
    font-size: 1rem;
    color: $dark-grey;
  }
  section{
    margin-bottom: 1em;
  }
  .success-button{
    display: block;
    margin: 0 auto;
  }
</style>
