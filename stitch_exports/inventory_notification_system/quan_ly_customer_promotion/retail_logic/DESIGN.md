---
name: Retail Logic
colors:
  surface: '#faf9fb'
  surface-dim: '#dbd9dc'
  surface-bright: '#faf9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f3f6'
  surface-container: '#efedf0'
  surface-container-high: '#e9e8ea'
  surface-container-highest: '#e3e2e5'
  on-surface: '#1b1c1e'
  on-surface-variant: '#43474d'
  inverse-surface: '#2f3033'
  inverse-on-surface: '#f2f0f3'
  outline: '#74777e'
  outline-variant: '#c4c6ce'
  surface-tint: '#49607e'
  primary: '#000f22'
  on-primary: '#ffffff'
  primary-container: '#0a2540'
  on-primary-container: '#768dad'
  inverse-primary: '#b0c8eb'
  secondary: '#006c49'
  on-secondary: '#ffffff'
  secondary-container: '#6cf8bb'
  on-secondary-container: '#00714d'
  tertiary: '#1a0b00'
  on-tertiary: '#ffffff'
  tertiary-container: '#381d00'
  on-tertiary-container: '#ae835a'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d2e4ff'
  primary-fixed-dim: '#b0c8eb'
  on-primary-fixed: '#001c37'
  on-primary-fixed-variant: '#314865'
  secondary-fixed: '#6ffbbe'
  secondary-fixed-dim: '#4edea3'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005236'
  tertiary-fixed: '#ffdcbe'
  tertiary-fixed-dim: '#eebd90'
  on-tertiary-fixed: '#2d1600'
  on-tertiary-fixed-variant: '#613f1c'
  background: '#faf9fb'
  on-background: '#1b1c1e'
  surface-variant: '#e3e2e5'
  background-slate: '#F8FAFC'
  border-gray: '#E2E8F0'
  text-dark: '#334155'
  text-muted: '#64748B'
  status-error: '#EF4444'
  status-warning: '#F59E0B'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  metadata:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  data-tabular:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  safe-area: 16px
  gutter: 12px
  touch-target: 48px
  stack-sm: 8px
  stack-md: 16px
---

# Global Design Guidelines: Mini Supermarket Internal Management App
## 1. Core Architecture & Design System
*   **Framework:** Flutter (Material 3 standard).
*   **Style:** Modern corporate, minimal brutalism for data-heavy screens, high information density but highly readable.
*   **Layout:** Mobile portrait (9:16 aspect ratio, e.g., 390x844px). Edge-to-edge design with 16px horizontal safe area padding. No device mockup bezels.
## 2. Color Palette & Theming
*   **Primary Brand:** Deep Corporate Blue (e.g., #0A2540) for app bars, primary action buttons, and active states.
*   **Secondary/Action:** Emerald Green (e.g., #10B981) for success indicators, inventory additions, and checkout completion.
*   **Backgrounds:** Pure White (#FFFFFF) for content cards, Light Slate Gray (#F8FAFC) for app background to create structural depth.
*   **Alerts & Status:** Crimson Red (#EF4444) for critical errors/low stock, Amber Yellow (#F59E0B) for warnings/expiring items.
*   **Dividers & Borders:** Ultra-light Gray (#E2E8F0), 1px solid line for separating list items.
## 3. Typography & Hierarchy
*   **Font Family:** Inter or Roboto (clean, sans-serif optimized for mobile screens).
*   **Headers:** Bold, 20px-24px, Dark Navy. Used for screen titles, section headers, and primary dashboard metrics.
*   **Body Text:** Regular, 14px, Dark Gray (#334155). Used for product names, descriptions, and list item contents.
*   **Metadata/Captions:** Medium, 12px, Muted Gray (#64748B). Used for timestamps, SKUs, barcode numbers, and subtle helper texts.
*   **Numerical Data:** Monospace font configuration for financial figures, stock counts, and receipt numbers to ensure perfect vertical alignment in tables and lists.
## 4. UI Components Detailed Specifications
*   **Cards (Containers):** 12px border radius, white background, subtle drop shadow (elevation level 1). Used to group related data (e.g., Customer Profile, Order Details).
*   **Buttons & Actions:**
    *   *Primary Buttons:* Solid Primary Blue fill, 48px height (touch-target optimized), 8px border radius, bold white text. Center alignment.
    *   *Floating Action Button (FAB):* Prominent placement (bottom-right), high-contrast color, used exclusively for core repetitive actions like "Barcode Scanner" or "Create Document".
    *   *Secondary Buttons:* Transparent background with 1px solid primary color outline.
    *   *Badges/Tags:* Small pill-shaped containers with muted background colors and solid text (e.g., "Pending", "Approved") for status tracking.
*   **Input Fields:** Material 3 outlined text fields with 8px border radius. Must display clear focus states (thick blue border) and error states (red border with specific error text below).
*   **Navigation:** Fixed Bottom Navigation Bar supporting 4-5 distinct items. Active state uses filled icon and Primary color; inactive state uses outlined icon and Muted Gray.
## 5. UX & Interaction Requirements
*   **High Contrast:** Critical for harsh lighting environments in retail stores. Text and background combinations must meet WCAG AAA contrast ratios.
*   **Iconography:** Strictly functional (Material standard). No decorative or abstract icons. Real-world metaphors (e.g., physical box for inventory, receipt paper for orders).
*   **Data Visualization:** Incorporate micro-charts (sparklines) inside dashboard cards. Use linear progress bars for visual stock capacity limits.
*   **Edge Cases & States:** Designs must account for "Empty States" (e.g., illustrative gray box when no search results found), "Loading Skeletons" (shimmering placeholders instead of loading spinners), and structured "Error Modals".