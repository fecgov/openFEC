const finalRules = {
  /* airbnb config overrides */
  'react/jsx-filename-extension': [0],
  'react/no-render-return-value': [0],
  'import/no-extraneous-dependencies': [0],
  'import/no-named-as-default': [0], // allow component to be the same as the default export
  'class-methods-use-this': [0],
  'no-throw-literal': [0],
  'camelcase': [0],
  'object-curly-newline': [0],
  'comma-dangle': ['error',
    {
      arrays: 'always-multiline',
      objects: 'always-multiline',
      imports: 'always-multiline',
      exports: 'always-multiline',
      functions: 'never',
    },
  ],
  'jsx-a11y/anchor-is-valid': [ 'error', {
    'components': [ 'NoLink' ],
    'specialLink': [ 'hrefLeft', 'hrefRight' ],
    'aspects': [ 'noHref', 'invalidHref', 'preferButton' ]
  }],
};

module.exports = {
  extends: 'airbnb',
  globals: {
    'document': true
  },
  rules: finalRules,
  parserOptions: {
    ecmaVersion: 6,
  },
};
