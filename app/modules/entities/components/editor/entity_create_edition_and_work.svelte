<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import PropertyClaimsEditor from '#entities/components/editor/property_claims_editor.svelte'
  import wdLang from 'wikidata-lang'
  import preq from '#lib/preq'

  export let edition

  edition.type = 'edition'

  let work = {
    type: 'work',
    claims: {}
  }

  const workProperties = [
    'wdt:P50',
    'wdt:P136',
    'wdt:P921',
  ]

  const editionProperties = [
    'wdt:P212',
    'wdt:P1476', // required
    'wdt:P1680',
    'wdt:P407', // required
    'wdt:P123',
    'invp:P2',
  ]

  // TODO: add required properties

  async function create () {
    const title = edition.claims['wdt:P1476'][0]
    const titleLang = edition.claims['wdt:P407'][0]
    const workLabelLangCode = wdLang.byWdId[titleLang]?.code || 'en'
    work.labels = { [workLabelLangCode]: title }
    const entry = {
      edition,
      works: [ work ]
    }
    const { entries } = await preq.post(app.API.entities.resolve, {
      entries: [ entry ],
      update: true,
      create: true,
      enrich: true
    })
    const { uri } = entries[0].edition
    app.execute('show:entity', uri, { refresh: true })
  }
</script>

<div class="column">
  <p class="context">
    {i18n('No data could be found for that ISBN.')}
    {I18n('can you tell us more about this work and this particular edition?')}
  </p>
  <section class="work">
    <h2>{I18n('work')}</h2>
    <p class="help">{i18n('Data common to all editions of this book')}</p>
    {#each workProperties as property}
      <PropertyClaimsEditor
        bind:entity={work}
        {property}
      />
    {/each}
  </section>
  <section class="edition">
    <h2>{I18n('edition')}</h2>
    <p class="help">{i18n('Data specific to that particular edition')}</p>
    {#each editionProperties as property}
      <PropertyClaimsEditor
        bind:entity={edition}
        {property}
      />
    {/each}
  </section>
  <button
    on:click={create}
    class="success-button"
    >
    {I18n('create')}
  </button>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .column{
    @include display-flex(column, stretch, center);
    max-width: 50em;
    margin: 1em auto;
  }
  .context{
    margin-top: .6em;
    text-align: center;
  }
  h2, .help{
    text-align: center;
    margin: 0;
  }
  h2{
    font-size: 1.4rem;
  }
  .work, .edition{
    background-color: $light-grey;
    @include radius;
    margin: 1em 0;
    padding: 1em;
  }
  .success-button{
    margin: 0 auto;
  }
</style>
