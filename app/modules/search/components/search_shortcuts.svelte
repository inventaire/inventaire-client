<script lang="ts">
  import { fade } from 'svelte/transition'
  import { i18n, I18n } from '#user/lib/i18n'
</script>

<ul class="shortcuts" in:fade>
  <li>
    <div class="key"><span class="symbol">↓</span>{I18n('down')}</div>
    {I18n('next result')}
  </li>
  <li>
    <div class="key"><span class="symbol">↑</span>{I18n('up')}</div>
    {I18n('previous result')}
  </li>
  <li>
    <div class="key"><span class="symbol">↩</span>{I18n('enter')}</div>
    {I18n("go to result's page")}
  </li>
  <li>
    <div class="key"><span class="symbol">⇟</span>{i18n('PgDn')}</div>
    {I18n('next category')}
  </li>
  <li>
    <div class="key"><span class="symbol">⇞</span>{i18n('PgUp')}</div>
    {I18n('previous category')}
  </li>
</ul>

<style lang="scss">
  @import "#general/scss/utils";
  .shortcuts{
    @include position(fixed, $topbar-height, 0);
    background-color: rgba($dark-grey, 0.6);
    @include radius;
    margin: 0.5em;
    color: white;
    @include display-flex(column);
  }
  li{
    margin: 0.5em;
    @include display-flex(row, center, flex-start);
  }
  .key{
    @include display-flex(row, center, flex-start);
    background-color: #555;
    padding: 0.2em;
    @include radius;
    width: 5em;
    margin-inline-end: 0.5em;
    font-weight: bold;
  }
  .symbol{
    width: 1em;
    font-size: 1.2em;
    text-align: center;
    margin-inline: 0.2em 0.4em;
  }
</style>
