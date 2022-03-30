<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import PropertyClaimsEditor from '#entities/components/editor/property_claims_editor.svelte'
  import wdLang from 'wikidata-lang'
  import preq from '#lib/preq'
  import WrapToggler from '#components/wrap_toggler.svelte'
  import propertiesPerType from '#entities/lib/editor/properties_per_type'

  export let edition

  edition.type = 'edition'

  let work = {
    type: 'work',
    claims: {}
  }

  let showAllWorkProperties = false
  let showAllEditionProperties = false

  let workPropertiesShortlist = [
    'wdt:P50',
    'wdt:P136',
    'wdt:P921',
  ]

  let editionPropertiesShortlist = [
    'wdt:P212',
    'wdt:P1476', // required
    'wdt:P1680',
    'wdt:P407', // required
    'wdt:P123',
    'invp:P2',
  ]

  const allWorkProperties = Object.keys(propertiesPerType.work)
  const allEditionProperties = _.without(Object.keys(propertiesPerType.edition), 'wdt:P629')
  const isShortlisted = shortlist => property => shortlist.includes(property)

  // Regenerate shortlists from propertiesPerType properties to preserve order
  workPropertiesShortlist = allWorkProperties.filter(isShortlisted(workPropertiesShortlist))
  editionPropertiesShortlist = allEditionProperties.filter(isShortlisted(editionPropertiesShortlist))

  $: displayedWorkProperties = showAllWorkProperties ? allWorkProperties : workPropertiesShortlist
  $: displayedEditionProperties = showAllEditionProperties ? allEditionProperties : editionPropertiesShortlist

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

  let workSection, editionSection
</script>

<div class="column">
  <p class="context">
    {i18n('No data could be found for that ISBN.')}
    {I18n('can you tell us more about this work and this particular edition?')}
  </p>

  <section class="work" bind:this={workSection}>
    <h2>{I18n('work')}</h2>
    <p class="help">{i18n('Data common to all editions of this book')}</p>
    {#each displayedWorkProperties as property (property)}
      <PropertyClaimsEditor
        bind:entity={work}
        {property}
      />
    {/each}
    <WrapToggler
      bind:show={showAllWorkProperties}
      moreText={I18n('add more details')}
      lessText={I18n('show only main properties')}
      scrollTopElement={workSection}
    />
  </section>

  <section class="edition">
    <h2>{I18n('edition')}</h2>
    <p class="help">{i18n('Data specific to that particular edition')}</p>
    {#each displayedEditionProperties as property (property)}
      <PropertyClaimsEditor
        bind:entity={edition}
        {property}
      />
    {/each}
    <WrapToggler
      bind:show={showAllEditionProperties}
      moreText={I18n('add more details')}
      lessText={I18n('show only main properties')}
      scrollTopElement={editionSection}
    />
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
  section{
    :global(.wrap-toggler) {
      margin: 0 auto;
    }
  }
</style>
