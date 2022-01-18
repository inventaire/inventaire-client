<script>
  import { I18n } from '#user/lib/i18n'
  import _ from 'underscore'
  import Flash from '#lib/components/flash.svelte'
  import log_ from '#lib/loggers'
  import app from '#app/app'
  import createEntity from '#entities/lib/create_entity'
  import entityDraft from '#entities/lib/entity_draft_model'

  export let candidates
  export let transaction
  export let listing
  let flash
  let importingCandidates
  let processedCandidates = 0

  const importCandidates = async () => {
    flash = null
    if (importingCandidates) return flash = { type: 'warning', message: I18n('already importing books') }
    importingCandidates = true
    if (_.isEmpty(candidates)) return flash = { type: 'warning', message: I18n('no book selected') }
    processedCandidates = 0

    const remainingCandidates = _.clone(candidates)
    const failedImports = []

    candidates = await Promise.all(candidates.map(createEntitiesByCandidate))
    const createItem = async () => {
      if (remainingCandidates.length === 0) return
      const nextCandidate = remainingCandidates.pop()
      const { edition } = nextCandidate
      if (edition && nextCandidate.checked) {
        const { uri: editionUri } = edition
        if (editionUri) {
          await app.request('item:create', {
            transaction,
            listing,
            details: nextCandidate.details,
            entity: editionUri
          })
          .catch(err => {
            failedImports.push(nextCandidate.preCandidate.isbn)
            log_.error(err, 'createItem err')
          })
        }
      }
      processedCandidates += 1
      await createItem()
    }

    return createItem()
    .then(() => {
      if (failedImports.length > 0) {
        flash = { type: 'error', message: I18n('not_imported_books', { failedImports: failedImports.join(', ') }) }
      } else {
        flash = { type: 'success', message: I18n('import completed') }
      }
      importingCandidates = false
    })
  }

  const createEntitiesByCandidate = async candidate => {
    const { customWorkTitle, customAuthorName } = candidate
    if (candidate.works || !customWorkTitle) return candidate
    let author
    if (!candidate.authors && customAuthorName) {
      const authorDraft = entityDraft.createDraft({ type: 'author', label: customAuthorName, claims: {} })
      author = await createEntity(authorDraft)
    }
    const workClaims = {}
    if (author?.uri) workClaims['wdt:P50'] = [ author.uri ]
    const workDraft = entityDraft.createDraft({ type: 'work', label: customWorkTitle, claims: workClaims })
    const work = await createEntity(workDraft)
    const claims = {
      'wdt:P629': [ work.uri ],
      'wdt:P1476': [ customWorkTitle ],
      'wdt:P212': [ candidate.preCandidate.isbnData.isbn13h ]
    }
    const draft = entityDraft.createDraft({ type: 'edition', claims })
    const edition = await createEntity(draft)
    candidate.edition = edition
    candidate.works = [ work ]
    // TODO: handle several authors case, probably when developping contributive entity builder
    if (author) candidate.authors = [ author ]
    return candidate
  }

  $: candidatesLength = candidates.length
</script>
<div class="importCandidates">
  <h3>4/ {I18n('import this batch')}</h3>
  <Flash bind:state={flash}/>
  {#if flash?.type === 'success'}
    <button
      href="/"
      class="button"
      on:click="{() => app.execute('show:home')}"
      >{I18n('See the new books in my inventory')}</button>
  {:else}
    <button
      class="importCandidatesButton button success"
      class:disabled={importingCandidates}
      on:click={importCandidates}
      >
      {I18n('import the selection')}
    </button>
  {/if}
</div>

<style lang="scss">
  @import 'app/modules/general/scss/utils';
  h3{
    margin-top: 1em;
    text-align: center;
  }
  .importCandidates {
    @include display-flex(column, center, center, wrap);
    button { margin: 1em 0; }
    text-align:center;
  }
</style>
