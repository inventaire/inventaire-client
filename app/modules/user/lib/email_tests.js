import forms_ from 'modules/general/lib/forms';

export default {
  pass(email, selector){
    return forms_.pass({
      value: email,
      tests: emailTests,
      selector
    });
  },

  // verifies that the email isnt already in use
  verifyAvailability(email, selector){
    return _.preq.get(app.API.auth.emailAvailability(email))
    .catch(function(err){
      err.selector = selector;
      throw err;
    });
  }
};

var emailTests = {
  "it doesn't look like an email"(email){
    return !_.isEmail(email);
  }
};
