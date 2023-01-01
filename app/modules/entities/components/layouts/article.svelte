<script>
  import { i18n } from '#user/lib/i18n'
  import BaseLayout from './base_layout.svelte'
  import AuthorsInfo from './authors_info.svelte'
  import Infobox from './infobox.svelte'
  import { omitNonInfoboxClaims } from '#entities/components/lib/work_helpers'
  import Link from '#lib/components/link.svelte'
  import getBestLangValue from '#entities/lib/get_best_lang_value'

  export let entity, standalone

  const { uri, claims, wikisource, originalLang, description, label, labelLang } = entity

  const descriptionLang = getBestLangValue(app.user.lang, originalLang, description)

  let href
  const DOI = claims['wdt:P356']?.[0]
  if (DOI != null) href = `https://dx.doi.org/${DOI}`

  $: app.navigate(`/entity/${uri}`)
</script>

<BaseLayout
  bind:entity
  {standalone}
>
  <div class="entity-layout" slot="entity">
    <div class="top-section">
      <div class="work-section">
        <h4 lang={labelLang}>
          {#if href}
            <Link
              url={href}
              text={label}
              icon="link"
            />
          {:else}
            {label}
          {/if}
        </h4>
        {#if description}
          <p class="description grey" lang={descriptionLang}>{description}</p>
        {/if}
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
  </div>
</BaseLayout>

<style lang="scss">
  @import "#general/scss/utils";
  .entity-layout{
    @include display-flex(column, center);
    width: 100%;
  }
  .top-section{
    @include display-flex(row, flex-start, center);
    width: 100%;
  }
  .work-section{
    @include display-flex(column, flex-start);
    flex: 1 0 0;
    margin: 0 1em;
    :global(.claims-infobox-wrapper){
      margin-bottom: 1em;
    }
    :global(.wikisource){
      margin: 0.5em 0;
    }
  }
  .relatives-browser{
    margin: 1em 0;
    width: 100%;
  }
  /* Small screens */
  @media screen and (max-width: $small-screen){
    .work-section{
      margin-left: 0;
      :global(.claims-infobox-wrapper){
        margin-bottom: 0;
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
