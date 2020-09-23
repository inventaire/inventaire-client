import sitelinks_ from 'lib/wikimedia/sitelinks';
import wikipedia_ from 'lib/wikimedia/wikipedia';
import getBestLangValue from 'modules/entities/lib/get_best_lang_value';
const { escapeExpression } = Handlebars;
const wdHost = 'https://www.wikidata.org';

export default function(attrs){
  const { lang } = app.user;
  setWikiLinks.call(this, lang);
  setAttributes.call(this, lang);

  this.set('isWikidataEntity', true);

  return _.extend(this, specificMethods);
};

var setWikiLinks = function(lang){
  const updates = {
    wikidata: {
      url: `${wdHost}/entity/${this.wikidataId}`,
      wiki: `${wdHost}/wiki/${this.wikidataId}`,
      history: `${wdHost}/w/index.php?title=${this.wikidataId}&action=history`
    }
  };

  const sitelinks = this.get('sitelinks');
  if (sitelinks != null) {
    updates.wikipedia = sitelinks_.wikipedia(sitelinks, lang, this.originalLang);
    updates.wikisource = sitelinks_.wikisource(sitelinks, lang, this.originalLang);
  }

  return this.set(updates);
};

var setAttributes = function(lang){
  let label = this.get('label');
  const wikipediaTitle = this.get('wikipedia.title');
  if ((wikipediaTitle != null) && (label == null)) {
    // If no label was found, try to use the wikipedia page title
    // remove the escaped spaces: %20
    label = decodeURIComponent(wikipediaTitle)
      // Remove the eventual desambiguation part between parenthesis
      .replace(/\s\(\w+\)/, '');

    this.set('label', label);
  }

  const description = getBestLangValue(lang, this.originalLang, this.get('descriptions')).value;
  if (description != null) { return this.set('description', description); }
};

var specificMethods = {
  getWikipediaExtract() {
    // If an extract was already fetched, we are done
    if (this.get('extract') != null) { return Promise.resolve(); }

    const lang = this.get('wikipedia.lang');
    const title = this.get('wikipedia.title');
    if ((lang == null) || (title == null)) { return Promise.resolve(); }

    return wikipedia_.extract(lang, title)
    .then(_setWikipediaExtractAndDescription.bind(this))
    .catch(_.Error('setWikipediaExtract err'));
  }
};

var _setWikipediaExtractAndDescription = function(extractData){
  const { extract, lang } = extractData;
  if (_.isNonEmptyString(extract)) {
    const extractDirection = rtlLang.includes(lang) ? 'rtl' : 'ltr';
    this.set('extractDirection', extractDirection);
    return this.set('extract', extract);
  }
};

var rtlLang = [ 'ar', 'he' ];
