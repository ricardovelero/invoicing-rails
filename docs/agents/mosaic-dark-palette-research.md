# Investigación: paleta oscura de Cruip Mosaic

Fecha: 2026-09-23. Alcance: fuentes primarias de Cruip y código fuente de
Tailwind. No se modificó código de la aplicación como parte de esta
investigación.

## Conclusión

**Mosaic Lite actual no usa la combinación `slate`/`indigo` del handoff.** Su
paleta declarada es `gray` con acento `violet`: fondo `gray-100` a `gray-900`,
tarjetas `white` a `gray-800`, texto principal `gray-800` a `gray-100`, borde
`gray-200` a `gray-700/60` y primario `violet-500`. Esta es la referencia
Mosaic vigente que conviene usar si se busca reproducir Mosaic actual.

La app, sin embargo, es una recreación de una generación anterior de Mosaic
Lite. La revisión oficial que introdujo el modo oscuro (commit `d11ddd2`,
2023) sí usa `slate`/`indigo`; por ello se incluye una tabla de compatibilidad
al final. Mantener esa segunda tabla preserva la paridad visual light de esta
app, pero debe describirse como una adaptación de la versión histórica, no
como la paleta vigente de Mosaic.

No fue posible inspeccionar el código de Mosaic Pro: Cruip lo distribuye como
producto de pago. Su página oficial confirma que las versiones Lite públicas
son el mecanismo disponible para evaluar el código.

## Tabla recomendada: Mosaic Lite actual

Los valores son canales HSL sin función envolvente, listos para `hsl(var(...) /
<alpha-value>)`. Cruip no expone una capa de tokens semánticos; las filas se
obtienen agrupando las utilidades que el propio Lite usa de forma repetida. En
particular, `muted`, `secondary` e `input` son nombres de adaptación, no
nombres que existan literalmente en Mosaic.

| Token | Claro (HSL) | Oscuro (HSL) | Origen visual en Mosaic |
| --- | --- | --- | --- |
| `background` | `220 14.3% 95.9%` | `220.9 39.3% 11.0%` | `gray-100` → `gray-900` |
| `foreground` | `215 27.9% 16.9%` | `220 14.3% 95.9%` | título / enlace principal `gray-800` → `gray-100` |
| `card` | `0 0% 100%` | `215 27.9% 16.9%` | `white` → `gray-800` |
| `card-foreground` | `215 27.9% 16.9%` | `220 14.3% 95.9%` | igual que texto principal |
| `muted` | `220 14.3% 95.9%` | `216.9 19.1% 26.7%` | superficie neutra `gray-100` / `gray-700` |
| `muted-foreground` | `215 13.8% 34.1%` | `217.9 10.6% 64.9%` | texto auxiliar `gray-600` → `gray-400` |
| `border` | `220 13.0% 91.0%` | `216.9 19.1% 26.7%` | `gray-200` → `gray-700/60`* |
| `input` | `220 13.0% 91.0%` | `216.9 19.1% 26.7%` | borde de formulario `gray-200` → `gray-700/60`* |
| `ring` | `248.4 100% 72.0%` | `248.4 100% 72.0%` | foco y checkbox `violet-500` (el foco usa `/50`) |
| `primary` | `248.4 100% 72.0%` | `248.4 100% 72.0%` | `violet-500` |
| `primary-foreground` | `0 0% 100%` | `0 0% 100%` | texto de controles sólidos |
| `secondary` | `220.9 39.3% 11.0%` | `220 14.3% 95.9%` | control neutro invertido `gray-900` → `gray-100` |
| `destructive` | `0 100% 66.9%` | `0 100% 66.9%` | `red-500` |
| `success` | `142.4 56.3% 51.6%` | `142.4 56.3% 51.6%` | `green-500` |
| `warning` | `43.2 86.3% 57.1%` | `43.2 86.3% 57.1%` | `yellow-500` |

\* Mosaic aplica `gray-700` con 60 % de opacidad al borde oscuro. El token
guarda el color base; el consumidor que deba replicarlo exactamente debe usar
`border-border/60`.

## Tabla de compatibilidad: Mosaic Lite histórico que refleja esta app

Esta es la tabla apropiada si la decisión de producto es respetar literalmente
la recreación `slate`/`indigo` ya presente y evitar cualquier variación en el
modo claro. Los hex de `slate`, `indigo`, `rose`, `emerald` y `amber` proceden
de Tailwind CSS 3.4.1; los pares de utilidades están comprobados en el commit
oficial de Mosaic que añadió dark mode.

| Token | Claro (HSL) | Oscuro (HSL) | Utilidades históricas de Mosaic |
| --- | --- | --- | --- |
| `background` | `210 40% 96.1%` | `222.2 47.4% 11.2%` | `slate-100` → `slate-900` |
| `foreground` | `217.2 32.6% 17.5%` | `210 40% 96.1%` | `slate-800` → `slate-100` |
| `card` | `0 0% 100%` | `217.2 32.6% 17.5%` | `white` → `slate-800` |
| `card-foreground` | `217.2 32.6% 17.5%` | `210 40% 96.1%` | `slate-800` → `slate-100` |
| `muted` | `210 40% 98.0%` | `215.3 25.0% 26.7%` | `slate-50` / `slate-700` (hover usa además `/20`) |
| `muted-foreground` | `215.4 16.3% 46.9%` | `215.0 20.2% 65.1%` | `slate-500` → `slate-400` |
| `border` | `214.3 31.8% 91.4%` | `215.3 25.0% 26.7%` | `slate-200` → `slate-700` |
| `input` | `214.3 31.8% 91.4%` | `215.3 25.0% 26.7%` | `slate-200` → `slate-700` |
| `ring` | `238.7 83.5% 66.7%` | `238.7 83.5% 66.7%` | `indigo-500` (focus usa `/50`) |
| `primary` | `238.7 83.5% 66.7%` | `238.7 83.5% 66.7%` | `indigo-500` |
| `primary-foreground` | `0 0% 100%` | `0 0% 100%` | `white` |
| `secondary` | `210 40% 96.1%` | `215.3 25.0% 26.7%` | superficies neutras `slate-100` / `slate-700` |
| `destructive` | `349.7 89.2% 60.2%` | `349.7 89.2% 60.2%` | `rose-500` |
| `success` | `160.1 84.1% 39.4%` | `160.1 84.1% 39.4%` | `emerald-500` |
| `warning` | `37.7 92.1% 50.2%` | `37.7 92.1% 50.2%` | `amber-500` |

## Evidencia primaria

- [Página oficial de Mosaic](https://cruip.com/mosaic/): confirma que Mosaic es
  un producto de pago y que Cruip ofrece versiones Lite públicas para evaluar
  el código.
- [Repositorio oficial de Mosaic Lite](https://github.com/cruip/tailwind-dashboard-template)
  y su [changelog](https://github.com/cruip/tailwind-dashboard-template/blob/main/CHANGELOG.md):
  el rediseño de Mosaic se publicó en 3.0.0; por ello no se deben mezclar sus
  colores actuales con los de la generación histórica.
- [Paleta actual declarada por Cruip](https://github.com/cruip/tailwind-dashboard-template/blob/main/src/css/style.css#L12-L79):
  define los hex exactos de `gray`, `violet`, `green`, `red` y `yellow` usados
  en la primera tabla.
- [Body del Lite actual](https://github.com/cruip/tailwind-dashboard-template/blob/main/index.html#L17):
  usa `bg-gray-100 dark:bg-gray-900 text-gray-600 dark:text-gray-400`.
- [Tarjeta del dashboard actual](https://github.com/cruip/tailwind-dashboard-template/blob/main/src/partials/dashboard/DashboardCard01.jsx#L76-L104):
  usa `white` → `gray-800`, `gray-800` → `gray-100` y el estado verde.
- [Formularios actuales](https://github.com/cruip/tailwind-dashboard-template/blob/main/src/css/additional-styles/utility-patterns.css):
  documentan el borde `gray-200` → `gray-700/60` y el foco/acento `violet-500`.
- [Commit oficial que añadió dark mode](https://github.com/cruip/tailwind-dashboard-template/commit/d11ddd2b9484899174dadd5dcd52730d9e740e4e):
  base histórica de la segunda tabla.
- [Body histórico](https://github.com/cruip/tailwind-dashboard-template/blob/d11ddd2b9484899174dadd5dcd52730d9e740e4e/index.html#L18):
  prueba `slate-100` → `slate-900` y `slate-600` → `slate-400`.
- [Tarjeta histórica](https://github.com/cruip/tailwind-dashboard-template/blob/d11ddd2b9484899174dadd5dcd52730d9e740e4e/src/partials/dashboard/DashboardCard01.jsx#L76-L104):
  prueba tarjeta, foreground, borde, `rose-500` y `emerald-500`.
- [Formularios históricos](https://github.com/cruip/tailwind-dashboard-template/blob/d11ddd2b9484899174dadd5dcd52730d9e740e4e/src/css/additional-styles/utility-patterns.css#L60-L131):
  prueba input/borde, `indigo-500`, foco y superficies muted.
- [Fuente de colores de Tailwind CSS 3.4.1](https://github.com/tailwindlabs/tailwindcss/blob/v3.4.1/src/public/colors.js):
  valores hex de la tabla histórica; las conversiones a HSL se calcularon
  directamente desde esos hex (redondeo a una decimal).

## Implicación para el spike

Hay una elección explícita antes de codificar tokens:

1. Usar la primera tabla actualiza la app a la apariencia Mosaic vigente
   (`gray`/`violet`) y necesariamente modifica el aspecto claro de los
   componentes tokenizados.
2. Usar la segunda tabla mantiene el lenguaje visual existente
   (`slate`/`indigo`) y satisface la paridad clara exigida por el handoff. Es la
   opción de menor riesgo para este spike, aunque no debe presentarse como la
   paleta de la versión actual.
