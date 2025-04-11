import { defineConfig } from 'eslint/config';
import js from '@eslint/js';
import globals from 'globals';

export default defineConfig(
  [
    {
      files: ['app/javascript/**/*.{js,mjs,cjs}'],
      plugins: { js },
      extends: ['js/recommended'],
      languageOptions: {
        globals: globals.browser,
      },
      rules: {
        'prettier/prettier': 'error',
      },
    },
  ],
  {
    ignores: ['app/assets/**', 'vendor/**', 'node_modules/**'],
  },
);
