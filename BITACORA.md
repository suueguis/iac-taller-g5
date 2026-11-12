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

**Roles:** Operador: Samuel · Navegante: Susana · Revisora: Susana · Bitácora: Susana

### Evidencias
`infra/main.tf` copiado de `material-por-fase/fase-2/infra/main.tf` sin cambios. `terraform fmt -check` y `terraform validate` pasaron sin errores.

`terraform init`
```
Initializing the backend...

Initializing provider plugins...
- Finding kreuzwerker/docker versions matching "~> 4.6"...
- Installing kreuzwerker/docker v4.7.0...
- Installed kreuzwerker/docker v4.7.0 (self-signed, key ID 0DCE698927DAF8EC)
Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://developer.hashicorp.com/terraform/cli/plugins/signing

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

`terraform plan -out=fase2.tfplan`
```
Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # docker_container.web will be created
  + resource "docker_container" "web" {
      + attach                                      = false
      + bridge                                      = (known after apply)
      + command                                     = (known after apply)
      + container_logs                              = (known after apply)
      + container_read_refresh_timeout_milliseconds = 15000
      + entrypoint                                  = (known after apply)
      + env                                         = (known after apply)
      + exit_code                                   = (known after apply)
      + hostname                                    = (known after apply)
      + id                                          = (known after apply)
      + image                                       = (known after apply)
      + init                                        = (known after apply)
      + ipc_mode                                    = (known after apply)
      + log_driver                                  = (known after apply)
      + logs                                        = false
      + memory_reservation                          = 0
      + must_run                                    = true
      + name                                        = "web-g5"
      + network_data                                = (known after apply)
      + network_mode                                = "bridge"
      + platform                                    = (known after apply)
      + read_only                                   = false
      + remove_volumes                              = true
      + restart                                     = "no"
      + rm                                          = false
      + runtime                                     = (known after apply)
      + security_opts                               = (known after apply)
      + shm_size                                    = (known after apply)
      + start                                       = true
      + stdin_open                                  = false
      + stop_signal                                 = (known after apply)
      + stop_timeout                                = (known after apply)
      + tty                                         = false
      + wait                                        = false
      + wait_timeout                                = 60

      + healthcheck (known after apply)

      + labels (known after apply)

      + ports {
          + external = 8080
          + internal = 80
          + ip       = "0.0.0.0"
          + protocol = "tcp"
        }
    }

  # docker_image.nginx will be created
  + resource "docker_image" "nginx" {
      + id           = (known after apply)
      + image_id     = (known after apply)
      + keep_locally = true
      + name         = "nginx:1.27-alpine"
      + repo_digest  = (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + url = "http://localhost:8080"

─────────────────────────────────────────────────────────────────────────────

Saved the plan to: fase2.tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "fase2.tfplan"
```

`terraform apply "fase2.tfplan"`
```
docker_image.nginx: Creating...
docker_image.nginx: Creation complete after 1s [id=sha256:65645c7bb6a0661892a8b03b89d0743208a18dd2f3f17a54ef4b76fb8e2f2a10nginx:1.27-alpine]
docker_container.web: Creating...
docker_container.web: Creation complete after 2s [id=162bfac4bf4cd1b076ca8423e79f2069f149e5b10131e658718600246840e3a6]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

url = "http://localhost:8080"
```

`terraform output`
```
url = "http://localhost:8080"
```

`docker ps --filter name=g5` (recortado a los contenedores del taller)
```
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS        PORTS                  NAMES
162bfac4bf4c   65645c7bb6a0   "/docker-entrypoint.…"   2 seconds ago   Up 1 second   0.0.0.0:8080->80/tcp   web-g5
```

`curl -sI http://localhost:8080 | head -2`
```
HTTP/1.1 200 OK
Server: nginx/1.27.5
```

`git status` (antes del commit; `.terraform/` y `fase2.tfplan` no aparecen porque `.gitignore` los excluye, y `.terraform.lock.hcl` sí se sube)
```
On branch main
Your branch is up to date with 'origin/main'.

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	infra/.terraform.lock.hcl
	infra/main.tf

nothing added to commit but untracked files present (use "git add" to track)
```

**Aprobación del revisor:** Aprobado (Revisora Susana): Plan: 2 a crear, 0 a cambiar, 0 a destruir.

### Respuestas
1. Pidieron un solo servidor. ¿Cuántos recursos creó el plan y por qué?

2. El contenedor usa `docker_image.nginx.image_id`. ¿Qué orden de creación impone esa referencia? Relaciónenlo con la diapositiva «Qué ocurre cuando aplicas».

3. ¿Qué descargó `terraform init`, dónde lo guardó y para qué sirve `.terraform.lock.hcl`?

4. De los cuatro bloques de la diapositiva «Cómo se escribe Terraform», ¿cuál no aparece todavía en su archivo?

5. Comparen con la Fase 1: ¿dónde quedó registrado ahora lo que hicieron?

---

## Fase 3 · Idempotencia y estado

**Roles:** Operadora: Susana · Navegante: Samuel · Revisor: Samuel · Bitácora: Samuel

### Evidencias
`terraform plan` (sin cambios) y `terraform apply` sin cambios
```
$ terraform plan
docker_image.nginx: Refreshing state... [id=sha256:65645c7bb6a0661892a8b03b89d0743208a18dd2f3f17a54ef4b76fb8e2f2a10nginx:1.27-alpine]
docker_container.web: Refreshing state... [id=162bfac4bf4cd1b076ca8423e79f2069f149e5b10131e658718600246840e3a6]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration
and found no differences, so no changes are needed.

$ terraform apply
docker_image.nginx: Refreshing state... [id=sha256:65645c7bb6a0661892a8b03b89d0743208a18dd2f3f17a54ef4b76fb8e2f2a10nginx:1.27-alpine]
docker_container.web: Refreshing state... [id=162bfac4bf4cd1b076ca8423e79f2069f149e5b10131e658718600246840e3a6]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration
and found no differences, so no changes are needed.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

url = "http://localhost:8080"
```

`terraform state list` y `terraform state show docker_container.web`
```
$ terraform state list
docker_container.web
docker_image.nginx

$ terraform state show docker_container.web
# docker_container.web:
resource "docker_container" "web" {
    attach                                      = false
    bridge                                      = null
    command                                     = [
        "nginx",
        "-g",
        "daemon off;",
    ]
    container_read_refresh_timeout_milliseconds = 15000
    cpu_set                                     = null
    cpu_shares                                  = 0
    domainname                                  = null
    entrypoint                                  = [
        "/docker-entrypoint.sh",
    ]
    env                                         = []
    hostname                                    = "162bfac4bf4c"
    id                                          = "162bfac4bf4cd1b076ca8423e79f2069f149e5b10131e658718600246840e3a6"
    image                                       = "sha256:65645c7bb6a0661892a8b03b89d0743208a18dd2f3f17a54ef4b76fb8e2f2a10"
    init                                        = false
    ipc_mode                                    = "private"
    log_driver                                  = "json-file"
    logs                                        = false
    max_retry_count                             = 0
    memory                                      = 0
    memory_reservation                          = 0
    memory_swap                                 = 0
    must_run                                    = true
    name                                        = "web-g5"
    network_data                                = [
        {
            gateway                   = "172.17.0.1"
            global_ipv6_address       = null
            global_ipv6_prefix_length = 0
            ip_address                = "172.17.0.3"
            ip_prefix_length          = 16
            ipv6_gateway              = null
            mac_address               = "c6:59:1c:b3:a5:31"
            network_name              = "bridge"
        },
    ]
    network_mode                                = "bridge"
    platform                                    = "linux"
    privileged                                  = false
    publish_all_ports                           = false
    read_only                                   = false
    remove_volumes                              = true
    restart                                     = "no"
    rm                                          = false
    runtime                                     = "runc"
    security_opts                               = []
    shm_size                                    = 64
    start                                       = true
    stdin_open                                  = false
    stop_signal                                 = "SIGQUIT"
    stop_timeout                                = 1
    tty                                         = false
    user                                        = null
    userns_mode                                 = null
    wait                                        = false
    wait_timeout                                = 60
    working_dir                                 = "/"

    ports {
        external = 8080
        internal = 80
        ip       = "0.0.0.0"
        protocol = "tcp"
    }
}
```

Valor de `serial` (en `terraform.tfstate`)
```
Antes de cualquier apply de esta fase (tras la Fase 2):  "serial": 3
Después del apply sin cambios:                           "serial": 4
Después del apply con el cambio de imagen:               "serial": 9
```

Cambio hecho a mano en `infra/main.tf`
```diff
 resource "docker_image" "nginx" {
-  name         = "nginx:1.27-alpine"
+  name         = "nginx:1.28-alpine"
   keep_locally = true
 }
```

`terraform plan -out=fase3.tfplan` (con `-/+` y `forces replacement`)
```
docker_image.nginx: Refreshing state... [id=sha256:65645c7bb6a0661892a8b03b89d0743208a18dd2f3f17a54ef4b76fb8e2f2a10nginx:1.27-alpine]
docker_container.web: Refreshing state... [id=162bfac4bf4cd1b076ca8423e79f2069f149e5b10131e658718600246840e3a6]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # docker_container.web must be replaced
-/+ resource "docker_container" "web" {
      + bridge                                      = (known after apply)
      ~ command                                     = [
          - "nginx",
          - "-g",
          - "daemon off;",
        ] -> (known after apply)
      + container_logs                              = (known after apply)
      - cpu_shares                                  = 0 -> null
      - device_cgroup_rules                         = [] -> null
      - dns                                         = [] -> null
      - dns_opts                                    = [] -> null
      - dns_search                                  = [] -> null
      ~ entrypoint                                  = [
          - "/docker-entrypoint.sh",
        ] -> (known after apply)
      ~ env                                         = [] -> (known after apply)
      + exit_code                                   = (known after apply)
      - group_add                                   = [] -> null
      ~ hostname                                    = "162bfac4bf4c" -> (known after apply)
      ~ id                                          = "162bfac4bf4cd1b076ca8423e79f2069f149e5b10131e658718600246840e3a6" -> (known after apply)
      ~ image                                       = "sha256:65645c7bb6a0661892a8b03b89d0743208a18dd2f3f17a54ef4b76fb8e2f2a10" -> (known after apply) # forces replacement
      ~ init                                        = false -> (known after apply)
      ~ ipc_mode                                    = "private" -> (known after apply)
      ~ log_driver                                  = "json-file" -> (known after apply)
      - log_opts                                    = {} -> null
      - max_retry_count                             = 0 -> null
      - memory                                      = 0 -> null
      - memory_swap                                 = 0 -> null
        name                                        = "web-g5"
      ~ network_data                                = [
          - {
              - gateway                   = "172.17.0.1"
              - global_ipv6_prefix_length = 0
              - ip_address                = "172.17.0.3"
              - ip_prefix_length          = 16
              - mac_address               = "c6:59:1c:b3:a5:31"
              - network_name              = "bridge"
                # (2 unchanged attributes hidden)
            },
        ] -> (known after apply)
      ~ platform                                    = "linux" -> (known after apply)
      - privileged                                  = false -> null
      - publish_all_ports                           = false -> null
      ~ runtime                                     = "runc" -> (known after apply)
      ~ security_opts                               = [] -> (known after apply)
      ~ shm_size                                    = 64 -> (known after apply)
      ~ stop_signal                                 = "SIGQUIT" -> (known after apply)
      ~ stop_timeout                                = 1 -> (known after apply)
      - storage_opts                                = {} -> null
      - sysctls                                     = {} -> null
      - tmpfs                                       = {} -> null
      - working_dir                                 = "/" -> null
        # (19 unchanged attributes hidden)

      ~ healthcheck (known after apply)

      ~ labels (known after apply)

        # (1 unchanged block hidden)
    }

  # docker_image.nginx must be replaced
-/+ resource "docker_image" "nginx" {
      ~ id           = "sha256:65645c7bb6a0661892a8b03b89d0743208a18dd2f3f17a54ef4b76fb8e2f2a10nginx:1.27-alpine" -> (known after apply)
      ~ image_id     = "sha256:65645c7bb6a0661892a8b03b89d0743208a18dd2f3f17a54ef4b76fb8e2f2a10" -> (known after apply)
      ~ name         = "nginx:1.27-alpine" -> "nginx:1.28-alpine" # forces replacement
      ~ repo_digest  = "nginx@sha256:65645c7bb6a0661892a8b03b89d0743208a18dd2f3f17a54ef4b76fb8e2f2a10" -> (known after apply)
        # (1 unchanged attribute hidden)
    }

Plan: 2 to add, 0 to change, 2 to destroy.

─────────────────────────────────────────────────────────────────────────────

Saved the plan to: fase3.tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "fase3.tfplan"
```

`terraform apply "fase3.tfplan"`, plan final y comprobación
```
$ terraform apply fase3.tfplan
docker_container.web: Destroying... [id=162bfac4bf4cd1b076ca8423e79f2069f149e5b10131e658718600246840e3a6]
docker_container.web: Destruction complete after 1s
docker_image.nginx: Destroying... [id=sha256:65645c7bb6a0661892a8b03b89d0743208a18dd2f3f17a54ef4b76fb8e2f2a10nginx:1.27-alpine]
docker_image.nginx: Destruction complete after 0s
docker_image.nginx: Creating...
docker_image.nginx: Creation complete after 1s [id=sha256:a8b39bd9cf0f83869a2162827a0caf6137ddf759d50a171451b335cecc87d236nginx:1.28-alpine]
docker_container.web: Creating...
docker_container.web: Creation complete after 1s [id=5c761c1e3fbb2dba0bc75dbe0fdff476f49b698539dc3ab0501aa5e366a8599e]

Apply complete! Resources: 2 added, 0 changed, 2 destroyed.

Outputs:

url = "http://localhost:8080"

$ terraform plan
docker_image.nginx: Refreshing state... [id=sha256:a8b39bd9cf0f83869a2162827a0caf6137ddf759d50a171451b335cecc87d236nginx:1.28-alpine]
docker_container.web: Refreshing state... [id=5c761c1e3fbb2dba0bc75dbe0fdff476f49b698539dc3ab0501aa5e366a8599e]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration
and found no differences, so no changes are needed.

$ docker ps --filter name=g5
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                  NAMES
5c761c1e3fbb   a8b39bd9cf0f   "/docker-entrypoint.…"   3 seconds ago   Up 2 seconds   0.0.0.0:8080->80/tcp   web-g5

$ curl -sI http://localhost:8080 | head -2
HTTP/1.1 200 OK
Server: nginx/1.28.3
```

**Aprobación del revisor:**
- Apply sin cambios — Aprobado (Revisor Samuel): 0 a crear, 0 a cambiar, 0 a destruir.
- Cambio de imagen a 1.28 — Aprobado (Revisor Samuel): Plan: 2 a crear, 0 a cambiar, 2 a destruir.

### Respuestas
1. ¿Qué respondió Terraform en el paso 1 y en qué se diferencia del segundo `docker run` de la Fase 1?

2. ¿Qué datos guarda el state que no escribieron en `main.tf`? ¿Para qué los necesita Terraform?

3. ¿Por qué el cambio de imagen reemplazó el contenedor en lugar de modificarlo? Relaciónenlo con «Infraestructura mutable vs. inmutable».

4. ¿Cómo cambió `serial` después del `apply` y qué creen que representa?

5. Piensen en un proyecto real con bases de datos: ¿qué riesgo habría si este archivo se subiera a Git?

---

## Fase 4 · Drift: cuando la realidad se desvía

**Roles:** Operador: Samuel · Navegante: Susana · Revisora: Susana · Bitácora: Susana

### Evidencias
> Nota: en los planes largos se recortaron con `[...]` las líneas de atributos calculados (`(known after apply)`, `-> null`) para que la bitácora sea legible; las líneas que importan para cada experimento (`must_run`, `forces replacement`, `Plan:`) se conservan tal cual salieron.

#### Experimento A · Apagar el contenedor

```
$ docker stop web-g5
web-g5

$ docker ps -a --filter name=g5
CONTAINER ID   IMAGE          COMMAND                  CREATED              STATUS                              PORTS     NAMES
5c761c1e3fbb   a8b39bd9cf0f   "/docker-entrypoint.…"   About a minute ago   Exited (0) Less than a second ago             web-g5

$ terraform plan -out=fase4a.tfplan
docker_image.nginx: Refreshing state... [id=sha256:a8b39bd9cf0f83869a2162827a0caf6137ddf759d50a171451b335cecc87d236nginx:1.28-alpine]
docker_container.web: Refreshing state... [id=5c761c1e3fbb2dba0bc75dbe0fdff476f49b698539dc3ab0501aa5e366a8599e]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # docker_container.web must be replaced
-/+ resource "docker_container" "web" {
      [...]
      ~ exit_code                                   = 0 -> (known after apply)
      [...]
      ~ must_run                                    = false -> true
        name                                        = "web-g5"
      [...]
      + ports { # forces replacement
          + external = 8080 # forces replacement
          + internal = 80 # forces replacement
          + ip       = "0.0.0.0" # forces replacement
          + protocol = "tcp" # forces replacement
        }
    }

Plan: 1 to add, 0 to change, 1 to destroy.
```

Corrección:
```
$ terraform apply fase4a.tfplan
docker_container.web: Destroying... [id=5c761c1e3fbb2dba0bc75dbe0fdff476f49b698539dc3ab0501aa5e366a8599e]
docker_container.web: Destruction complete after 0s
docker_container.web: Creating...
docker_container.web: Creation complete after 1s [id=b2659048374fabe7f6d582d6bfc867a1bb42b9ffb92fe2ab8d64840b5fbe8937]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.

Outputs:

url = "http://localhost:8080"

$ docker ps --filter name=g5
CONTAINER ID   IMAGE          COMMAND                  CREATED        STATUS                  PORTS                  NAMES
b2659048374f   a8b39bd9cf0f   "/docker-entrypoint.…"   1 second ago   Up Less than a second   0.0.0.0:8080->80/tcp   web-g5

$ curl -sI http://localhost:8080 | head -2
HTTP/1.1 200 OK
Server: nginx/1.28.3

$ terraform plan
No changes. Your infrastructure matches the configuration.
```

#### Experimento B · Borrar el contenedor

```
$ docker rm -f web-g5
web-g5

$ docker ps -a --filter name=g5
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

$ terraform plan -refresh-only
docker_image.nginx: Refreshing state... [id=sha256:a8b39bd9cf0f83869a2162827a0caf6137ddf759d50a171451b335cecc87d236nginx:1.28-alpine]
docker_container.web: Refreshing state... [id=b2659048374fabe7f6d582d6bfc867a1bb42b9ffb92fe2ab8d64840b5fbe8937]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the
last "terraform apply" which may have affected this plan:

  # docker_container.web has been deleted
  - resource "docker_container" "web" {
      [...]
      - name                                        = "web-g5" -> null
      [...]
      - ports {
          - external = 8080 -> null
          - internal = 80 -> null
          - ip       = "0.0.0.0" -> null
          - protocol = "tcp" -> null
        }
    }


This is a refresh-only plan, so Terraform will not take any actions to undo
these. If you were expecting these changes then you can apply this plan to
record the updated values in the Terraform state without changing any remote
objects.

$ terraform plan -out=fase4b.tfplan
[...]
Terraform will perform the following actions:

  # docker_container.web will be created
  + resource "docker_container" "web" {
      [...]
      + image                                       = "sha256:a8b39bd9cf0f83869a2162827a0caf6137ddf759d50a171451b335cecc87d236"
      [...]
      + name                                        = "web-g5"
      [...]
      + ports {
          + external = 8080
          + internal = 80
          + ip       = "0.0.0.0"
          + protocol = "tcp"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

Corrección:
```
$ terraform apply fase4b.tfplan
docker_container.web: Creating...
docker_container.web: Creation complete after 1s [id=8d7d69643789a473dc29007ae1abb6a5fe04b296f3a389259c581105650842a8]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

url = "http://localhost:8080"

$ docker ps --filter name=g5
CONTAINER ID   IMAGE          COMMAND                  CREATED        STATUS                  PORTS                  NAMES
8d7d69643789   a8b39bd9cf0f   "/docker-entrypoint.…"   1 second ago   Up Less than a second   0.0.0.0:8080->80/tcp   web-g5

$ curl -sI http://localhost:8080 | head -2
HTTP/1.1 200 OK
Server: nginx/1.28.3

$ terraform plan
No changes. Your infrastructure matches the configuration.
```

#### Experimento C · Cambiar por dentro

```
$ curl -s http://localhost:8080 | head -5   (antes)
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>

$ MSYS_NO_PATHCONV=1 docker exec web-g5 sh -c 'echo "<h1>Modificado a mano - g5</h1>" > /usr/share/nginx/html/index.html'

$ curl -s http://localhost:8080   (después)
<h1>Modificado a mano - g5</h1>

$ terraform plan
docker_image.nginx: Refreshing state... [id=sha256:a8b39bd9cf0f83869a2162827a0caf6137ddf759d50a171451b335cecc87d236nginx:1.28-alpine]
docker_container.web: Refreshing state... [id=8d7d69643789a473dc29007ae1abb6a5fe04b296f3a389259c581105650842a8]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration
and found no differences, so no changes are needed.

$ terraform plan -replace=docker_container.web -out=fase4c.tfplan
[...]
Terraform will perform the following actions:

  # docker_container.web will be replaced, as requested
-/+ resource "docker_container" "web" {
      [...]
        name                                        = "web-g5"
      [...]
    }

Plan: 1 to add, 0 to change, 1 to destroy.
```

Corrección:
```
$ terraform apply fase4c.tfplan
docker_container.web: Destroying... [id=8d7d69643789a473dc29007ae1abb6a5fe04b296f3a389259c581105650842a8]
docker_container.web: Destruction complete after 0s
docker_container.web: Creating...
docker_container.web: Creation complete after 1s [id=962d621ba780b595488336b53a97afb982520630463657d743ed7223638c097c]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.

Outputs:

url = "http://localhost:8080"

$ docker ps --filter name=g5
CONTAINER ID   IMAGE          COMMAND                  CREATED        STATUS                  PORTS                  NAMES
962d621ba780   a8b39bd9cf0f   "/docker-entrypoint.…"   1 second ago   Up Less than a second   0.0.0.0:8080->80/tcp   web-g5

$ curl -s http://localhost:8080 | head -5
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>

$ terraform plan
No changes. Your infrastructure matches the configuration.
```

**Aprobación del revisor (por experimento):**
- A — Aprobado (Revisora Susana): Plan: 1 a crear, 0 a cambiar, 1 a destruir.
- B — Aprobado (Revisora Susana): Plan: 1 a crear, 0 a cambiar, 0 a destruir.
- C — Aprobado (Revisora Susana): Plan: 1 a crear, 0 a cambiar, 1 a destruir (con `-replace=docker_container.web`).

### Tabla de drift

| Experimento | ¿El plan lo detectó? | ¿Qué propuso Terraform? | ¿Cómo quedó corregido? |
|---|---|---|---|
| A · Apagar | Sí: `must_run = false -> true` y `exit_code = 0` (el contenedor existía pero estaba apagado) | Reemplazar el contenedor (`-/+`, `forces replacement` en `ports`): `Plan: 1 to add, 0 to change, 1 to destroy` | `terraform apply fase4a.tfplan`: contenedor recreado, `docker ps` lo muestra `Up` y `curl` responde `200 OK` |
| B · Borrar | Sí: `docker_container.web has been deleted` (con `plan -refresh-only` solo informa; con `plan` propone volver) | Crear de nuevo el contenedor: `Plan: 1 to add, 0 to change, 0 to destroy` | `terraform apply fase4b.tfplan`: contenedor creado, `curl` responde `200 OK` |
| C · Cambiar por dentro | No: `terraform plan` dijo `No changes` aunque `curl` ya mostraba otra página | Nada con `plan` normal. Con `-replace=docker_container.web`: `Plan: 1 to add, 0 to change, 1 to destroy` | `terraform apply fase4c.tfplan`: contenedor recreado y `curl` volvió a mostrar «Welcome to nginx!» |

### Respuestas
1. ¿Por qué Terraform no detectó el experimento C? ¿Qué tipo de herramienta de la diapositiva «Aprovisionar ≠ configurar» se encarga de ese nivel?

2. ¿Por qué `-replace` es una corrección coherente con la infraestructura inmutable?

3. En un equipo real, ¿cómo detectarían el drift sin esperar a que alguien ejecute `plan` por casualidad?

---

## Fase 5 · Las piezas que dan flexibilidad

**Roles:** Operadora: Susana · Navegante: Samuel · Revisor: Samuel · Bitácora: Samuel

### Evidencias
Se copió todo `material-por-fase/fase-5/infra/` a `infra/`: reemplaza `main.tf` y agrega `variables.tf`, `locals.tf`, `data.tf`, `outputs.tf` y `terraform.tfvars` (`grupo = 5`). `terraform fmt -check` y `terraform validate` pasaron sin tocar el HCL.

`terraform plan -out=fase5.tfplan`
```
docker_image.nginx: Refreshing state... [id=sha256:a8b39bd9cf0f83869a2162827a0caf6137ddf759d50a171451b335cecc87d236nginx:1.28-alpine]
data.docker_network.bridge: Reading...
data.docker_network.bridge: Read complete after 0s [id=2bd15f0293fc4780a4c3e7a76cafb9c5f5cf1b84d2a57a48ff51de06fd017fa3]
docker_container.web: Refreshing state... [id=962d621ba780b595488336b53a97afb982520630463657d743ed7223638c097c]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # docker_container.web must be replaced
-/+ resource "docker_container" "web" {
      [...]
        name                                        = "web-g5"
      [...]
      ~ healthcheck (known after apply)

      + labels { # forces replacement
          + label = "curso"
          + value = "arquitectura-sw-2"
        }
      + labels { # forces replacement
          + label = "grupo"
          + value = "5"
        }

      + upload { # forces replacement
          + content        = <<-EOT
                <h1>Hola desde el grupo 5</h1>
                <p>Desplegado con Terraform por el grupo 5</p>
            EOT
          + executable     = false
          + file           = "/usr/share/nginx/html/index.html"
            # (6 unchanged attributes hidden)
        }

        # (1 unchanged block hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.

Changes to Outputs:
  + contenedor = "web-g5"
  + red_driver = "bridge"
```
(Se recortaron con `[...]` las líneas de atributos calculados del contenedor, como en la Fase 4.)

`terraform apply "fase5.tfplan"`, comprobaciones y salidas
```
$ terraform apply fase5.tfplan
docker_container.web: Destroying... [id=962d621ba780b595488336b53a97afb982520630463657d743ed7223638c097c]
docker_container.web: Destruction complete after 1s
docker_container.web: Creating...
docker_container.web: Creation complete after 1s [id=0d30e8177c96923becacc08156da287fa3464b2dc6370d2758bbbb0bedeaf58a]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.

Outputs:

contenedor = "web-g5"
red_driver = "bridge"
url = "http://localhost:8080"

$ docker ps --filter name=g5
CONTAINER ID   IMAGE          COMMAND                  CREATED        STATUS                  PORTS                  NAMES
0d30e8177c96   a8b39bd9cf0f   "/docker-entrypoint.…"   1 second ago   Up Less than a second   0.0.0.0:8080->80/tcp   web-g5

$ curl -s http://localhost:8080
<h1>Hola desde el grupo 5</h1>
<p>Desplegado con Terraform por el grupo 5</p>

$ docker inspect web-g5 --format "{{json .Config.Labels}}"
{"curso":"arquitectura-sw-2","grupo":"5","maintainer":"NGINX Docker Maintainers <docker-maint@nginx.com>"}

$ terraform output
contenedor = "web-g5"
red_driver = "bridge"
url = "http://localhost:8080"

$ terraform plan
No changes. Your infrastructure matches the configuration.
```

`terraform console` (una expresión por vez)
```
> local.nombre
"web-g5"
> local.etiquetas
{
  "curso" = "arquitectura-sw-2"
  "grupo" = "5"
}
> var.puerto
8080
> var.imagen
"nginx:1.28-alpine"
> data.docker_network.bridge.driver
"bridge"
```

Validación del puerto: `terraform plan -var="puerto=9500"` (falla)
```
data.docker_network.bridge: Reading...
docker_image.nginx: Refreshing state... [id=sha256:a8b39bd9cf0f83869a2162827a0caf6137ddf759d50a171451b335cecc87d236nginx:1.28-alpine]
data.docker_network.bridge: Read complete after 0s [id=2bd15f0293fc4780a4c3e7a76cafb9c5f5cf1b84d2a57a48ff51de06fd017fa3]

Planning failed. Terraform encountered an error while generating this plan.


Error: Invalid value for variable

  on variables.tf line 6:
   6: variable "puerto" {
    ├────────────────
    │ var.puerto is 9500

El puerto debe estar entre 8000 y 8999.

This was checked by the validation rule at variables.tf:11,3-13.
(código de salida: 1)
```

Validación del puerto: `terraform plan -var="puerto=8085"` (solo `plan`, no se aplicó; salida filtrada con `grep` a las líneas relevantes)
```
          ~ external = 8080 -> 8085 # forces replacement
Plan: 1 to add, 0 to change, 1 to destroy.
Changes to Outputs:
  ~ url        = "http://localhost:8080" -> "http://localhost:8085"
```

**Aprobación del revisor:** Aprobado (Revisor Samuel): Plan: 1 a crear, 0 a cambiar, 1 a destruir. El contenedor se reemplaza (no se modifica) porque los bloques nuevos `labels` y `upload` figuran como `forces replacement`: el provider no puede cambiar esos atributos en un contenedor ya creado, así que lo destruye y crea otro con el mismo nombre y puerto.

### Respuestas
1. `puerto` tiene un default, puede venir de `terraform.tfvars` y se pasó con `-var`. ¿Qué valor gana cuando hay varios?

2. ¿Qué hizo el bloque `validation` con el puerto 9500? ¿En qué se parece a la idea de Policy as Code?

3. ¿Terraform creó la red `bridge`? ¿Qué le pasará cuando el grupo ejecute `destroy`?

4. ¿Qué ganan con `local.nombre` frente a escribir `"web-gN"` en cada lugar donde se necesita?

---

## Fase 6 · Módulos: la receta una sola vez

**Roles:** Operador: Samuel · Navegante: Susana · Revisora: Susana · Bitácora: Susana

### Evidencias
Se copió todo `material-por-fase/fase-6/infra/` a `infra/` (incluye `modules/sitio_web/` con su `versions.tf`). `terraform init`, `terraform fmt -check -recursive` y `terraform validate` pasaron sin tocar el HCL.

`terraform init`
```
Initializing the backend...

Initializing modules...
- blog in modules\sitio_web
- tienda in modules\sitio_web
- docs in modules\sitio_web

Initializing provider plugins...
- Reusing version 4.7.0 of kreuzwerker/docker from the dependency lock file
- Using previously-installed kreuzwerker/docker v4.7.0

Terraform has been successfully initialized!
```
(Se recortó el texto de ayuda final de `init`.)

`terraform plan -out=fase6.tfplan` (se recortaron con `[...]` las líneas de atributos calculados del contenedor que se destruye)
```
Terraform will perform the following actions:

  # docker_container.web will be destroyed
  # (because docker_container.web is not in configuration)
  - resource "docker_container" "web" {
      [...]
      - name                                        = "web-g5" -> null
      [...]
      - ports {
          - external = 8080 -> null
          - internal = 80 -> null
          - ip       = "0.0.0.0" -> null
          - protocol = "tcp" -> null
        }
      [...]
    }

  # docker_image.nginx will be destroyed
  # (because docker_image.nginx is not in configuration)
  - resource "docker_image" "nginx" {
      - keep_locally = true -> null
      - name         = "nginx:1.28-alpine" -> null
      [...]
    }

  # module.blog.docker_container.this will be created
  + resource "docker_container" "this" {
      + name                                        = "blog-g5"
      + ports {
          + external = 8082
          + internal = 80
          + ip       = "0.0.0.0"
          + protocol = "tcp"
        }
      [...]
    }

  # module.blog.docker_image.this will be created
  + resource "docker_image" "this" {
      + keep_locally = true
      + name         = "nginx:1.28-alpine"
      [...]
    }

  # module.docs.docker_container.this will be created
  [... mismo patrón: name = "docs-g5", external = 8083 ...]

  # module.docs.docker_image.this will be created
  [... mismo patrón ...]

  # module.tienda.docker_container.this will be created
  [... mismo patrón: name = "tienda-g5", external = 8081 ...]

  # module.tienda.docker_image.this will be created
  [... mismo patrón ...]

Plan: 6 to add, 0 to change, 2 to destroy.

Changes to Outputs:
  - contenedor = "web-g5" -> null
  - url        = "http://localhost:8080" -> null
  + urls       = [
      + "http://localhost:8081",
      + "http://localhost:8082",
      + "http://localhost:8083",
    ]
```

`terraform apply "fase6.tfplan"`
```
module.docs.docker_image.this: Creating...
module.blog.docker_image.this: Creating...
module.tienda.docker_image.this: Creating...
docker_container.web: Destroying... [id=0d30e8177c96923becacc08156da287fa3464b2dc6370d2758bbbb0bedeaf58a]
docker_container.web: Destruction complete after 1s
docker_image.nginx: Destroying... [id=sha256:a8b39bd9cf0f83869a2162827a0caf6137ddf759d50a171451b335cecc87d236nginx:1.28-alpine]
docker_image.nginx: Destruction complete after 0s
module.docs.docker_image.this: Creation complete after 1s [id=sha256:a8b39bd9cf0f83869a2162827a0caf6137ddf759d50a171451b335cecc87d236nginx:1.28-alpine]
module.tienda.docker_image.this: Creation complete after 1s [id=sha256:a8b39bd9cf0f83869a2162827a0caf6137ddf759d50a171451b335cecc87d236nginx:1.28-alpine]
module.blog.docker_image.this: Creation complete after 1s [id=sha256:a8b39bd9cf0f83869a2162827a0caf6137ddf759d50a171451b335cecc87d236nginx:1.28-alpine]
module.blog.docker_container.this: Creating...
module.docs.docker_container.this: Creating...
module.tienda.docker_container.this: Creating...
module.blog.docker_container.this: Creation complete after 2s [id=6c4f4c3d6443b018e84812c27af78430aa1190890f7ab67a983a57eec46496c8]
module.tienda.docker_container.this: Creation complete after 2s [id=5b63fe5288bb6397431fd0aad792f64391416d341fca35fd74da25224ad8f3ca]
module.docs.docker_container.this: Creation complete after 2s [id=8ad61cba5c69cabd1cdbf1c7ab7bd0ed313aa02091cf1a1a3bc9c17758432d0b]

Apply complete! Resources: 6 added, 0 changed, 2 destroyed.

Outputs:

red_driver = "bridge"
urls = [
  "http://localhost:8081",
  "http://localhost:8082",
  "http://localhost:8083",
]
```

`terraform output urls`, `docker ps` y comprobación de los tres sitios
```
$ terraform output urls
[
  "http://localhost:8081",
  "http://localhost:8082",
  "http://localhost:8083",
]

$ docker ps --filter name=g5
CONTAINER ID   IMAGE          COMMAND                  CREATED        STATUS        PORTS                  NAMES
5b63fe5288bb   a8b39bd9cf0f   "/docker-entrypoint.…"   1 second ago   Up 1 second   0.0.0.0:8081->80/tcp   tienda-g5
6c4f4c3d6443   a8b39bd9cf0f   "/docker-entrypoint.…"   1 second ago   Up 1 second   0.0.0.0:8082->80/tcp   blog-g5
8ad61cba5c69   a8b39bd9cf0f   "/docker-entrypoint.…"   1 second ago   Up 1 second   0.0.0.0:8083->80/tcp   docs-g5

$ curl -s http://localhost:8081
<h1>Tienda del grupo 5</h1>
<p>Sitio tienda-g5, desplegado con Terraform</p>
$ curl -s http://localhost:8082
<h1>Blog del grupo 5</h1>
<p>Sitio blog-g5, desplegado con Terraform</p>
$ curl -s http://localhost:8083
<h1>Documentación del grupo 5</h1>
<p>Sitio docs-g5, desplegado con Terraform</p>

$ terraform plan
No changes. Your infrastructure matches the configuration.
```

Prueba sin `versions.tf` (en una copia temporal fuera del repositorio, borrando `modules/sitio_web/versions.tf` y `.terraform/`; el repo no se tocó)
```
$ terraform init
Initializing the backend...

Initializing modules...
- tienda in modules\sitio_web
- blog in modules\sitio_web
- docs in modules\sitio_web

Initializing provider plugins...
- Finding kreuzwerker/docker versions matching "~> 4.6"...
- Finding latest version of hashicorp/docker...
- Installing kreuzwerker/docker v4.7.0...
- Installed kreuzwerker/docker v4.7.0 (self-signed, key ID 0DCE698927DAF8EC)
Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://developer.hashicorp.com/terraform/cli/plugins/signing

Error: Failed to query available provider packages

Could not retrieve the list of available versions for provider
hashicorp/docker: provider registry registry.terraform.io does not have a
provider named registry.terraform.io/hashicorp/docker

Did you intend to use kreuzwerker/docker? If so, you must specify that source
address in each module which requires that provider. To see which modules are
currently depending on hashicorp/docker, run the following command:
    terraform providers
(código de salida: 1)
```

**Aprobación del revisor:** Aprobado (Revisora Susana): Plan: 6 a crear, 0 a cambiar, 2 a destruir. Se destruyen `docker_container.web` y `docker_image.nginx` porque ya no están en el código raíz; se crean la imagen y el contenedor de cada uno de los tres usos del módulo (`tienda-g5` en 8081, `blog-g5` en 8082 y `docs-g5` en 8083).

### Respuestas
1. Anoten la línea `Plan:` del paso 8. ¿Qué se destruyó, qué se creó y por qué?

2. ¿Qué error obtendrían si el módulo no tuviera `versions.tf`?

3. Si mañana hay que agregar una etiqueta a todos los sitios, ¿cuántos archivos tocan con módulo? ¿Cuántos bloques habrían tocado copiando y pegando?

4. ¿Qué necesitaría otro grupo para usar su módulo sin copiar la carpeta?

---

## Fase 7 · State remoto y varios ambientes

**Roles:** Operadora: Susana · Navegante: Samuel · Revisor: Samuel · Bitácora: Samuel

### Evidencias
> Sobre la contraseña: no está en ningún archivo del repositorio. En los comandos de abajo se escribe `<CLAVE>`. En esta ejecución la clave se generó al azar dentro del propio comando `docker run` y solo existe dentro del contenedor `tf-state-g5`; los scripts de apoyo (fuera del repo) la leían del contenedor y reemplazaban cualquier aparición por `<CLAVE>` en la salida. Los comandos equivalentes, tal como se escribirían a mano, son los dos primeros bloques.
>
> Las salidas largas de `plan` se recortaron con `[...]` o se filtraron a las líneas relevantes; se indica en cada caso. En la línea `Who:` del error de bloqueo se reemplazó el nombre del usuario y del equipo de Windows por `<USUARIO>@<EQUIPO>`.

Backend: contenedor de Postgres (puerto 5436 porque otros puertos del equipo estaban ocupados)
```
$ docker run -d --name tf-state-g5 -p 127.0.0.1:5436:5432 -e POSTGRES_PASSWORD=<CLAVE> -e POSTGRES_DB=terraform_state postgres:17-alpine
$ export PG_CONN_STR='postgres://postgres:<CLAVE>@localhost:5436/terraform_state?sslmode=disable'
```

Paso 1 del LEEME: solo se agregó `backend "pg" {}` al `main.tf` de la Fase 6
```diff
 terraform {
   required_version = ">= 1.6"

+  # El backend queda vacío: la conexión llega por la variable de entorno PG_CONN_STR
+  backend "pg" {}
+
   required_providers {
```

`terraform init -migrate-state` (con `-force-copy` para evitar la pregunta interactiva), `terraform workspace list`, `terraform state list` y `terraform plan`
```
$ terraform init -migrate-state -force-copy
Initializing the backend...

Successfully configured the backend "pg"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing modules...

Initializing provider plugins...
- Reusing version 4.7.0 of kreuzwerker/docker from the dependency lock file
- Using previously-installed kreuzwerker/docker v4.7.0

Terraform has been successfully initialized!
[...]
[exit 0]

$ terraform workspace list
* default

$ terraform state list
data.docker_network.bridge
module.blog.docker_container.this
module.blog.docker_image.this
module.docs.docker_container.this
module.docs.docker_image.this
module.tienda.docker_container.this
module.tienda.docker_image.this

$ terraform plan
[...]
No changes. Your infrastructure matches the configuration.
```

Tabla `states` antes de crear los ambientes
```
$ docker exec tf-state-g5 psql -U postgres -d terraform_state -c "SELECT id, name FROM terraform_remote_state.states;"
 id |  name   
----+---------
  1 | default
(1 row)
```

Prueba de bloqueo con dos procesos (equivalen a las dos terminales). Terminal 1: `terraform apply -var="imagen=nginx:1.27-alpine"`, que se queda esperando la confirmación (el plan era 6 a crear, 0 a cambiar, 6 a destruir) y nunca recibe `yes`; al cerrarse su entrada se cancela solo. Terminal 2, ocho segundos después: `terraform plan`
```
--- Terminal 2: terraform plan
$ terraform plan

Error: Error acquiring the state lock

Error message: Workspace is already locked: default
Lock Info:
  ID:        659a9207-ec1a-d25f-d1d5-d093315b71b1
  Path:      
  Operation: OperationTypePlan
  Who:       <USUARIO>@<EQUIPO>
  Version:   1.17.0
  Created:   2026-11-12 05:46:43.9593393 +0000 UTC
  Info:      


Terraform acquires a state lock to protect the state from being written
by multiple users at the same time. Please resolve the issue above and try
again. For most commands, you can disable locking with the "-lock=false"
flag, but this is not recommended.
[exit 1]

--- Terminal 1 terminó. Salida de su apply (últimas líneas):

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: 
Error: error asking for approval: EOF

--- Comprobación: nada cambió
$ terraform plan
No changes. Your infrastructure matches the configuration.
```
(Un primer intento de la prueba usó `terraform console` para mantener el lock y no sirvió: ese comando no toma el lock y el `plan` paralelo pasó sin error. Por eso se rehízo con un `apply` en espera.)

Paso 4 del LEEME: `terraform destroy` en el workspace `default`, con los archivos de la Fase 6 más `backend "pg" {}`
```
$ terraform workspace show
default

$ terraform plan -destroy -out=fase7-default-destroy.tfplan
[...]
  # module.blog.docker_container.this will be destroyed
  # module.blog.docker_image.this will be destroyed
  # module.docs.docker_container.this will be destroyed
  # module.docs.docker_image.this will be destroyed
  # module.tienda.docker_container.this will be destroyed
  # module.tienda.docker_image.this will be destroyed

Plan: 0 to add, 0 to change, 6 to destroy.

Changes to Outputs:
  - red_driver = "bridge" -> null
  - urls       = [
      - "http://localhost:8081",
      - "http://localhost:8082",
      - "http://localhost:8083",
    ] -> null

$ terraform apply fase7-default-destroy.tfplan
module.docs.docker_container.this: Destroying... [id=8ad61cba5c69cabd1cdbf1c7ab7bd0ed313aa02091cf1a1a3bc9c17758432d0b]
module.blog.docker_container.this: Destroying... [id=6c4f4c3d6443b018e84812c27af78430aa1190890f7ab67a983a57eec46496c8]
module.tienda.docker_container.this: Destroying... [id=5b63fe5288bb6397431fd0aad792f64391416d341fca35fd74da25224ad8f3ca]
[...]
Apply complete! Resources: 0 added, 0 changed, 6 destroyed.
[exit 0]

$ terraform state list   (default, ya vacío)
[exit 0]

$ docker ps --filter name=g5
CONTAINER ID   IMAGE                COMMAND                  CREATED          STATUS          PORTS                      NAMES
09e2919cb683   postgres:17-alpine   "docker-entrypoint.s…"   12 minutes ago   Up 12 minutes   127.0.0.1:5436->5432/tcp   tf-state-g5
```

Paso 5: recién después del destroy se copiaron los archivos de `material-por-fase/fase-7/infra/` (cambian `main.tf`, `locals.tf` y `outputs.tf`). `terraform init` y `terraform fmt -check -recursive` pasaron. En el workspace `default`, `terraform validate` y `terraform plan` fallan con el error esperado:
```
$ terraform workspace show
default
$ terraform plan   (workspace default: debe fallar)

Error: Invalid index

  on locals.tf line 12, in locals:
  12:   amb = local.ambientes[local.entorno]
    ├────────────────
    │ local.ambientes is object with 3 attributes
    │ local.entorno is "default"

The given key does not identify an element in this collection value.
[exit 1]
```

Ambientes. Cada uno se creó con `terraform workspace new <ambiente>` y se aplicó con su plan guardado (salidas filtradas a las líneas relevantes):
```
dev      Plan: 2 to add, 0 to change, 0 to destroy.   (tienda-g5-dev, 8101, nginx:1.28-alpine)
staging  Plan: 6 to add, 0 to change, 0 to destroy.   (tienda 8201, blog 8202, docs 8203, nginx:1.28-alpine)
prod     Plan: 6 to add, 0 to change, 0 to destroy.   (tienda 8301, blog 8302, docs 8303, nginx:1.27-alpine)
```
```
$ terraform apply fase7-dev.tfplan        -> Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
$ terraform apply fase7-staging.tfplan    -> Apply complete! Resources: 6 added, 0 changed, 0 destroyed.
$ terraform apply fase7-prod.tfplan       -> Apply complete! Resources: 6 added, 0 changed, 0 destroyed.
```
Tras cada `apply`, `terraform plan` dio `No changes`. Respuesta HTTP de los sitios, por ejemplo:
```
$ curl -s http://localhost:8302
<h1>Blog - PROD - grupo 5</h1>
<p>Sitio blog-g5-prod, desplegado con Terraform</p>
```

`terraform workspace list`, tabla `states` después de crear los ambientes y `docker ps`
```
$ terraform workspace list
  default
  dev
* prod
  staging

$ docker exec tf-state-g5 psql -U postgres -d terraform_state -c "SELECT id, name FROM terraform_remote_state.states ORDER BY id;"
 id |  name   
----+---------
  1 | default
  3 | dev
  5 | staging
  7 | prod
(4 rows)

$ docker ps --filter name=g5
NAMES               IMAGE                STATUS              PORTS
docs-g5-prod        65645c7bb6a0         Up 6 seconds        0.0.0.0:8303->80/tcp
tienda-g5-prod      65645c7bb6a0         Up 6 seconds        0.0.0.0:8301->80/tcp
blog-g5-prod        65645c7bb6a0         Up 6 seconds        0.0.0.0:8302->80/tcp
tienda-g5-staging   a8b39bd9cf0f         Up 41 seconds       0.0.0.0:8201->80/tcp
docs-g5-staging     a8b39bd9cf0f         Up 41 seconds       0.0.0.0:8203->80/tcp
blog-g5-staging     a8b39bd9cf0f         Up 41 seconds       0.0.0.0:8202->80/tcp
tienda-g5-dev       a8b39bd9cf0f         Up About a minute   0.0.0.0:8101->80/tcp
tf-state-g5         postgres:17-alpine   Up 14 minutes       127.0.0.1:5436->5432/tcp
```
Son siete sitios más el backend.

Comprobación de que la contraseña no está en el repositorio (con la clave real, que aquí se muestra como `<CLAVE>`):
```
$ git grep <CLAVE>
(sin resultados)
$ git log --all -p -S<CLAVE>
(sin resultados)
```

**Aprobación del revisor (por workspace):**
- default (destroy, con los archivos de la Fase 6 y `backend "pg" {}`) — Aprobado (Revisor Samuel): workspace default, Plan: 0 a crear, 0 a cambiar, 6 a destruir.
- Prueba de bloqueo (apply en espera, que se cancela solo) — Aprobado (Revisor Samuel): workspace default, Plan: 6 a crear, 0 a cambiar, 6 a destruir (no se ejecutó: nunca recibió `yes`).
- dev — Aprobado (Revisor Samuel): workspace dev, Plan: 2 a crear, 0 a cambiar, 0 a destruir (1 sitio).
- staging — Aprobado (Revisor Samuel): workspace staging, Plan: 6 a crear, 0 a cambiar, 0 a destruir (3 sitios).
- prod — Aprobado (Revisor Samuel): workspace prod, Plan: 6 a crear, 0 a cambiar, 0 a destruir (3 sitios, imagen 1.27).

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
