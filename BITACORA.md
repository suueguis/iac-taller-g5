# Bitácora — Taller IaC con Terraform

**Curso:** Arquitectura de Software II (2026-2) · Tema VII: Infraestructura como Código
**Grupo:** 5

**Integrantes:**
- Susana Eguis Muñoz
- Samuel Tabares

## Rotación de roles

El grupo es de 2 personas. La guía define cuatro roles y solo prevé fusionarlos para 3 integrantes (Navegante y Bitácora en la misma persona), así que aquí quien no es Operador/a asume los otros tres roles. Ninguna aprobación del plan la da quien teclea: el Operador/a y el Revisor/a son siempre personas distintas.

| Fase | Operador/a | Navegante | Revisor/a del plan | Bitácora |
|---|---|---|---|---|
| 0 y 1 | Susana | Samuel | Samuel | Samuel |
| 2 | Samuel | Susana | Susana | Susana |
| 3 | Susana | Samuel | Samuel | Samuel |
| 4 | Samuel | Susana | Susana | Susana |
| 5 | Susana | Samuel | Samuel | Samuel |
| 6 | Samuel | Susana | Susana | Susana |
| 7 | Susana | Samuel | Samuel | Samuel |
| 8 | Samuel | Susana | Susana | Susana |
| 9 | Susana | Samuel | Samuel | Samuel |

> Regla de la Fase 7: la contraseña del backend nunca se escribe en este archivo ni en ningún archivo del repositorio. En los comandos pegados aquí se reemplaza por `<CLAVE>`.

---

## Fase 0 · Preparación del entorno

**Roles:** Operadora: Susana · Navegante: Samuel · Revisor: Samuel · Bitácora: Samuel

### Evidencias

`terraform -version`
```
Terraform v1.17.0
on windows_amd64

Your version of Terraform is out of date! The latest version
is 1.17.2. You can update by downloading from https://developer.hashicorp.com/terraform/install
```

`docker version`
```
Client:
 Version:           29.0.1
 API version:       1.52
 Go version:        go1.25.4
 Git commit:        eedd969
 Built:             Fri Nov 14 16:19:55 2025
 OS/Arch:           windows/amd64
 Context:           desktop-linux

Server: Docker Desktop 4.53.0 (211793)
 Engine:
  Version:          29.0.1
  API version:      1.52 (minimum version 1.44)
  Go version:       go1.25.4
  Git commit:       198b5e3
  Built:            Fri Nov 14 16:17:57 2025
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          v2.1.5
  GitCommit:        fcd43222d6b07379a4be9786bda52438f0dd16a1
 runc:
  Version:          1.3.3
  GitCommit:        v1.3.3-0-gd842d771
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
```

`git --version`
```
git version 2.45.1.windows.1
```

### Respuestas
_Esta fase no tiene preguntas._

---

## Fase 1 · Arranque: hacerlo a mano

**Roles:** Operadora: Susana · Navegante: Samuel · Revisor: Samuel · Bitácora: Samuel

### Evidencias
> Nota: este equipo tiene otros contenedores personales ajenos al taller. Por eso las salidas de `docker ps` se recortaron a la cabecera y a las filas `clickops` (el resto de filas no se pega; no se tocó ningún otro contenedor).

Primer `docker run`:
```
$ docker run -d --name clickops-g5 -p 8090:80 nginx:1.27-alpine
b7273ff81eb208300cfc200e9b0cde28eae247c59c5befcb8e4c0cf3b16ef617

$ docker ps
CONTAINER ID   IMAGE                COMMAND                  CREATED        STATUS                       PORTS                                         NAMES
b7273ff81eb2   nginx:1.27-alpine    "/docker-entrypoint.…"   1 second ago   Up 1 second                  0.0.0.0:8090->80/tcp, [::]:8090->80/tcp       clickops-g5

$ curl -sI http://localhost:8090
HTTP/1.1 200 OK
Server: nginx/1.27.5
```

Segundo `docker run` (mismo comando, mismo nombre):
```
$ docker run -d --name clickops-g5 -p 8090:80 nginx:1.27-alpine
docker: Error response from daemon: Conflict. The container name "/clickops-g5" is already in use by container "b7273ff81eb208300cfc200e9b0cde28eae247c59c5befcb8e4c0cf3b16ef617". You have to remove (or rename) that container to be able to reuse that name.

Run 'docker run --help' for more information
(código de salida: 125)
```

Intento con otro nombre (`clickops-g5-2`) y el mismo puerto:
```
$ docker run -d --name clickops-g5-2 -p 8090:80 nginx:1.27-alpine
5e0ab5a00605e157625d3346f62f3515b622dc59cf91ccb60097e1c13062ffed
docker: Error response from daemon: failed to set up container networking: driver failed programming external connectivity on endpoint clickops-g5-2 (ed7af4f616dc542b4a91e6b7148d603dff438c4c548991fe9888d0c344e80352): Bind for 0.0.0.0:8090 failed: port is already allocated

Run 'docker run --help' for more information
(código de salida: 125)

$ docker ps -a
CONTAINER ID   IMAGE                COMMAND                  CREATED         STATUS                       PORTS                                         NAMES
5e0ab5a00605   nginx:1.27-alpine    "/docker-entrypoint.…"   2 seconds ago   Created                                                                    clickops-g5-2
b7273ff81eb2   nginx:1.27-alpine    "/docker-entrypoint.…"   4 seconds ago   Up 3 seconds                 0.0.0.0:8090->80/tcp, [::]:8090->80/tcp       clickops-g5
```

Limpieza y `docker ps -a` final (sin contenedores `clickops`):
```
$ docker rm -f clickops-g5 clickops-g5-2
clickops-g5
clickops-g5-2

$ docker ps -a --filter name=clickops
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

**Mismo objetivo de dos formas**

- Lista imperativa de pasos en orden:
- Una sola frase declarativa:

### Respuestas
1. ¿Qué error produjo el segundo `docker run`? ¿Qué dice eso sobre la idempotencia de un comando imperativo?

2. Si otro grupo necesitara mañana un servidor idéntico, ¿qué tendrían que contarle y dónde quedó registrado lo que hicieron?

3. ¿Cuáles de los cuatro puntos de la diapositiva «Por qué duele» vivieron en esta fase?

---

## Fase 2 · Primer despliegue: write → init → plan → apply

### Evidencias
_Pegar: salida de `terraform init`, `terraform plan` (con la línea `Plan:`), `terraform apply`, `terraform output`, `docker ps` y `git status`._

**Aprobación del revisor:** _(ej. «Aprobado: 2 a crear, 0 a cambiar, 0 a destruir»)_

### Respuestas
1. Pidieron un solo servidor. ¿Cuántos recursos creó el plan y por qué?

2. El contenedor usa `docker_image.nginx.image_id`. ¿Qué orden de creación impone esa referencia? Relaciónenlo con la diapositiva «Qué ocurre cuando aplicas».

3. ¿Qué descargó `terraform init`, dónde lo guardó y para qué sirve `.terraform.lock.hcl`?

4. De los cuatro bloques de la diapositiva «Cómo se escribe Terraform», ¿cuál no aparece todavía en su archivo?

5. Comparen con la Fase 1: ¿dónde quedó registrado ahora lo que hicieron?

---

## Fase 3 · Idempotencia y estado

### Evidencias
_Pegar: `terraform apply` sin cambios, `terraform state list`, `terraform state show docker_container.web`, el valor de `serial` antes y después, el plan con `-/+` y `forces replacement`, y el plan final sin cambios._

**Aprobación del revisor:**

### Respuestas
1. ¿Qué respondió Terraform en el paso 1 y en qué se diferencia del segundo `docker run` de la Fase 1?

2. ¿Qué datos guarda el state que no escribieron en `main.tf`? ¿Para qué los necesita Terraform?

3. ¿Por qué el cambio de imagen reemplazó el contenedor en lugar de modificarlo? Relaciónenlo con «Infraestructura mutable vs. inmutable».

4. ¿Cómo cambió `serial` después del `apply` y qué creen que representa?

5. Piensen en un proyecto real con bases de datos: ¿qué riesgo habría si este archivo se subiera a Git?

---

## Fase 4 · Drift: cuando la realidad se desvía

### Evidencias
_Pegar la salida de cada experimento (A, B y C): el `terraform plan` antes de corregir y el resultado después._

**Aprobación del revisor (por experimento):**

### Tabla de drift

| Experimento | ¿El plan lo detectó? | ¿Qué propuso Terraform? | ¿Cómo quedó corregido? |
|---|---|---|---|
| A · Apagar | | | |
| B · Borrar | | | |
| C · Cambiar por dentro | | | |

### Respuestas
1. ¿Por qué Terraform no detectó el experimento C? ¿Qué tipo de herramienta de la diapositiva «Aprovisionar ≠ configurar» se encarga de ese nivel?

2. ¿Por qué `-replace` es una corrección coherente con la infraestructura inmutable?

3. En un equipo real, ¿cómo detectarían el drift sin esperar a que alguien ejecute `plan` por casualidad?

---

## Fase 5 · Las piezas que dan flexibilidad

### Evidencias
_Pegar: salida de `terraform plan` y `apply`, el resultado de `terraform console`, `terraform output`, y los dos `plan` de la validación (puerto 9500 y 8085)._

**Aprobación del revisor:** _(incluir la explicación de por qué el contenedor se reemplaza)_

### Respuestas
1. `puerto` tiene un default, puede venir de `terraform.tfvars` y se pasó con `-var`. ¿Qué valor gana cuando hay varios?

2. ¿Qué hizo el bloque `validation` con el puerto 9500? ¿En qué se parece a la idea de Policy as Code?

3. ¿Terraform creó la red `bridge`? ¿Qué le pasará cuando el grupo ejecute `destroy`?

4. ¿Qué ganan con `local.nombre` frente a escribir `"web-gN"` en cada lugar donde se necesita?

---

## Fase 6 · Módulos: la receta una sola vez

### Evidencias
_Pegar: línea `Plan:` del paso 8, `terraform apply`, `terraform output urls` y `docker ps` con los tres sitios._

**Aprobación del revisor:** _(qué se destruye, qué se crea y por qué)_

### Respuestas
1. Anoten la línea `Plan:` del paso 8. ¿Qué se destruyó, qué se creó y por qué?

2. ¿Qué error obtendrían si el módulo no tuviera `versions.tf`?

3. Si mañana hay que agregar una etiqueta a todos los sitios, ¿cuántos archivos tocan con módulo? ¿Cuántos bloques habrían tocado copiando y pegando?

4. ¿Qué necesitaría otro grupo para usar su módulo sin copiar la carpeta?

---

## Fase 7 · State remoto y varios ambientes

### Evidencias
_Pegar: `terraform init -migrate-state`, `terraform state list`, la consulta a la tabla `states` (antes y después de crear los ambientes), el error de bloqueo de la terminal 2, `terraform workspace list`, y `git grep` de la contraseña (sin resultados). Recuerden: la contraseña va como `<CLAVE>`._

**Aprobación del revisor (por workspace):** _(workspace activo y cuántos sitios se crean)_

### Respuestas
1. ¿Qué respondió la terminal 2 en la prueba de bloqueo? ¿Qué problema de trabajo en equipo evita?

2. ¿Dónde quedó la contraseña del backend y por qué no debe estar en `main.tf`?

3. ¿Qué filas tiene ahora la tabla `states` y cómo se relacionan con los workspaces?

4. ¿Qué error da `terraform plan` en el workspace `default` y por qué es útil que falle?

5. ¿Por qué `dev` tiene un solo sitio y `staging` replica a `prod`? ¿Por qué `prod` usa otra versión de imagen?

6. Los tres ambientes comparten código y backend. ¿Qué riesgo tiene eso frente a usar carpetas separadas por ambiente?

---

## Fase 8 · Testing y calidad

### Evidencias
_Pegar: `terraform fmt -check` y `validate`, `terraform test` (cuatro pruebas aprobadas), los dos escaneos de Checkov o Trivy (antes y después de corregir el bucket), y `bash validar.sh` completo. Anotar también qué se vio en `docker ps` durante `despliegue_real`._

### Respuestas
1. ¿Qué encontró cada nivel (estático, pruebas, seguridad) que los otros no podían encontrar?

2. ¿Qué vio quien observaba `docker ps` durante `despliegue_real`? ¿Por qué vale la pena un entorno desechable?

3. ¿Qué controles fallaron en el bucket y cuántos quedaron después de corregir? ¿Cuáles corresponden al ejemplo «sin buckets públicos» de la clase?

4. ¿Qué ventaja tiene detectar un problema en el código, antes del `apply`, frente a detectarlo en la nube?

5. ¿En qué paso del pipeline de la diapositiva va `validar.sh` y qué paso humano viene después?

---

## Fase 9 · Auditoría cruzada y cierre

### Evidencias
_Pegar: los planes de `destroy` de cada ambiente, `docker ps` con solo `tf-state-g5`, y `docker ps` final sin contenedores. El detalle de la auditoría va en `AUDITORIA.md`._

**Aprobación del revisor (por cada destroy):**

### Respuestas
1. ¿Qué anti-patrón encontraron en el otro grupo? ¿Y cuál les señalaron a ustedes?

2. ¿Qué habría pasado si eliminaban el contenedor del backend antes de ejecutar los `destroy`?

3. ¿Por qué `destroy` exige la misma disciplina de lectura que `apply`?

---

## Declaración de uso de inteligencia artificial

En la realización de este taller se utilizó inteligencia artificial (Claude, de Anthropic) como herramienta de apoyo.
