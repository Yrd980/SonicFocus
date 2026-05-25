---
name: SonicFocus
colors:
  surface: '#131314'
  surface-dim: '#131314'
  surface-bright: '#3a393a'
  surface-container-lowest: '#0e0e0f'
  surface-container-low: '#1c1b1c'
  surface-container: '#201f20'
  surface-container-high: '#2a2a2b'
  surface-container-highest: '#353436'
  on-surface: '#e5e2e3'
  on-surface-variant: '#c2c6d6'
  inverse-surface: '#e5e2e3'
  inverse-on-surface: '#313031'
  outline: '#8c909f'
  outline-variant: '#424754'
  surface-tint: '#adc6ff'
  primary: '#adc6ff'
  on-primary: '#002e6a'
  primary-container: '#4d8eff'
  on-primary-container: '#00285d'
  inverse-primary: '#005ac2'
  secondary: '#d0bcff'
  on-secondary: '#3c0091'
  secondary-container: '#571bc1'
  on-secondary-container: '#c4abff'
  tertiary: '#4edea3'
  on-tertiary: '#003824'
  tertiary-container: '#00a572'
  on-tertiary-container: '#00311f'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#adc6ff'
  on-primary-fixed: '#001a42'
  on-primary-fixed-variant: '#004395'
  secondary-fixed: '#e9ddff'
  secondary-fixed-dim: '#d0bcff'
  on-secondary-fixed: '#23005c'
  on-secondary-fixed-variant: '#5516be'
  tertiary-fixed: '#6ffbbe'
  tertiary-fixed-dim: '#4edea3'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005236'
  background: '#131314'
  on-background: '#e5e2e3'
  surface-variant: '#353436'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Geist
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.05em
  mono-technical:
    fontFamily: Geist
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-padding-desktop: 40px
  container-padding-mobile: 20px
  gutter: 24px
  section-gap: 64px
---

## Brand & Style

The design system embodies a premium, futuristic atmosphere tailored for high-fidelity audio engineering and immersive listening. It targets a sophisticated audience of audiophiles, producers, and tech enthusiasts who value precision and aesthetic depth. 

The visual direction is **Futuristic Glassmorphism**. It combines the structural clarity of a professional workstation with the ethereal quality of semi-transparent surfaces. The interface should feel like a high-end physical hardware console reimagined for a digital space, utilizing deep obsidian backgrounds, vibrant neon accents, and soft, multi-layered blurs to create a sense of infinite depth.

## Colors

The palette is rooted in a "Deep Space" ethos. The primary background is a near-black navy (`#0A0A0B`) that provides maximum contrast for luminous accents. 

- **Primary (Electric Blue):** Used for active states, primary controls, and high-frequency audio visualizers.
- **Secondary (Deep Purple):** Used for auxiliary functions, secondary data layers, and low-frequency depth indicators.
- **Surface Treatment:** Surfaces are not solid; they use a translucent glass effect with a 20px–40px backdrop blur. 
- **Gradients:** Use subtle linear gradients (45-degree angle) between Electric Blue and Deep Purple for interactive elements like sliders and primary buttons to suggest energy and movement.

## Typography

This design system utilizes **Inter** for its clean, Swiss-inspired legibility across the core interface. To enhance the technical "control center" feel, **Geist** is introduced for labels and technical readouts, providing a monospaced-adjacent precision that complements the futuristic aesthetic.

Headlines should remain tight with slight negative letter-spacing to feel impactful and modern. Labels and technical data points should use uppercase and expanded letter-spacing to mimic the readout of professional audio hardware.

## Layout & Spacing

The layout follows a **fluid grid system** with generous margins to emulate a premium, spacious Apple-like aesthetic. 

- **Desktop:** 12-column grid with 24px gutters. Elements should be grouped into large, glassmorphic cards that span multiple columns.
- **Mobile:** 4-column grid. Complex audio controls (like EQ faders) should transition from horizontal layouts to vertical stacks or scrollable carousels.
- **Rhythm:** All spacing must be multiples of 8px. Use 40px–64px gaps between major sections to maintain a sense of "air" and luxury.

## Elevation & Depth

Depth is achieved through **Tonal Layering and Translucency** rather than traditional drop shadows.

- **Level 0 (Base):** Deep Navy background (#0A0A0B).
- **Level 1 (Panels):** Glass surfaces with 3% white opacity and a 30px backdrop blur.
- **Level 2 (Active Elements):** Elements that are hovered or active should gain a subtle "Inner Glow" (1px solid border at 20% opacity of the Primary color) and a very soft, diffused outer glow (0px 4px 20px) using a tinted version of the Primary color.
- **Borders:** All glass panels must have a 0.5px or 1px stroke. Use a gradient stroke (Top-Left: white at 10% to Bottom-Right: white at 2%) to simulate light hitting the edge of the "glass."

## Shapes

The shape language is dominated by **large, soft radii** to contrast the technical complexity of audio data. 

- **Primary Containers:** 24px–32px corner radius (defined as `rounded-xl`).
- **Interactive Controls (Sliders/Buttons):** 12px corner radius (defined as `rounded-lg`).
- **Data Points:** Small circular nodes (fully rounded) for graph points and toggles.

The combination of sharp technical lines (in visualizers) and soft container shapes creates a balanced, high-end look.

## Components

### Buttons
Primary buttons use a subtle gradient fill from Electric Blue to Deep Purple. Secondary buttons are "ghost" style with a 1px glass border. All buttons should have a subtle hover transition where the backdrop blur intensity increases.

### Audio Sliders
The track of the slider is a thin, dark recessed line. The "thumb" or handle is a glowing circular element. The "filled" portion of the track should pulse slightly with the audio rhythm.

### Cards & Panels
Use "Glass Cards" for all grouping. These panels should have no solid background color, relying entirely on backdrop-filter: blur(24px) and a thin white-to-transparent border.

### Visualizers
Audio waveforms and spectrum analyzers must be rendered with high-frequency detail using thin 1px lines. Use the Primary color for mid-tones and Secondary color for peaks, creating a vibrant neon glow effect.

### Input Fields
Inputs are dark, recessed wells with a 10% opacity fill and a sharp 1px focus ring in Electric Blue. Use Geist font for all numeric input to ensure character alignment.