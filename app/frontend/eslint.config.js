/**
 * ESLint configuration for the frontend project.
 *
 * This configuration:
 * - Enables recommended ESLint rules
 * - Adds React Hooks linting support
 * - Adds React Refresh (Vite) support
 * - Configures modern ECMAScript settings
 * - Defines browser global variables
 * - Customizes selected linting rules
 */

import js from '@eslint/js'
import globals from 'globals'
import reactHooks from 'eslint-plugin-react-hooks'
import reactRefresh from 'eslint-plugin-react-refresh'
import { defineConfig, globalIgnores } from 'eslint/config'

/**
 * Exported ESLint flat configuration.
 *
 * Uses ESLint's modern "flat config" format.
 */
export default defineConfig([

  /**
   * Globally ignore the `dist` directory.
   *
   * This prevents linting of production build artifacts.
   */
  globalIgnores(['dist']),

  {
    /**
     * Target files for this configuration.
     *
     * Applies to all JavaScript and JSX files in the project.
     */
    files: ['**/*.{js,jsx}'],

    /**
     * Base configurations extended by this setup:
     *
     * - ESLint recommended rules
     * - React Hooks recommended rules
     * - React Refresh configuration (optimized for Vite)
     */
    extends: [
      js.configs.recommended,
      reactHooks.configs.flat.recommended,
      reactRefresh.configs.vite,
    ],

    /**
     * Language options defining ECMAScript version and environment.
     */
    languageOptions: {
      /**
       * ECMAScript version used for parsing.
       */
      ecmaVersion: 2020,

      /**
       * Browser global variables (window, document, etc.).
       */
      globals: globals.browser,

      /**
       * Parser configuration options.
       */
      parserOptions: {
        ecmaVersion: 'latest',

        /**
         * Enable JSX syntax support.
         */
        ecmaFeatures: { jsx: true },

        /**
         * Use ES module syntax (import/export).
         */
        sourceType: 'module',
      },
    },

    /**
     * Custom rule overrides.
     */
    rules: {
      /**
       * Disallow unused variables.
       *
       * Exception:
       * - Variables starting with uppercase letters or underscore
       *   are ignored (useful for React components or constants).
       */
      'no-unused-vars': ['error', { varsIgnorePattern: '^[A-Z_]' }],
    },
  },
])