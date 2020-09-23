/* eslint-disable
    import/no-duplicates,
    no-return-assign,
    no-undef,
    no-var,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import Tasks from 'modules/tasks/collections/tasks'

export default function (attrs) {
  const { _id } = attrs

  this.set({
    aliases: {},
    isInvEntity: true,
    // Always setting the invUri as long as some inv entities
    // use an alternative uri format (namely isbn: uris)
    invUri: `inv:${_id}`
  })

  return _.extend(this, specificMethods)
};

var specificMethods = {
  fetchMergeSuggestions () {
    if (this.mergeSuggestionsPromise != null) { return this.mergeSuggestionsPromise }

    const uri = this.get('uri')

    return this.mergeSuggestionsPromise = _.preq.get(app.API.tasks.bySuspectUris(uri))
      .then(res => {
        const tasks = res.tasks[uri]
        this.mergeSuggestions = new Tasks(tasks)
        this.mergeSuggestions.sort()
        return this.mergeSuggestions
      })
  }
}
