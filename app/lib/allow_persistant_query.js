const alwaysKeep = () => true;

const redirectTest = section => allowRedirectPersistantQuery.includes(section);

var allowRedirectPersistantQuery = [
  'signup',
  'login'
];

export { alwaysKeep as debug, alwaysKeep as lang, redirectTest as redirect, alwaysKeep as authors, alwaysKeep as editions, alwaysKeep as descriptions, alwaysKeep as large };
