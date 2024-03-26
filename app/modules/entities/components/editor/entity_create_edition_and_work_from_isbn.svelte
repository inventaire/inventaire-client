<script>
  import { without } from 'underscore'
  import WrapToggler from '#components/wrap_toggler.svelte'
  import { createEditionAndWorkFromEntry, getMissingRequiredProperties } from '#entities/components/editor/lib/create_helpers'
  import PropertyClaimsEditor from '#entities/components/editor/property_claims_editor.svelte'
  import { propertiesPerType, requiredPropertiesPerType } from '#entities/lib/editor/properties_per_type'
  import Flash from '#lib/components/flash.svelte'
  import { i18n, I18n } from '#user/lib/i18n'

  export let edition, isbn13h

  edition.type = 'edition'

  let work = {
    type: 'work',
    claims: {},
  }

  let showAllWorkProperties = false
  let showAllEditionProperties = false

  let workPropertiesShortlist = [
    'wdt:P50',
    'wdt:P136',
    'wdt:P921',
  ]

  let editionPropertiesShortlist = [
    'wdt:P1476',
    'wdt:P1680',
    'wdt:P407',
    'wdt:P123',
    'invp:P2',
  ]

  const editionImplicitProperties = [
    'wdt:P629',
    'wdt:P212',
    'wdt:P957',
  ]

  const allWorkProperties = Object.keys(propertiesPerType.work)
  const allEditionProperties = without(Object.keys(propertiesPerType.edition), ...editionImplicitProperties)
  const isShortlisted = shortlist => property => shortlist.includes(property)
  // Regenerate shortlists from propertiesPerType properties to preserve order
  workPropertiesShortlist = allWorkProperties.filter(isShortlisted(workPropertiesShortlist))
  editionPropertiesShortlist = allEditionProperties.filter(isShortlisted(editionPropertiesShortlist))
  $: displayedWorkProperties = showAllWorkProperties ? allWorkProperties : workPropertiesShortlist
  $: displayedEditionProperties = showAllEditionProperties ? allEditionProperties : editionPropertiesShortlist

  const editionRequiredProperties = without(requiredPropertiesPerType.edition, ...editionImplicitProperties)

  let missingRequiredProperties
  function onEditionChange () {
    missingRequiredProperties = getMissingRequiredProperties({
      entity: edition,
      requiredProperties: editionRequiredProperties,
    })
    if (missingRequiredProperties.length > 0) {
      flash = {
        type: 'info',
        message: `${I18n('required properties are missing')}: ${missingRequiredProperties.join(', ')}`,
      }
    } else if (flash?.type === 'info') {
      flash = null
    }
  }

  $: edition && onEditionChange()

  let flash
  async function create () {
    try {
      const editionUri = await createEditionAndWorkFromEntry({ edition, work })
      app.execute('show:entity', editionUri, { refresh: true })
    } catch (err) {
      flash = err
    }
  }

  let workSection, editionSection
</script>

<div class="column">
  <h2>{isbn13h}</h2>
  <p class="context">{i18n('No data could be found for that ISBN.')}</p>
  <p class="context">{I18n('can you tell us more about this work and this particular edition?')}</p>

  <section class="work" bind:this={workSection}>
    <h2>{I18n('work')}</h2>
    <p class="help">{i18n('Data common to all editions of this book')}</p>
    <ul>
      {#each displayedWorkProperties as property (property)}
        <PropertyClaimsEditor
          bind:entity={work}
          {property}
        />
      {/each}
    </ul>
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
    <ul>
      {#each displayedEditionProperties as property (property)}
        <PropertyClaimsEditor
          bind:entity={edition}
          {property}
          required={editionRequiredProperties.includes(property)}
        />
      {/each}
    </ul>
    <WrapToggler
      bind:show={showAllEditionProperties}
      moreText={I18n('add more details')}
      lessText={I18n('show only main properties')}
      scrollTopElement={editionSection}
    />
  </section>

  <Flash state={flash} />

  <button
    class="success-button"
    disabled={missingRequiredProperties?.length > 0}
    on:click={create}
  >
    {I18n("create and go to the edition's page")}
  </button>
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .column{
    @include display-flex(column, stretch, center);
    max-inline-size: 50em;
    margin: 1em auto;
  }
  .context{
    margin-block-start: 0.6em;
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
    margin: 1em auto;
  }
  section{
    :global(.wrap-toggler){
      margin: 0 auto;
    }
  }
</style>
