<!-- TODO: refactor as a JS module -->
<script>
  import { isNonEmptyArray } from 'lib/boolean_tests'
  import { getEntitiesByUris } from '../lib/entities'
  import { getAuthorWorks } from '../lib/types/author'
  import { addWorksImages } from '../lib/types/work'
  import DeduplicateAuthors from './deduplicate_authors.svelte'
  import DeduplicateWorks from './deduplicate_works.svelte'

  let state, name, worksPromise

  export let uris

  if (!isNonEmptyArray(uris)) {
    uris = app.request('querystring:get', 'uris')?.split('|')
  }

  if (isNonEmptyArray(uris)) {
    loadFromUris(uris)
  } else {
    state = 'deduplicate:authors'
    name = app.request('querystring:get', 'name')
  }

  async function loadFromUris () {
    const entities = await getEntitiesByUris(uris)
    // Guess type from first entity
    const { type } = entities[0]
    if (type === 'human') {
      if (entities.length === 1) {
        worksPromise = getAuthorWorks(entities[0])
          .then(addWorksImages)
        state = 'deduplicate:works'
        return
      }
      // } else if (type === 'work') {
      // return this.showDeduplicateWorks(entities)
    }

    // If we haven't returned at this point, it is a non handled case
    throw new Error(`case not handled yet: ${type}`)
  }
</script>

<div class="content">
	{#if state === 'deduplicate:authors'}
		<DeduplicateAuthors {name} />
	{:else if state === 'deduplicate:works'}
		<DeduplicateWorks {worksPromise} />
	{/if}
</div>
