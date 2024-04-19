<script lang="ts">
  import Link from '#app/lib/components/link.svelte'
  import { git, wiki, dataHome, translate, blog, faq, communicationChannels } from '#app/lib/urls'
  import { i18n, I18n } from '#user/lib/i18n'
  import FooterIconLink from '#welcome/components/footer_icon_link.svelte'
</script>

<section id="icon-links">
  <FooterIconLink icon="pencil-square-o" url={wiki} text={I18n('documentation')} />
  <FooterIconLink icon="newspaper-o" url={blog} text={i18n('Articles & videos')} />
  <FooterIconLink icon="question" url={faq} text={I18n('FAQ')} />
  <FooterIconLink icon="code" url={git} text={I18n('code')} />
  <FooterIconLink icon="database" url={dataHome} text={I18n('data')} />
  <FooterIconLink icon="language" url={translate} text={I18n('translation')} />
  <FooterIconLink icon="comments" url={communicationChannels} text={I18n('join the conversation')} />
</section>

<section id="legal">
  <Link
    url="https://wiki.inventaire.io/wiki/Credits"
    text={I18n('credits')}
    classNames="link"
    light={true}
  />
  <Link
    url="https://wiki.inventaire.io/wiki/Legal_notice"
    text={I18n('legal notice')}
    classNames="link"
    light={true}
  />
  <Link
    url="https://wiki.inventaire.io/wiki/Statuses"
    text={I18n('statuses')}
    classNames="link"
    light={true}
  />
  <Link
    url="https://wiki.inventaire.io/wiki/Funding"
    text={I18n('funding')}
    classNames="link"
    light={true}
  />
  <Link
    url="https://wiki.inventaire.io/wiki/Funding#Donations"
    text={I18n('donate')}
    classNames="link"
    light={true}
  />
</section>

<style lang="scss">
  @import "#general/scss/utils";

  section{
    background-color: $darker-grey;
    text-align: center;
  }
  #icon-links{
    @include display-flex(row, flex-start, space-around, wrap);
    padding: 1em;
  }
  #legal{
    @include display-flex(row, center, center, wrap);
    :global(a){
      margin: 0.5em;
    }
  }
</style>
