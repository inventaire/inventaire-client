<script>
  import { I18n, i18n } from '#user/lib/i18n'
  import { isNonEmptyString, isNonEmptyPlainObject } from '#lib/boolean_tests'
  import Spinner from '#general/components/spinner.svelte'
  import preq from '#lib/preq'
  import WrapToggler from '#components/wrap_toggler.svelte'
  import sitelinks_ from '#lib/wikimedia/sitelinks'
  import Link from '#lib/components/link.svelte'
  import EntityImage from '../entity_image.svelte'

  export let entity

  const { uri, sitelinks, originalLang, image } = entity

  async function getWikipediaExtract () {
    if (!uri.startsWith('wd:')) return {}
    const userLang = app.user.lang
    const { title } = sitelinks_.wikipedia(sitelinks, userLang, originalLang)
    return preq.get(app.API.data.wikipediaExtract(userLang, title))
  }

  let showMore = false
</script>
{#await getWikipediaExtract()}
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
      <div class="wikipedia-extract-wrapper">
        <div
          class="wikipedia-extract"
          class:show-more={showMore}
        >
          {res.extract}
          <Link
            url={res.url}
            text={i18n('read_more_on_wikipedia')}
            grey={true}
          />
        </div>
        <div class="wrap-toggler-wrapper">
          <WrapToggler
            bind:show={showMore}
            moreText={I18n('more details...')}
            lessText={I18n('less details')}
          />
        </div>
      </div>
    {/if}
  </div>
{/await}
<style lang="scss">
  @import '#general/scss/utils';
  .wikipedia-extract-row{
    @include display-flex(row);
    padding: 1em 0;
  }
  .wikipedia-extract-wrapper{
    @include display-flex(column);
  }
  .wikipedia-extract{
    @include display-flex(column);
    line-height: 1.6;
    position: relative;
    &:not(.show-more){
      max-height: 10em;
      overflow: hidden;
    }
  }
  .entity-image{
    min-width: 7em;
    padding-right: 1em;
  }

  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .wikipedia-extract-row{
      @include display-flex(column, center, center);
    }
  }
</style>
