<script>
  import { I18n } from '#user/lib/i18n'
  import { createEventDispatcher } from 'svelte'
  import { getBasicInfoByUri } from '#entities/lib/entities'
  import Spinner from '#general/components/spinner.svelte'
  import IdentifierWithTooltip from './identifier_with_tooltip.svelte'
  import { imgSrc } from '#lib/handlebars_helpers/images'

  export let value, valueLabel, valueBasicInfo

  let waitingForValueEntityBasicInfo, label, description, image
  const dispatch = createEventDispatcher()

  $: {
    if (value) {
      waitingForValueEntityBasicInfo = getBasicInfoByUri(value)
        .then(setInfo)
        .catch(err => dispatch('error', err))
    }
  }

  function setInfo (data) {
    valueBasicInfo = data
    valueLabel = label = data.label
    description = data.description
    image = data.image
  }
</script>

<button class="value-display" on:click={() => dispatch('edit')} title="{I18n('edit')}">
  {#await waitingForValueEntityBasicInfo}
    <Spinner />
  {:then}
    <div
      class="image"
      style:background-image={image ? `url(${imgSrc(image.url, 64, 64)})` : 'none'}
    >
    </div>
    <div>
      {#if label}<span class="label">{label}</span>{/if}
      <div class="bottom">
        {#if description}<span class="description">{description}</span>{/if}
        {#if value}
          <IdentifierWithTooltip uri={value} />
        {/if}
      </div>
    </div>
  {/await}
</button>

<style lang="scss">
  @import '#general/scss/utils';
  .value-display{
    flex: 1;
    height: 100%;
    font-weight: normal;
    @include display-flex(row, center, flex-start);
    cursor: pointer;
    text-align: left;
    @include bg-hover(white, 5%);
    user-select: text;
    padding: 0;
  }
  .image{
    flex: 0 0 3em;
    height: 3em;
    margin-right: 0.5em;
    background-size: cover;
    background-position: center center;
  }
  .bottom{
    padding: 0.5em 0;
  }
  .label{
    display: block;
    text-align: left;
    margin-top: 0.4em;
  }
  .description{
    color: $grey;
    margin-right: 1em;
  }
</style>
