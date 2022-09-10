<script>
  import { I18n } from '#user/lib/i18n'
  import { isNonEmptyString, isNonEmptyPlainObject } from '#lib/boolean_tests'
  import Spinner from '#general/components/spinner.svelte'
  import WrapToggler from '#components/wrap_toggler.svelte'
  import Link from '#lib/components/link.svelte'
  import { getWikipediaExtract } from '#entities/components/lib/wikipedia_extract_helpers'
  import EntityImage from '../entity_image.svelte'

  export let entity

  const { image } = entity

  let isUnwrapped = false

  let extractElementHeight
  // sync with &:not(.show-more)
  const maxHeight = 160
  // When extractElementHeight is below maxHeight,
  // it will be forever, so dont display toggler
  $: displayToggler = extractElementHeight >= maxHeight
</script>
{#await getWikipediaExtract(entity)}
  <Spinner/>
{:then res}
  <div class="wikipedia-extract-row">
      {#if isNonEmptyPlainObject(image)}
        <div class="entity-image">
          <EntityImage
            {entity}
            withLink={false}
            size={400}
          />
        </div>
      {/if}
      {#if isNonEmptyString(res.extract)}
        <div
          class="wikipedia-extract"
          class:show-more={isUnwrapped}
          bind:clientHeight={extractElementHeight}
        >
          {res.extract}
          <Link
            url={res.url}
            text={I18n('read_more_on_wikipedia')}
            grey={true}
          />
        </div>
        {#if displayToggler}
          <div class="wrap-toggler-wrapper">
            <WrapToggler
              bind:show={isUnwrapped}
              moreText={I18n('read more...')}
              lessText={I18n('read less')}
            />
          </div>
        {/if}
      {/if}
  </div>
{/await}
<style lang="scss">
  @import '#general/scss/utils';
  .wikipedia-extract-row{
    padding: 1em 0;
  }
  .wikipedia-extract{
    line-height: 1.6;
    position: relative;
    &:not(.show-more){
      // sync with maxHeight
      max-height: 160px;
      overflow: hidden;
    }
  }
  .entity-image {
    float: left;
    width: 7em;
    margin-right: 1em;
    padding-top: 0.3em;
  }
</style>
