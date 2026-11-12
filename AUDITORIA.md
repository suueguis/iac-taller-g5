# Auditoría cruzada · Grupo 5 revisa al Grupo 2

**Repositorio auditado:** https://github.com/Sarasaenz12/iac-taller-g2 (rama `main`, último commit `43c4a00`, `fase-8`).
**Quiénes auditamos:** Susana Eguis Muñoz y Samuel Tabares, grupo 5.
**Cómo lo hicimos:** clonamos el repositorio en una carpeta aparte y lo leímos sin modificar nada ni hacer commit allí. No ejecutamos su código: ni `apply`, ni `validar.sh`, ni `terraform test`. Todo lo que sigue sale de leer sus archivos, su `BITACORA.md` y su historial con los comandos de la guía. Donde no pudimos comprobar algo, lo decimos.

## Resultado por anti-patrón

| Anti-patrón | Resultado | Evidencia |
|---|---|---|
| Tocar a mano | **Cumple** | Los `docker` que cambian algo solo aparecen en las fases permitidas: Fase 1 (`BITACORA.md` líneas 122 a 151), Fase 4 (`docker stop` en la 537, `docker rm -f` en la 586 y `docker exec` en la 651) y Fase 7 (`docker run` del backend en la 1188, más `docker exec ... psql` de solo consulta en la 1232 y la 1448). En las fases 2, 3, 5, 6 y 8 no hay ningún comando de Docker que cambie algo; en la Fase 8 solo miran `docker ps` (línea 1589). Tampoco hay `-auto-approve`, `force-unlock`, `taint` ni `state rm`, y el `terraform.tfstate` lo abren solo para leer (línea 425). |
| State sin proteger | **Cumple** | `git log --all --name-only \| grep tfstate` no devolvió nada, ni tampoco ningún `.tfplan` ni carpeta `.terraform/` en el historial. Su `.gitignore` excluye `*.tfstate`, `*.tfstate.*`, `*.tfplan` y `.terraform/`. |
| Copiar y pegar | **Cumple** | `grep -rn --include='*.tf' docker_container infra/` encuentra solo `infra/modules/sitio_web/main.tf:14` (la definición) y `infra/modules/sitio_web/outputs.tf:6` (una referencia al nombre). En la raíz hay un único `module "sitio"` con `for_each` (`infra/main.tf:18` a `26`), no tres bloques repetidos. |
| Secretos en el código | **Cumple, con una reserva** | No encontramos ninguna contraseña real en todo el historial. Lo único con forma de credencial es `POSTGRES_PASSWORD=****` (`BITACORA.md:1188`) y `postgres://terraform:****@...` (`BITACORA.md:1197`), ya enmascarados por ellos, en los commits `838b57d` y `43c4a00`. En los `.tf`, `.tfvars`, `.sh` y `.hcl` no hay nada. Buscamos también `postgres://`, `PG_CONN_STR`, `password` y `clave`. La reserva: su contraseña real no la tenemos, así que no pudimos buscarla literalmente, y ellos mismos invitan a pedirla (línea 1182). No lo hicimos. |
| Aplicar sin leer el plan | **No cumple, en dos puntos** | En casi todos los `apply` y en el `destroy` de `default` hay línea `Plan:` y aprobación del revisor con la cuenta completa (por ejemplo Fase 2, líneas 273 a 280; Fase 3, 459 a 463; Fase 4, 564 a 568, 631 a 636 y 663; Fase 5, 792 a 800; Fase 6, 1029 a 1042 y 1134 a 1136; Fase 7, 1286 a 1319 y los tres ambientes en 1363 a 1436). Las excepciones son el `terraform apply` sin cambios de la Fase 3 (`BITACORA.md:357` a `365`), que no tiene aprobación anotada, y `despliegue_real` de la Fase 8, que crea y destruye un contenedor de verdad y no deja ninguna línea `Plan:` ni aprobación. |
| Un solo archivo gigante | **Cumple** | `infra/` tiene `main.tf`, `variables.tf`, `locals.tf`, `data.tf`, `outputs.tf`, `terraform.tfvars` y el lock; `infra/modules/sitio_web/` tiene `versions.tf`, `variables.tf`, `main.tf`, `outputs.tf` y `tests/`. Ningún `.tf` pasa de 26 líneas. |

## Lo demás que revisamos

- **Un commit por fase.** Hay nueve commits, de `fase-0` a `fase-8`, cada uno con el formato `fase-X: ...` y con los archivos que corresponden a esa fase. Todavía no hay `fase-9` ni `AUDITORIA.md`: la sección de la Fase 9 de su bitácora está vacía (líneas 1776 a 1782). Lo anotamos como pendiente, no como falta.
- **Rotación de roles.** Son tres personas, la tabla (líneas 6 a 22) rota y en las nueve filas el Operador y el Revisor son distintos. Además, los roles que cada fase declara (líneas 26, 116, 198, 351, 529, 725, 914, 1180 y 1537) coinciden con la tabla. Lo que no podemos comprobar es quién hizo cada commit: los nueve salen de la misma cuenta de GitHub, y eso no dice nada de la rotación.
- **Piezas de la Fase 8.** Existen `validar.sh`, `seguridad/bucket.tf` (con los cuatro valores del bloqueo en `true`) y `infra/modules/sitio_web/tests/sitio_web.tftest.hcl` con sus cuatro pruebas.

## Dos hallazgos concretos

**1. Un `apply` real sin aprobación anotada** (`BITACORA.md:357` a `365`, y la Fase 8 completa, líneas 1535 a 1775). En la Fase 3 ejecutan `terraform apply` sin cambios, con la respuesta `No changes`, y no queda registrado quién lo aprobó. En la Fase 8, la prueba `despliegue_real` de `terraform test` hace un `apply` y un `destroy` de verdad, y tampoco tiene su `Plan:` ni su aprobación. En ninguno de los dos casos pasó nada malo, pero la regla de la guía es que nada se aplica sin que el revisor lo apruebe en voz alta, y el que lee la bitácora no puede comprobarlo.

**2. Una nota sobre la contraseña que se contradice con el historial** (`BITACORA.md:1182`). Dice que buscar la contraseña de ejemplo de la guía «siempre dará vacío». Pero el comando de la guía para la fila de secretos (`git log -p -S` con esa contraseña de ejemplo) devuelve el commit `838b57d` sobre `BITACORA.md`, justamente por esa nota, que escribe el literal. Nosotros evitamos repetirlo aquí para no caer en lo mismo. No es una fuga: su contraseña real solo aparece como `****` (líneas 1188 y 1197). Aun así, quien corra la comprobación de la guía verá un resultado donde ellos dicen que no hay ninguno, y hay que entrar a leer para descartar que sea un secreto.

## Recomendación

Que registren, para toda ejecución que cree, cambie o destruya recursos, la línea `Plan: X a crear, Y a cambiar, Z a destruir` y el «Aprobado» del revisor, incluyendo los casos que hoy se les escapan: un `apply` sin cambios y las pruebas de `terraform test` que despliegan de verdad. Les cuesta una línea por ejecución y cierra el único anti-patrón que no cumplen. Para la Fase 9, el mismo cuidado sirve para los tres `terraform destroy`.

## Cosas menores que vimos de pasada

No las contamos como hallazgos. `local.etiquetas` está definido pero no se usa (en su `infra/locals.tf`, líneas 21 a 24); en el nuestro pasa igual (`infra/locals.tf`, líneas 20 a 23). `validar.sh` está guardado sin permiso de ejecución y no tienen `.gitattributes` que fije los saltos de línea de los `.sh` a LF, así que en un clon con CRLF podría romperse. El `host` de Docker para Windows está escrito dentro del código (`infra/main.tf:14` a `16` y la prueba, líneas 1 a 4); funciona, pero deja el repositorio atado a un sistema operativo.
