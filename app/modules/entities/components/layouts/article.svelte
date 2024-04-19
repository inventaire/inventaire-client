<script lang="ts">
  import { setContext } from 'svelte'
  import { debounce } from 'underscore'
  import app from '#app/app'
  import Link from '#app/lib/components/link.svelte'
  import { onChange } from '#app/lib/svelte/svelte'
  import WorksBrowser from '#entities/components/layouts/works_browser.svelte'
  import { getSubEntitiesSections } from '#entities/components/lib/entities'
  import { omitNonInfoboxClaims } from '#entities/components/lib/work_helpers'
  import Spinner from '#general/components/spinner.svelte'
  import { i18n } from '#user/lib/i18n'
  import AuthorsInfo from './authors_info.svelte'
  import BaseLayout from './base_layout.svelte'
  import EntityTitle from './entity_title.svelte'
  import Infobox from './infobox.svelte'

  export let entity

  const { uri, claims, wikisource } = entity

  setContext('layout-context', 'article')

  let href
  const DOI = claims['wdt:P356']?.[0]
  if (DOI != null) href = `https://dx.doi.org/${DOI}`

  let sections, waitingForReverseEntities, flash
  function getSections () {
    waitingForReverseEntities = getSubEntitiesSections({ entity })
      .then(res => sections = res)
      .catch(err => flash = err)
  }
  const lazyGetSections = debounce(getSections, 100)
  $: if (entity) onChange(entity, lazyGetSections)

  $: app.navigate(`/entity/${uri}`)
</script>

<BaseLayout
  bind:entity
  bind:flash
>
  <div class="entity-layout" slot="entity">
    <div class="top-section">
      <div class="work-section">
        <EntityTitle {entity} hasLinkTitle={href} {href} />
        <AuthorsInfo {claims} />
        <Infobox
          claims={omitNonInfoboxClaims(entity.claims)}
          entityType={entity.type}
        />
        {#if wikisource}
          <Link
            url={wikisource.url}
            text={i18n('on Wikisource')}
            icon="wikisource"
            classNames="wikisource"
          />
        {/if}
      </div>
    </div>
    <div class="relatives-browser">
      {#await waitingForReverseEntities}
        <Spinner center={true} />
      {:then}
        <WorksBrowser {sections} />
      {/await}
    </div>
    <!-- TODO: add RelativeEntitiesList "cited by" -->
  </div>
</BaseLayout>

<style lang="scss">
  @import "#general/scss/utils";
  .entity-layout{
    @include display-flex(column, center);
    inline-size: 100%;
  }
  .top-section{
    @include display-flex(row, flex-start, center);
    inline-size: 100%;
  }
  .work-section{
    @include display-flex(column, flex-start);
    flex: 1 0 0;
    margin: 0 1em;
    :global(.claims-infobox-wrapper){
      margin-block-end: 1em;
    }
    :global(.wikisource){
      margin: 0.5em 0;
    }
  }
  .relatives-browser{
    margin: 1em 0;
    inline-size: 100%;
  }
  /* Small screens */
  @media screen and (max-width: $small-screen){
    .work-section{
      margin-inline-start: 0;
      :global(.claims-infobox-wrapper){
        margin-block-end: 0;
      }
    }
    .top-section{
      @include display-flex(column, center);
    }
    .entity-layout{
      @include display-flex(column);
    }
  }
</style>
