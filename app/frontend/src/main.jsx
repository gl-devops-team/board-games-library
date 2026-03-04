/**
 * Application entry point.
 *
 * This file bootstraps the React application and mounts
 * the root <App /> component into the DOM.
 *
 * Responsibilities:
 * - Import global styles
 * - Initialize React root
 * - Render the main App component
 */

import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.jsx'

/**
 * Root DOM element where the React application is mounted.
 *
 * @type {HTMLElement | null}
 */
const rootElement = document.getElementById('root')

/**
 * Create a React root and render the application.
 *
 * StrictMode enables additional checks and warnings
 * during development (does not affect production build).
 */
createRoot(rootElement).render(
  <StrictMode>
    <App />
  </StrictMode>,
)