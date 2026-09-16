# Plan de migración a Rails 8.0.5.1

Fecha: 2026-09-15. Rama: `codex/upgrade-rails-7-to-8`.

## Objetivo y referencia inicial

Actualizar el framework a **Rails 8.0.5.1**, adoptar sus valores por defecto y
mantener los contratos de la aplicación de facturación. El análisis y la revisión
los realiza el modelo de razonamiento avanzado; la implementación de dependencias
y configuración se delega al modelo de ejecución rápida.

La inspección del repositorio confirma:

- `Gemfile` declara `~> 7.2.1`, pero `Gemfile.lock` resuelve **7.2.3.2**.
- Ruby **3.3.12**, Bundler **2.4.10**; Ruby satisface el mínimo 3.2 de Rails 8.
- `config/application.rb` carga valores por defecto de **7.1**, no de 7.2.
- PostgreSQL, Devise 5.0.4, Sprockets, Import Maps, Turbo 1.5, Stimulus 1.3,
  Tailwind 2.3, Simple Form, Pagy 6.2 y Receipts forman la arquitectura actual.
- Minitest es el framework de pruebas instalado: **128 pruebas, 334 aserciones,
  0 fallos, 0 errores, 0 omitidas**, con Rails 7.2.3.2 y dos procesos.
- Hay tres pruebas activas de navegador en `test/system/items_test.rb`. Las tres
  fallan ya en Rails 7 con `NameError: uninitialized constant Rack::Handler`:
  Capybara 3.39.2 no utiliza el servidor compatible con Rack 3. Se requiere 3.40.
- `bundle exec rspec` inicialmente falla porque RSpec no está instalado.
- Jbuilder 2.11.5 usa `ActiveSupport::ProxyObject`, retirado en Rails 8.
- No se han encontrado componentes ni inicialización de Flowbite en el código;
  la interacción existente usa Stimulus y Alpine con su adaptador de Turbo.

## Decisiones de arquitectura

| Área | Decisión | Contrato que se debe verificar |
| --- | --- | --- |
| Framework | Fijar `gem 'rails', '8.0.5.1'` y resolver con `bundle update rails` | Todos los componentes Rails del lockfile tienen esa versión |
| Ruby | Mantener 3.3.12 y las plataformas Darwin/Linux del lockfile | Arranque local y resolución del despliegue Linux |
| Dependencias | Actualizar Jbuilder a una versión sin ProxyObject; ampliar otras actualizaciones solo ante incompatibilidad demostrada | JSON, formularios, autenticación y assets siguen funcionando |
| Valores por defecto | Adoptar `config.load_defaults 8.0`; revisar también los cambios acumulados de 7.2 | Fechas Madrid, renderizado, transacciones y caché mantienen resultados correctos |
| Datos | Mantener PostgreSQL, tablas, índices y restricciones existentes | Numeración por serie, aislamiento de cuentas, rollback y documentos emitidos inmutables |
| Jobs, caché y Cable | Conservar los adaptadores existentes | No aparece dependencia operativa nueva de Solid Queue/Cache/Cable ni Redis |
| Assets | Conservar Sprockets, Import Maps, Tailwind 2.3 y Hotwire actuales | Precompilación, módulos JavaScript y navegación Turbo operativos |
| Autenticación y correo | Conservar Devise, rutas, layouts, credenciales y Postmark en producción | Inicio de sesión real, sesión entre peticiones, correo de prueba sin envíos externos |
| Tests | Añadir RSpec Rails para regresiones de compatibilidad y conservar Minitest | Ambas suites ejecutan pruebas reales; no se acepta una suite vacía |
| Despliegue | Mantener el contrato de Render y sus variables | Arranque en producción, SSL, correo, puerto, hilos y assets conservados |

## Cambios y riesgos concretos

### Dependencias y APIs retiradas

Actualizar Rails a la versión exacta solicitada. Jbuilder es un bloqueo conocido
por su uso de ProxyObject; actualizar la gema, sin crear un parche que restaure
una API retirada. Conservar las versiones bloqueadas de las demás gemas cuando
el resolvedor y las pruebas lo permitan. RSpec Rails es una dependencia de pruebas
necesaria para el comando solicitado; no sustituye ni oculta la suite Minitest.

Buscar APIs retiradas, opciones obsoletas, enums con argumentos incompatibles y
serializaciones antes de atribuir fallos a la lógica de negocio. El código revisado
no utiliza enums ni serializadores personalizados que necesiten una migración.

### Actualización de configuración

Ejecutar `bin/rails app:update` contestando automáticamente con la respuesta por
defecto. Revisar el resultado completo contra Git y reincorporar las opciones
específicas del proyecto que los generadores sustituyan. La aceptación automática
del generador no elimina la necesidad de reconciliar configuración.

Preservar expresamente:

- Módulo `Facturacion`, autoload de `lib`, zona `Madrid`, traducciones estrictas y
  layout de correo de Devise.
- Rutas de facturas, series, onboarding, autenticación, idioma y Letter Opener.
- PostgreSQL y variables de conexión de producción; no modificar migraciones antiguas.
- Sprockets, manifiesto, Import Maps, CSP, assets locales y configuración Tailwind.
- Postmark/Letter Opener, URL pública de Render, SSL y configuración de Puma.
- Adaptadores de almacenamiento, jobs y caché ya utilizados.

Reemplazar `cache_classes` por `enable_reloading` donde proceda. La opción
`action_dispatch.show_exceptions = false` es obsoleta: revisar el comportamiento
real anterior y usar un símbolo admitido; los tests deben distinguir excepciones
propagadas de respuestas HTTP 500 deliberadamente inspeccionadas.

Después de validar las nuevas opciones, cargar los defaults 8.0 y evitar un
initializer temporal que duplique esos mismos valores. Revisar el initializer
7.0 existente, que solo contiene comentarios.

### Valores acumulados 7.2 y 8.0

El código instalado de `railties-8.0.5.1` confirma los cambios acumulados:

- 7.2: YJIT, WebP entre imágenes web de Active Storage, decodificación PostgreSQL
  de fechas y validación de timestamps de migraciones.
- 8.0: `active_support.to_time_preserves_timezone = :zone`,
  `action_dispatch.strict_freshness = true` y `Regexp.timeout ||= 1`.

Con `:zone`, una fecha Madrid debe conservar tanto su instante como sus reglas
de horario de verano. La nueva comprobación de frescura HTTP prioriza ETag
cuando también existe Last-Modified. La aplicación no define `fresh_when` ni
`stale?`; verificar entrega y compilación de assets. Revisar también jobs y sus
transacciones, aunque el árbol de defaults de esta versión ya no configura
`enqueue_after_transaction_commit` como hacía el de 7.2.

### Facturación y compatibilidad funcional

`Invoice#issue!`, `Invoice#assign_number!`, `InvoiceSequence#reserve_next!` y
`InvoiceSeries#create_sequence` son contratos críticos. Deben seguir bloqueando
la fila del contador, numerando correlativamente por usuario/serie y revirtiendo
el contador cuando falla la emisión. Mantener el ADR 0001, las restricciones SQL,
las validaciones de fechas y la inmutabilidad de las facturas emitidas.

Verificar HTML y JSON, descarga PDF, autenticación y sesiones Devise, idioma
español/inglés, formularios inválidos y navegación de ítems con Turbo. Las
regresiones se prueban con la base de datos real y fixtures existentes.

## Secuencia de ejecución

1. Registrar versiones y resultados iniciales; ejecutar también la suite de navegador.
2. Entregar este plan al modelo rápido con propiedad exclusiva de Gemfile,
   lockfile y archivos de configuración/generador. El modelo principal prepara
   RSpec y verifica los contratos funcionales en paralelo sin editar esos archivos.
3. Fijar Rails 8.0.5.1; añadir RSpec Rails y actualizar Jbuilder según necesidad.
   Ejecutar `bundle update rails` y registrar los cambios transitivos del lockfile.
4. Ejecutar `bin/rails app:update` con respuestas por defecto automáticas;
   reconciliar personalizaciones y adoptar defaults 8.0.
5. Arrancar Rails y ejecutar RSpec. Ante cada fallo, identificar su causa, hacer
   el cambio mínimo y repetir. No ignorar deprecaciones ni marcar ejemplos como
   pendientes para obtener un resultado verde.
6. Ejecutar toda la suite Minitest y las pruebas de navegador; corregir las
   incompatibilidades y añadir regresiones cuando el fallo lo justifique.
7. Verificar Zeitwerk, arranque por entornos, assets y diferencias de Git.
8. Registrar resultados finales, archivos modificados y riesgos de despliegue.

## Puertas de aceptación

- `bundle exec rails --version` informa Rails 8.0.5.1.
- Gemfile/lockfile y `config.load_defaults` concuerdan con el objetivo.
- `bundle update rails` y `bin/rails app:update` se han ejecutado realmente.
- `bundle exec rspec` ejecuta ejemplos significativos sin fallos ni pendientes.
- `bin/rails test` ejecuta la suite existente completa sin errores ni omitidos.
- `bin/rails test:system` pasa con un navegador real.
- `bin/rails zeitwerk:check` y la compilación de assets pasan.
- Las configuraciones de desarrollo, pruebas y producción arrancan; las
  comprobaciones de producción no ejecutan migraciones ni envían correos.
- No se debilitan assertions ni se ocultan avisos para simular compatibilidad.
- La revisión final no muestra cambios ajenos a la migración.

## Despliegue y recuperación

Esta tarea deja una rama local verificable. Para desplegar, utilizar el lockfile,
la versión Ruby fijada y el proceso Render existente. No se prevén cambios de
esquema de aplicación: el artefacto anterior permite volver a Rails 7.2.3.2 si una
comprobación de despliegue falla. Conservar secretos y cookies; comprobar login,
facturas/PDF y assets tras desplegar. Si el generador incorpora una migración de
framework, revisar su efecto y reversibilidad antes de considerarla necesaria.

## Fuentes

Consultadas mediante Context7 (`/websites/guides_rubyonrails_v8_0` y
`/rspec/rspec-rails`) y verificadas con las fuentes oficiales:

- [Guía de actualización Rails 8.0](https://guides.rubyonrails.org/v8.0/upgrading_ruby_on_rails.html).
- [Configuración de Rails 8.0](https://guides.rubyonrails.org/v8.0/configuring.html).
- [Notas de Rails 8.0](https://guides.rubyonrails.org/v8.0/8_0_release_notes.html).
- [Rails 8.0.5.1 y requisito de Ruby](https://rubygems.org/gems/rails/versions/8.0.5.1).
- [RSpec Rails: instalación y compatibilidad](https://github.com/rspec/rspec-rails).
- Código instalado de Rails/Jbuilder y archivos del repositorio citados arriba.

## Resultado de ejecución

Completado el 2026-09-15:

- El modelo rápido recibió este plan y ejecutó la actualización de dependencias
  y el generador. El modelo principal reconcilió después cada archivo generado
  con la configuración específica del proyecto.
- `bundle update rails` resolvió todos los componentes del framework a 8.0.5.1.
  También quedaron Jbuilder 2.15.1, Capybara 3.40.0, RSpec Rails 8.0.4 y
  Premailer 1.30.0. La actualización de Premailer eliminó las advertencias de
  argumentos posicionales observadas con Nokogiri.
- `bin/rails app:update` se ejecutó con las respuestas por defecto aceptadas
  automáticamente; su salida está en `tmp/rails8-app-update.log`. Se conservaron
  Postmark, el dominio de Render, Sprockets, Tailwind/Foreman y Puma.
- Se adoptó `config.load_defaults 8.0` y se eliminó el initializer 7.0, que solo
  contenía comentarios. Las deprecaciones de Rails hacen fallar el entorno test.
- `bundle exec rspec`: **13 ejemplos, 0 fallos**. Cubre autenticación/sesión,
  HTML/JSON/PDF, Turbo Streams, localización, fechas PostgreSQL/Madrid, correo y
  atomicidad de la numeración de facturas.
- `bin/rails test`: **128 pruebas, 335 aserciones, 0 fallos, 0 errores, 0 omitidas**.
- `bin/rails test:system`: **4 pruebas, 11 aserciones, 0 fallos, 0 errores,
  0 omitidas**, con Chrome, Puma y una navegación Turbo verificada en el navegador.
- `bundle exec rails zeitwerk:check`: correcto; solo informa que el directorio
  estándar de previews de correo no está en eager load.
- Arranque de producción verificado: Rails 8.0.5.1, dominio
  `invoicing-rails.onrender.com` y adaptador Postmark.
- `bundle exec rails assets:precompile`, `bundle check` y `git diff --check`:
  correctos. RuboCop no detecta infracciones en los nuevos specs ni en la
  configuración modificada revisada.

Quedan dos avisos informativos que ya existían o no representan deprecaciones de
Rails: la base local de Browserslist incluida en el toolchain Tailwind está
desactualizada y Prawn avisa de la cobertura Unicode limitada de sus fuentes PDF
integradas. La generación PDF fue ejercitada satisfactoriamente.
