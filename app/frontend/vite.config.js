/**
 * Vite configuration file for the frontend application.
 *
 * This configuration:
 * - Enables React support via the official Vite plugin
 * - Uses Vite's modern build system for fast development and optimized production builds
 *
 * @see https://vite.dev/config/
 */

import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

/**
 * Export the Vite configuration object.
 *
 * defineConfig provides better type inference and
 * improved IDE support for configuration options.
 */
export default defineConfig({

  /**
   * List of Vite plugins used in the project.
   *
   * react():
   * - Enables JSX transformation
   * - Supports Fast Refresh (instant React updates during development)
   * - Applies React-specific optimizations
   */
  plugins: [react()],

})