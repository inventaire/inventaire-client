<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import { imgSrc } from '#app/lib/image_source'
  import { getEntityBasicInfoByUri, type SerializedEntity } from '#entities/lib/entities'
  import Spinner from '#general/components/spinner.svelte'
  import type { EntityUri } from '#server/types/entity'
  import { I18n } from '#user/lib/i18n'
  import IdentifierWithTooltip from './identifier_with_tooltip.svelte'

  export let value: EntityUri
  export let valueLabel: string = null
  export let valueBasicInfo: SerializedEntity = null

  let waitingForValueEntityBasicInfo, label, description, image
  const dispatch = createEventDispatcher()

  $: {
    if (value) {
      waitingForValueEntityBasicInfo = getEntityBasicInfoByUri(value)
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

<button
  class="value-display"
  on:click|stopPropagation={() => dispatch('edit')}
  title={I18n('edit')}
>
  {#await waitingForValueEntityBasicInfo}
    <Spinner />
  {:then}
    <div
      class="image"
      style:background-image={image ? `url(${imgSrc(image.url, 64, 64)})` : 'none'}
    />
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
  @import "#general/scss/utils";
  .value-display{
    flex: 1;
    block-size: 100%;
    font-weight: normal;
    @include display-flex(row, center, flex-start);
    cursor: pointer;
    text-align: start;
    @include bg-hover(white, 5%);
    user-select: text;
    padding: 0;
  }
  .image{
    flex: 0 0 3em;
    block-size: 3em;
    margin-inline-end: 0.5em;
    background-size: cover;
    background-position: center center;
  }
  .bottom{
    padding: 0.5em 0;
  }
  .label{
    display: block;
    text-align: start;
    margin-block-start: 0.4em;
  }
  .description{
    color: $grey;
    margin-inline-end: 1em;
  }
</style>
