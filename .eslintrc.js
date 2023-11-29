const finalRules = {
  /* airbnb config overrides */
  "react/jsx-filename-extension": [0],
  "react/no-render-return-value": [0],
  "react/no-array-index-key": [0],
  "react/destructuring-assignment": [
    0,
    "enabled",
    "always",
    { ignoreClassFields: "True" },
  ], //ignore destructuring-assignment in class fields
  "import/no-extraneous-dependencies": [0],
  "import/no-named-as-default": [0], // allow component to be the same as the default export
  "class-methods-use-this": [0],
  "no-throw-literal": [0],
  camelcase: [0],
  "arrow-parens": [0],
  "object-curly-newline": [0],
  "comma-dangle": [
    "error",
    {
      arrays: "always-multiline",
      objects: "always-multiline",
      imports: "always-multiline",
      exports: "always-multiline",
      functions: "never",
    },
  ],
  "jsx-a11y/anchor-is-valid": [
    "error",
    {
      components: ["NoLink"],
      specialLink: ["hrefLeft", "hrefRight"],
      aspects: ["noHref", "invalidHref", "preferButton"],
    },
  ],
  "prettier/prettier": "error",
};

module.exports = {
  extends: ["airbnb", "plugin:prettier/recommended"],
  globals: {
    document: true,
  },
  rules: finalRules,
  parserOptions: {
    ecmaVersion: 6,
  },
  plugins: ["prettier"],
};
