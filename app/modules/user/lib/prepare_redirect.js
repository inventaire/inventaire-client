import { buildPath } from 'lib/location';
const formAction = '/api/submit';

export default function(redirect){
  if (!redirect) { redirect = this.options.redirect || app.request('querystring:get', 'redirect'); }

  if (!_.isNonEmptyString(redirect)) { return formAction; }

  if (redirect[0] === '/') { redirect = redirect.slice(1); }

  return buildPath(formAction, { redirect });
};
