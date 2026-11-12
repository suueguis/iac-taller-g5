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
  1. Comprobar que Docker Desktop está abierto y que su motor está corriendo.
  2. Ejecutar `docker run -d --name clickops-g5 -p 8090:80 nginx:1.27-alpine`, que descarga la imagen si hace falta y arranca el contenedor.
  3. Abrir `http://localhost:8090` y verificar que aparece la página de bienvenida de nginx.
  4. Si hay que repetirlo, borrar antes el contenedor con `docker rm -f clickops-g5`.
- Una sola frase declarativa: «Queremos un servidor nginx 1.27 llamado clickops-g5 que responda en el puerto 8090 del equipo.»

### Respuestas
1. ¿Qué error produjo el segundo `docker run`? ¿Qué dice eso sobre la idempotencia de un comando imperativo?

El segundo `docker run` falló con `Conflict. The container name "/clickops-g5" is already in use` y terminó con código de salida 125, porque el nombre ya existía y Docker no creó nada. Cuando probamos con otro nombre, `clickops-g5-2`, y el mismo puerto, Docker sí creó el contenedor pero no pudo arrancarlo (`Bind for 0.0.0.0:8090 failed: port is already allocated`), y `docker ps -a` lo mostró en estado `Created`. Eso nos dice que un comando imperativo no es idempotente: ejecutarlo dos veces no deja el mismo resultado que ejecutarlo una, sino un error o un contenedor a medias que hubo que limpiar a mano (Díaz Bautista, s. f.).

2. Si otro grupo necesitara mañana un servidor idéntico, ¿qué tendrían que contarle y dónde quedó registrado lo que hicieron?

Tendríamos que contarles de memoria el comando completo: la imagen y su versión (`nginx:1.27-alpine`), el nombre del contenedor y el mapeo de puertos (8090 a 80). Lo que hicimos no quedó registrado en ningún archivo de configuración, solo en el historial de la terminal y en la memoria de quien lo escribió; la única constancia es esta bitácora, copiada a mano. Es justo lo que la clase llama ClickOps (Díaz Bautista, s. f.).

3. ¿Cuáles de los cuatro puntos de la diapositiva «Por qué duele» vivieron en esta fase?

Vivimos los cuatro, cada uno a su manera. Fue lento y propenso a errores: el intento con otro nombre y el mismo puerto dejó `clickops-g5-2` creado pero sin arrancar y hubo que borrarlo a mano. Fue imposible de reproducir igual dos veces, porque el mismo comando funcionó la primera vez y falló la segunda. No quedó historial de quién creó o borró los contenedores ni cuándo, y el conocimiento se quedó en quien tecleó el comando, porque la imagen, el puerto y el nombre solo estaban en su terminal (Díaz Bautista, s. f., «Por qué duele»).

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

El plan dijo `Plan: 2 to add, 0 to change, 0 to destroy`. Los dos recursos fueron `docker_image.nginx` y `docker_container.web`: aunque pedimos un solo servidor, Docker necesita primero la imagen y después el contenedor que se crea a partir de ella. La salida `url` no cuenta como recurso, por eso apareció aparte, en «Changes to Outputs».

2. El contenedor usa `docker_image.nginx.image_id`. ¿Qué orden de creación impone esa referencia? Relaciónenlo con la diapositiva «Qué ocurre cuando aplicas».

La referencia obliga a crear la imagen antes que el contenedor, porque el contenedor necesita ese `image_id`, que solo se conoce cuando la imagen ya existe. En el `apply` se vio en ese orden: `docker_image.nginx: Creating...` y `Creation complete`, y solo después `docker_container.web: Creating...`. Es lo que muestra la diapositiva «Qué ocurre cuando aplicas»: Terraform arma el plan y respeta las dependencias antes de llamar al provider (Díaz Bautista, s. f.).

3. ¿Qué descargó `terraform init`, dónde lo guardó y para qué sirve `.terraform.lock.hcl`?

`terraform init` descargó el provider `kreuzwerker/docker` en su versión 4.7.0 (nuestro código pedía `~> 4.6`) y lo guardó en la carpeta `.terraform/`, que no se sube a Git. También creó `.terraform.lock.hcl`, donde queda registrada la versión exacta elegida y sus checksums, para que cualquier integrante que ejecute `init` use el mismo provider; por eso este archivo sí se sube al repositorio (HashiCorp, s. f.-b).

4. De los cuatro bloques de la diapositiva «Cómo se escribe Terraform», ¿cuál no aparece todavía en su archivo?

En nuestro `main.tf` de la Fase 2 aparecen `terraform`, `provider`, `resource` y `output`, pero no hay ningún bloque `variable`: el nombre, la imagen y el puerto están escritos directamente en el código (por ejemplo `external = 8080`). Tampoco hay todavía `locals` ni `data`; todo eso llega en la Fase 5 (Díaz Bautista, s. f., «Cómo se escribe Terraform»).

5. Comparen con la Fase 1: ¿dónde quedó registrado ahora lo que hicieron?

Ahora quedó registrado en `infra/main.tf`, dentro del repositorio de Git, en el commit `fase-2: primer despliegue`. Cualquiera puede leer qué servidor describimos, volver a crearlo con `terraform apply` y ver con `git log` quién lo hizo y cuándo, algo que en la Fase 1 solo existía en la terminal (Díaz Bautista, s. f.).

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

Respondió `No changes. Your infrastructure matches the configuration.` y cerró con `Apply complete! Resources: 0 added, 0 changed, 0 destroyed.` Terraform comparó el código, el state y lo que había en Docker, vio que coincidían y no hizo nada. El segundo `docker run` de la Fase 1, en cambio, falló con un conflicto de nombre; esa diferencia es la idempotencia (Díaz Bautista, s. f.).

2. ¿Qué datos guarda el state que no escribieron en `main.tf`? ¿Para qué los necesita Terraform?

`terraform state show docker_container.web` mostró datos que nunca escribimos en `main.tf`: el `id` completo del contenedor, el `hostname`, la IP `172.17.0.3`, el gateway `172.17.0.1`, la MAC, el `command`, el `entrypoint` y el `stop_signal`, entre otros. Terraform los guarda para saber qué objeto real de Docker corresponde a cada recurso del código y poder compararlos en el siguiente `plan`, sin tener que adivinar ni volver a crear lo que ya existe (HashiCorp, s. f.-a).

3. ¿Por qué el cambio de imagen reemplazó el contenedor en lugar de modificarlo? Relaciónenlo con «Infraestructura mutable vs. inmutable».

Al cambiar `nginx:1.27-alpine` por `nginx:1.28-alpine`, el plan mostró `-/+` y `forces replacement` en el `name` de `docker_image.nginx` y en el `image` de `docker_container.web`, con `Plan: 2 to add, 0 to change, 2 to destroy`. Un contenedor ya creado no cambia de imagen: Terraform destruyó el viejo y creó uno nuevo con la 1.28 (la respuesta HTTP pasó a decir nginx/1.28.3). Es la infraestructura inmutable, que se reemplaza en vez de parchearse, a diferencia de la mutable, donde se entra al servidor y se modifica (Díaz Bautista, s. f., «Infraestructura mutable vs. inmutable»).

4. ¿Cómo cambió `serial` después del `apply` y qué creen que representa?

El `serial` valía 3 después de la Fase 2, pasó a 4 con un `apply` que no cambió ningún recurso y llegó a 9 después del reemplazo por la imagen 1.28; un `plan` solo, en cambio, no lo movió. Entendemos que `serial` es un contador de versiones del state: sube con cada `apply`, incluso cuando no cambia ningún recurso, porque Terraform vuelve a guardar el state, y sirve para saber qué copia es más reciente (HashiCorp, s. f.-a). El salto de 4 a 9 coincide con que el reemplazo hizo varias operaciones (destruir contenedor e imagen, crear imagen y contenedor), pero no comprobamos si cada una suma exactamente uno.

5. Piensen en un proyecto real con bases de datos: ¿qué riesgo habría si este archivo se subiera a Git?

El state guarda en texto plano todos los atributos de los recursos, y en un proyecto real eso incluye contraseñas y cadenas de conexión de las bases de datos. Si el archivo entra a Git queda en el historial, donde es casi imposible de borrar y lo puede ver cualquiera con acceso al repositorio (HashiCorp, s. f.-c). Por eso nuestro `.gitignore` excluye `*.tfstate` y `.terraform/`, y en la Fase 7 el state pasó a un backend remoto; además, dos personas con copias distintas del state podrían pisarse.

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

Con `docker exec` cambiamos el `index.html` dentro del contenedor: `curl` mostró `<h1>Modificado a mano - g5</h1>`, pero `terraform plan` respondió `No changes`. Terraform solo compara lo que el provider lee de Docker (nombre, imagen, puertos, estado del contenedor), y el contenido de un archivo interno no forma parte de esa descripción. Ese nivel, lo que hay instalado o configurado dentro de lo que ya existe, lo cubren las herramientas de gestión de configuración (por ejemplo Ansible), que la diapositiva «Aprovisionar ≠ configurar» distingue de las de aprovisionamiento, como Terraform (Díaz Bautista, s. f.).

2. ¿Por qué `-replace` es una corrección coherente con la infraestructura inmutable?

Corregimos con `terraform apply -replace=docker_container.web`: el plan dijo `will be replaced, as requested` (`Plan: 1 to add, 0 to change, 1 to destroy`) y volvió a aparecer la página de bienvenida de nginx. No entramos a deshacer el cambio dentro del servidor: lo descartamos y creamos uno nuevo desde lo que dice el código. Esa es la lógica de la infraestructura inmutable, donde nada se arregla a mano sobre lo que ya existe (Díaz Bautista, s. f.).

3. En un equipo real, ¿cómo detectarían el drift sin esperar a que alguien ejecute `plan` por casualidad?

Ejecutando `terraform plan` de forma automática y periódica, por ejemplo dentro de un pipeline de CI/CD, y avisando al equipo cuando aparezca cualquier diferencia entre el código y la realidad. En el experimento B, `terraform plan -refresh-only` informó justo eso (`docker_container.web has been deleted`) sin proponer acciones, y esa revisión se puede programar. Eso no habría detectado el experimento C, que `plan` no ve, así que además hay que mantener la regla de que nadie cambia la infraestructura a mano (Díaz Bautista, s. f.).

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

Gana el valor pasado con `-var`. Según la documentación, el orden de menor a mayor prioridad es el `default`, las variables de entorno `TF_VAR_`, `terraform.tfvars`, los archivos `*.auto.tfvars` y, por último, `-var` y `-var-file` (HashiCorp, s. f.-d). En nuestra práctica el `default` era 8080: con `-var="puerto=9500"` Terraform usó 9500, y con `-var="puerto=8085"` el plan mostró `external = 8080 -> 8085`. Lo que no probamos fue la precedencia frente a `terraform.tfvars`, porque el nuestro no tenía `puerto` (solo `grupo` y `mensaje`); ese punto lo tomamos de la documentación.

2. ¿Qué hizo el bloque `validation` con el puerto 9500? ¿En qué se parece a la idea de Policy as Code?

Con `-var="puerto=9500"` el `plan` falló con `Error: Invalid value for variable ... var.puerto is 9500` y el mensaje «El puerto debe estar entre 8000 y 8999», sin llegar a crear nada; con 8085 el plan pasó y propuso reemplazar el contenedor. Se parece a Policy as Code porque es una regla escrita como código que se evalúa sola y bloquea lo que no cumple antes de aplicar, sin que una persona tenga que acordarse de revisarla (Díaz Bautista, s. f.).

3. ¿Terraform creó la red `bridge`? ¿Qué le pasará cuando el grupo ejecute `destroy`?

No: el `data source` solo lee una red que Docker ya tenía. En el plan apareció como `data.docker_network.bridge: Reading... Read complete`, nunca como `will be created`. Por eso los planes de destrucción de la Fase 7 (`Plan: 0 to add, 0 to change, 6 to destroy`) y de la Fase 9 (2, 6 y 6 recursos) no incluyeron la red `bridge`: Terraform la consulta pero no la gestiona, así que `destroy` no la toca.

4. ¿Qué ganan con `local.nombre` frente a escribir `"web-gN"` en cada lugar donde se necesita?

Con `local.nombre` el nombre se define una sola vez a partir del número de grupo (`"web-g${var.grupo}"`) y se reutiliza donde haga falta; en `terraform console`, `local.nombre` dio `"web-g5"`. Si cambia el patrón o el número de grupo se edita un solo lugar y no queda ninguna copia desincronizada, que es lo que se pierde al escribir `"web-g5"` a mano en cada parte (Díaz Bautista, s. f.).

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

La línea fue `Plan: 6 to add, 0 to change, 2 to destroy`. Se destruyeron `docker_container.web` y `docker_image.nginx`, porque al pasar al módulo ya no estaban en el código raíz (`is not in configuration`). Se crearon seis recursos, la imagen y el contenedor de cada uno de los tres usos del módulo: `tienda-g5` en el puerto 8081, `blog-g5` en el 8082 y `docs-g5` en el 8083. Por eso desapareció `web-g5`, el del puerto 8080.

2. ¿Qué error obtendrían si el módulo no tuviera `versions.tf`?

Lo probamos con `terraform init` en una copia temporal sin `modules/sitio_web/versions.tf` y falló con `Error: Failed to query available provider packages`, diciendo que el registro `does not have a provider named registry.terraform.io/hashicorp/docker` y sugiriendo «Did you intend to use kreuzwerker/docker?». Sin ese archivo el módulo no declara de dónde viene el provider y Terraform asume `hashicorp/docker`, que no existe.

3. Si mañana hay que agregar una etiqueta a todos los sitios, ¿cuántos archivos tocan con módulo? ¿Cuántos bloques habrían tocado copiando y pegando?

Con módulo tocaríamos un solo archivo, `infra/modules/sitio_web/main.tf`, porque ahí está la única definición del contenedor y el cambio llega a los tres sitios. Copiando y pegando habríamos tenido que editar tres bloques de contenedor, uno por sitio, y alguno podría haber quedado distinto de los otros (Díaz Bautista, s. f.).

4. ¿Qué necesitaría otro grupo para usar su módulo sin copiar la carpeta?

Necesitaría que el módulo estuviera publicado en un lugar accesible, por ejemplo en su propio repositorio de Git, y referenciarlo desde su `source` fijando una versión, en lugar de la ruta local que usamos nosotros (`./modules/sitio_web`). Así ese grupo no copia la carpeta y recibe los cambios al actualizar la versión. En el taller solo probamos la ruta local, no un `source` remoto (Díaz Bautista, s. f.).

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

La terminal 2 respondió `Error: Error acquiring the state lock` con `Workspace is already locked: default` y los datos del bloqueo (un ID, `Operation: OperationTypePlan` y la versión de Terraform), mientras la terminal 1 esperaba la confirmación de un `apply`. Eso evita que dos personas modifiquen el mismo state al mismo tiempo, lo que podría corromperlo o duplicar infraestructura (HashiCorp, s. f.-e). Nuestro primer intento, con `terraform console`, no bloqueó porque ese comando no toma el lock; lo repetimos con un `apply` en espera, que se cancelaba solo sin confirmar nada, y las dos «terminales» fueron dos procesos lanzados desde un mismo script.

2. ¿Dónde quedó la contraseña del backend y por qué no debe estar en `main.tf`?

En `main.tf` el bloque `backend "pg" {}` está vacío: la contraseña no está en ningún archivo. Vive en la variable de entorno `PG_CONN_STR`, definida solo en la terminal donde se ejecuta Terraform, y dentro del contenedor `tf-state-g5`, que la recibió en el `docker run`. En nuestra ejecución no usamos la de ejemplo de la guía: la clave se generó al azar al crear el contenedor y nunca se escribió en un archivo; en la bitácora los comandos llevan `<CLAVE>`, y con `git grep` y `git log -p -S` no encontramos nada. No debe estar en `main.tf` porque ese archivo se versiona y la contraseña quedaría para siempre en el historial de Git (Díaz Bautista, s. f.; HashiCorp, s. f.-e).

3. ¿Qué filas tiene ahora la tabla `states` y cómo se relacionan con los workspaces?

Antes de crear los ambientes la tabla tenía una sola fila, `1 | default`; al terminar tiene cuatro: `1 | default`, `3 | dev`, `5 | staging` y `7 | prod`. Cada fila es un workspace: la columna `name` es el nombre del workspace y ahí se guarda el state de ese ambiente, por eso cada uno queda aislado de los demás (HashiCorp, s. f.-e). Los `id` van de dos en dos porque es un contador autoincremental de Postgres y creemos que el backend consume más de un número al crear cada workspace; no lo comprobamos en su código, pero encaja con lo que vimos. La fila `default` sigue existiendo aunque su state quedó vacío después del `destroy`.

4. ¿Qué error da `terraform plan` en el workspace `default` y por qué es útil que falle?

Falla con `Error: Invalid index` en `locals.tf` línea 12 (`amb = local.ambientes[local.entorno]`), porque `local.entorno` vale `"default"` y el mapa `ambientes` solo tiene `dev`, `staging` y `prod`. Que falle es útil porque obliga a elegir un ambiente a propósito y evita desplegar sin querer en el lugar equivocado. Lo vimos también con `terraform validate`, que falla igual mientras el workspace activo sea `default`.

5. ¿Por qué `dev` tiene un solo sitio y `staging` replica a `prod`? ¿Por qué `prod` usa otra versión de imagen?

`dev` tiene un solo sitio, `tienda-g5-dev` en el puerto 8101 (2 recursos), porque sirve para probar con lo mínimo. `staging` tiene los tres sitios (`Plan: 6 to add`, puertos 8201 a 8203) porque es la réplica de producción donde se valida antes de lanzar, y `prod` también tiene tres (8301 a 8303). `prod` usa `nginx:1.27-alpine` mientras `dev` y `staging` prueban la 1.28: la versión nueva se valida primero en `staging` y solo después llega a producción (Díaz Bautista, s. f.).

6. Los tres ambientes comparten código y backend. ¿Qué riesgo tiene eso frente a usar carpetas separadas por ambiente?

Al compartir código y backend, un error en el código o aplicar en el workspace equivocado puede afectar a los tres ambientes, incluido `prod`, y una falla del backend los afecta a todos a la vez: un solo contenedor, `tf-state-g5`, guarda los cuatro states. Con carpetas separadas cada ambiente queda aislado, aunque a cambio se duplica código. Por eso en la Fase 9 confirmamos el ambiente con `workspace select` antes de cada `destroy` (Díaz Bautista, s. f.).

---

## Fase 8 · Testing y calidad

**Roles:** Operador: Samuel · Navegante: Susana · Revisora: Susana · Bitácora: Susana

### Evidencias
Se copió `material-por-fase/fase-8/` al repositorio: `validar.sh` y `seguridad/` en la raíz y `sitio_web.tftest.hcl` en `infra/modules/sitio_web/tests/`. Para que `terraform test` funcione en el módulo hubo que correr `terraform init` dentro de `infra/modules/sitio_web` (crea su propio `.terraform.lock.hcl`, que sí se sube).

Nota: `terraform validate` se ejecutó con el workspace `prod` activo; en el workspace `default` falla con `Invalid index` (Fase 7).

`terraform fmt -check -recursive` y `terraform validate`
```
$ terraform -chdir=infra fmt -check -recursive
(sin salida; código de salida 0)

$ terraform -chdir=infra validate
Success! The configuration is valid.
```

`terraform test` (cuatro pruebas)
```
$ terraform -chdir=infra/modules/sitio_web test
tests\sitio_web.tftest.hcl... in progress
  run "url_coherente_con_puerto"... pass
  run "rechaza_puerto_fuera_de_rango"... pass
  run "nombre_coincide_con_variable"... pass
  run "despliegue_real"... pass
tests\sitio_web.tftest.hcl... tearing down
tests\sitio_web.tftest.hcl... pass

Success! 4 passed, 0 failed.
```

`docker ps` durante `despliegue_real` (observado en un bucle cada 0,5 s mientras corría la prueba)
```
00:58:49
prueba-g5	a8b39bd9cf0f	Up Less than a second	0.0.0.0:8999->80/tcp

$ docker ps --filter name=prueba-g5     (después de la prueba)
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```
El contenedor `prueba-g5` apareció en el puerto 8999 durante `despliegue_real` y desapareció al terminar la prueba. El observador lo vio en 1 de 4 instantes (la prueba dura muy poco). Con `validar.sh` se vio igual, en 1 de 12 instantes (`Up 1 second`, puerto 8999).

Escaneo de seguridad con Checkov (versión 3.4.4). Checkov no estaba instalado, y tampoco `pipx` ni `trivy`; se instaló con `pip` en un entorno virtual aislado. Se ejecutó con `BC_SKIP_MAPPING=TRUE` para que no intente consultar una API externa (sin eso imprime un aviso largo y sigue funcionando). `bucket.tf` no se aplica, solo se escanea.

ANTES de corregir (los cuatro valores de `aws_s3_bucket_public_access_block` en `false`), con los cuatro controles de la política del equipo:
```
$ checkov -d seguridad --check CKV_AWS_53,CKV_AWS_54,CKV_AWS_55,CKV_AWS_56

terraform scan results:

Passed checks: 0, Failed checks: 4, Skipped checks: 0

Check: CKV_AWS_53: "Ensure S3 bucket has block public ACLS enabled"
	FAILED for resource: aws_s3_bucket_public_access_block.evidencias
	File: \bucket.tf:8-14
Check: CKV_AWS_54: "Ensure S3 bucket has block public policy enabled"
	FAILED for resource: aws_s3_bucket_public_access_block.evidencias
	File: \bucket.tf:8-14
Check: CKV_AWS_55: "Ensure S3 bucket has ignore public ACLs enabled"
	FAILED for resource: aws_s3_bucket_public_access_block.evidencias
	File: \bucket.tf:8-14
Check: CKV_AWS_56: "Ensure S3 bucket has 'restrict_public_buckets' enabled"
	FAILED for resource: aws_s3_bucket_public_access_block.evidencias
	File: \bucket.tf:8-14
```

ANTES, escaneo completo (todos los controles de Checkov; salida filtrada a las líneas `Check:` y `FAILED`/`PASSED`):
```
$ checkov -d seguridad --compact
Passed checks: 4, Failed checks: 11, Skipped checks: 0
Check: CKV_AWS_93  PASSED  aws_s3_bucket.evidencias
Check: CKV_AWS_19  PASSED  aws_s3_bucket.evidencias
Check: CKV_AWS_20  PASSED  aws_s3_bucket.evidencias
Check: CKV_AWS_57  PASSED  aws_s3_bucket.evidencias
Check: CKV_AWS_53  FAILED  aws_s3_bucket_public_access_block.evidencias
Check: CKV_AWS_54  FAILED  aws_s3_bucket_public_access_block.evidencias
Check: CKV_AWS_55  FAILED  aws_s3_bucket_public_access_block.evidencias
Check: CKV_AWS_56  FAILED  aws_s3_bucket_public_access_block.evidencias
Check: CKV2_AWS_62 FAILED  aws_s3_bucket.evidencias   (notificaciones de eventos)
Check: CKV2_AWS_61 FAILED  aws_s3_bucket.evidencias   (ciclo de vida)
Check: CKV_AWS_18  FAILED  aws_s3_bucket.evidencias   (registro de accesos)
Check: CKV_AWS_144 FAILED  aws_s3_bucket.evidencias   (replicación entre regiones)
Check: CKV_AWS_21  FAILED  aws_s3_bucket.evidencias   (versionado)
Check: CKV_AWS_145 FAILED  aws_s3_bucket.evidencias   (cifrado con KMS)
Check: CKV2_AWS_6  FAILED  aws_s3_bucket.evidencias   (bloqueo de acceso público)
```

Corrección en `seguridad/bucket.tf` (diff respecto al material):
```diff
 resource "aws_s3_bucket_public_access_block" "evidencias" {
   bucket                  = aws_s3_bucket.evidencias.id
-  block_public_acls       = false
-  block_public_policy     = false
-  ignore_public_acls      = false
-  restrict_public_buckets = false
+  block_public_acls       = true
+  block_public_policy     = true
+  ignore_public_acls      = true
+  restrict_public_buckets = true
 }
```

DESPUÉS de corregir, con los cuatro controles de la política del equipo:
```
$ checkov -d seguridad --check CKV_AWS_53,CKV_AWS_54,CKV_AWS_55,CKV_AWS_56
Passed checks: 4, Failed checks: 0, Skipped checks: 0

Check: CKV_AWS_53: "Ensure S3 bucket has block public ACLS enabled"
	PASSED for resource: aws_s3_bucket_public_access_block.evidencias
Check: CKV_AWS_54: "Ensure S3 bucket has block public policy enabled"
	PASSED for resource: aws_s3_bucket_public_access_block.evidencias
Check: CKV_AWS_55: "Ensure S3 bucket has ignore public ACLs enabled"
	PASSED for resource: aws_s3_bucket_public_access_block.evidencias
Check: CKV_AWS_56: "Ensure S3 bucket has 'restrict_public_buckets' enabled"
	PASSED for resource: aws_s3_bucket_public_access_block.evidencias
```

DESPUÉS, escaneo completo:
```
$ checkov -d seguridad --compact
Passed checks: 9, Failed checks: 6, Skipped checks: 0
Check: CKV_AWS_93  PASSED  aws_s3_bucket.evidencias
Check: CKV_AWS_53  PASSED  aws_s3_bucket_public_access_block.evidencias
Check: CKV_AWS_54  PASSED  aws_s3_bucket_public_access_block.evidencias
Check: CKV_AWS_55  PASSED  aws_s3_bucket_public_access_block.evidencias
Check: CKV_AWS_56  PASSED  aws_s3_bucket_public_access_block.evidencias
Check: CKV_AWS_19  PASSED  aws_s3_bucket.evidencias
Check: CKV2_AWS_6  PASSED  aws_s3_bucket.evidencias
Check: CKV_AWS_20  PASSED  aws_s3_bucket.evidencias
Check: CKV_AWS_57  PASSED  aws_s3_bucket.evidencias
Check: CKV2_AWS_62 FAILED  aws_s3_bucket.evidencias   (notificaciones de eventos)
Check: CKV2_AWS_61 FAILED  aws_s3_bucket.evidencias   (ciclo de vida)
Check: CKV_AWS_18  FAILED  aws_s3_bucket.evidencias   (registro de accesos)
Check: CKV_AWS_144 FAILED  aws_s3_bucket.evidencias   (replicación entre regiones)
Check: CKV_AWS_21  FAILED  aws_s3_bucket.evidencias   (versionado)
Check: CKV_AWS_145 FAILED  aws_s3_bucket.evidencias   (cifrado con KMS)
```
(Los controles `CKV_AWS_53` a `56` pasan; además `CKV2_AWS_6` pasó de fallar a pasar.)

`bash validar.sh` completo
```
$ bash validar.sh
Success! The configuration is valid.

tests\sitio_web.tftest.hcl... in progress
  run "url_coherente_con_puerto"... pass
  run "rechaza_puerto_fuera_de_rango"... pass
  run "nombre_coincide_con_variable"... pass
  run "despliegue_real"... pass
tests\sitio_web.tftest.hcl... tearing down
tests\sitio_web.tftest.hcl... pass

Success! 4 passed, 0 failed.

By Prisma Cloud | version: 3.4.4 

terraform scan results:

Passed checks: 4, Failed checks: 0, Skipped checks: 0

Check: CKV_AWS_53: "Ensure S3 bucket has block public ACLS enabled"
	PASSED for resource: aws_s3_bucket_public_access_block.evidencias
	File: \bucket.tf:8-14
Check: CKV_AWS_54: "Ensure S3 bucket has block public policy enabled"
	PASSED for resource: aws_s3_bucket_public_access_block.evidencias
	File: \bucket.tf:8-14
Check: CKV_AWS_55: "Ensure S3 bucket has ignore public ACLs enabled"
	PASSED for resource: aws_s3_bucket_public_access_block.evidencias
	File: \bucket.tf:8-14
Check: CKV_AWS_56: "Ensure S3 bucket has 'restrict_public_buckets' enabled"
	PASSED for resource: aws_s3_bucket_public_access_block.evidencias
	File: \bucket.tf:8-14
Validación completa: el cambio puede pasar a revisión
(código de salida 0)
```
(Se recortó el logotipo ASCII de Checkov. `fmt -check` no imprime nada cuando todo está bien.)

Pruebas que pide la guía para ver dónde se detiene `validar.sh`. Se ejecutaron en el repositorio y después se restauraron los archivos con `git checkout`; `git status` quedó igual que antes (sin esos cambios).

Prueba 1: desordenar a propósito la indentación de `infra/locals.tf` y correr `bash validar.sh`
```
$ git diff infra/locals.tf    (lo que se desordenó a propósito)
-  entorno = terraform.workspace
+entorno    =    terraform.workspace
-  desplazamiento = { tienda = 1, blog = 2, docs = 3 }
+desplazamiento    = { tienda = 1, blog = 2, docs = 3 }

$ bash validar.sh
locals.tf
[exit 3]
```
`validar.sh` se detuvo en su primer comando, `terraform fmt -check -recursive`, que imprimió el archivo mal formateado (`locals.tf`) y terminó con código 3. Por el `set -e` no llegó a `validate`, a `terraform test` ni a Checkov.

Prueba 2: volver a poner en `false` un valor de `seguridad/bucket.tf` (`block_public_acls`)
```
$ git diff seguridad/bucket.tf
-  block_public_acls       = true
+  block_public_acls       = false

$ checkov -d seguridad --check CKV_AWS_53,CKV_AWS_54,CKV_AWS_55,CKV_AWS_56   (paso 4 de validar.sh)
Passed checks: 3, Failed checks: 1, Skipped checks: 0
Check: CKV_AWS_54: "Ensure S3 bucket has block public policy enabled"
	PASSED for resource: aws_s3_bucket_public_access_block.evidencias
	File: \bucket.tf:8-14
Check: CKV_AWS_55: "Ensure S3 bucket has ignore public ACLs enabled"
	PASSED for resource: aws_s3_bucket_public_access_block.evidencias
	File: \bucket.tf:8-14
Check: CKV_AWS_56: "Ensure S3 bucket has 'restrict_public_buckets' enabled"
	PASSED for resource: aws_s3_bucket_public_access_block.evidencias
	File: \bucket.tf:8-14
Check: CKV_AWS_53: "Ensure S3 bucket has block public ACLS enabled"
	FAILED for resource: aws_s3_bucket_public_access_block.evidencias
	File: \bucket.tf:8-14
[exit 1]
```
En esta prueba se ejecutó solo el paso 4 de `validar.sh` (Checkov), no el script completo: los pasos 1 a 3 incluyen `terraform test`, que despliega un contenedor de verdad (`despliegue_real`), y no se repitió esa ejecución sin la aprobación del revisor. Checkov terminó con código 1 (`CKV_AWS_53` falló), y con `set -e` el script se habría detenido en ese paso, antes del mensaje final.

`docker ps` al terminar la fase (solo el taller): siete sitios más el backend, sin `prueba-g5`
```
NAMES               IMAGE                STATUS          PORTS
docs-g5-prod        65645c7bb6a0         Up 7 minutes    0.0.0.0:8303->80/tcp
tienda-g5-prod      65645c7bb6a0         Up 7 minutes    0.0.0.0:8301->80/tcp
blog-g5-prod        65645c7bb6a0         Up 7 minutes    0.0.0.0:8302->80/tcp
tienda-g5-staging   a8b39bd9cf0f         Up 8 minutes    0.0.0.0:8201->80/tcp
docs-g5-staging     a8b39bd9cf0f         Up 8 minutes    0.0.0.0:8203->80/tcp
blog-g5-staging     a8b39bd9cf0f         Up 8 minutes    0.0.0.0:8202->80/tcp
tienda-g5-dev       a8b39bd9cf0f         Up 9 minutes    0.0.0.0:8101->80/tcp
tf-state-g5         postgres:17-alpine   Up 22 minutes   127.0.0.1:5436->5432/tcp
```

**Aprobación del revisor:** Aprobado (Revisora Susana): Plan: 2 a crear, 0 a cambiar, 0 a destruir (la prueba `despliegue_real` crea la imagen y el contenedor `prueba-g5` y `terraform test` los destruye al terminar). Se corrió dos veces: con `terraform test` y dentro de `validar.sh`.

### Respuestas
1. ¿Qué encontró cada nivel (estático, pruebas, seguridad) que los otros no podían encontrar?

El análisis estático encontró lo que solo revela la forma del código: al desordenar la indentación de `locals.tf`, `terraform fmt -check` imprimió el archivo y `validar.sh` se detuvo en su primer paso, con código 3. Las pruebas comprueban comportamiento: `rechaza_puerto_fuera_de_rango` confirma que el 9500 se rechaza y `despliegue_real` verifica que el contenedor `prueba-g5` se crea de verdad. El escaneo de seguridad encontró lo que ni el formato ni las pruebas ven: con `block_public_acls` en `false`, Checkov falló `CKV_AWS_53` aunque el código fuera válido (Díaz Bautista, s. f.).

2. ¿Qué vio quien observaba `docker ps` durante `despliegue_real`? ¿Por qué vale la pena un entorno desechable?

Mientras corría la prueba, `docker ps` mostró un contenedor `prueba-g5` en el puerto 8999 (`Up Less than a second`) y, al terminar, `docker ps --filter name=prueba-g5` quedó vacío: `terraform test` lo destruyó solo. Como la prueba dura muy poco, con un bucle que miraba cada 0,5 segundos solo lo vimos en 1 de 4 instantes. Un entorno desechable vale la pena porque permite probar con un despliegue de verdad sin tocar ni ensuciar los ambientes reales, y se limpia solo (HashiCorp, s. f.-f).

3. ¿Qué controles fallaron en el bucket y cuántos quedaron después de corregir? ¿Cuáles corresponden al ejemplo «sin buckets públicos» de la clase?

Con los cuatro controles de la política del equipo fallaron `CKV_AWS_53`, `CKV_AWS_54`, `CKV_AWS_55` y `CKV_AWS_56` (0 pasaban, 4 fallaban), y pasaron los cuatro después de poner los valores en `true`. En el escaneo completo fallaban 11 controles y quedaron 6 (`CKV2_AWS_62`, `CKV2_AWS_61`, `CKV_AWS_18`, `CKV_AWS_144`, `CKV_AWS_21` y `CKV_AWS_145`), de versionado, registro de accesos, cifrado con KMS, replicación, ciclo de vida y notificaciones, que en una nube real también habría que atender. Los cuatro `CKV_AWS_53` a `56` son los del ejemplo «sin buckets públicos» de Policy as Code (Díaz Bautista, s. f.).

4. ¿Qué ventaja tiene detectar un problema en el código, antes del `apply`, frente a detectarlo en la nube?

Checkov analizó `seguridad/bucket.tf` sin credenciales de AWS y sin crear nada, así que el bucket público se corrigió en el archivo antes de que existiera. En la nube el mismo error ya estaría desplegado y habría que repararlo con el sistema en uso, con datos posiblemente expuestos. Detectar antes del `apply` es más barato y más seguro: se corrige un archivo y se vuelve a escanear en segundos (Díaz Bautista, s. f.).

5. ¿En qué paso del pipeline de la diapositiva va `validar.sh` y qué paso humano viene después?

`validar.sh` ejecuta `fmt -check`, `validate`, `terraform test` y Checkov, y termina con «el cambio puede pasar a revisión»: hace el papel de la etapa «Validar» de un pipeline de CI/CD, la que corre sola y detiene todo si algo falla (`set -e`). El paso humano que viene después es revisar el plan y aprobarlo, y solo entonces aplicar, como hicimos en cada fase con el «Aprobado» del revisor (Díaz Bautista, s. f.).

---

## Fase 9 · Auditoría cruzada y cierre

**Roles:** Operadora: Susana · Navegante: Samuel · Revisor: Samuel · Bitácora: Samuel

### Evidencias
El detalle de la auditoría al grupo 2 está en `AUDITORIA.md`.

> Sobre la conexión al backend: los planes y los `destroy` se ejecutaron desde la terminal de Susana, donde `PG_CONN_STR` estaba definida; la contraseña no aparece en ningún archivo ni salida de esta bitácora. Los `docker ps` se recortaron al filtro `g5` porque el equipo tiene otros contenedores personales ajenos al taller, que no se tocaron.

Planes de destrucción (un workspace por vez, en el orden de la guía). Se recortaron con `[...]` las líneas de atributos de cada recurso:

`dev`
```
$ terraform workspace select dev
Switched to workspace "dev".

$ terraform plan -destroy -out=fase9-dev.tfplan
Terraform will perform the following actions:

  # module.sitio["tienda"].docker_container.this will be destroyed
  [...]
  # module.sitio["tienda"].docker_image.this will be destroyed
  [...]

Plan: 0 to add, 0 to change, 2 to destroy.

Changes to Outputs:
  - red_driver = "bridge" -> null
  - urls       = {
      - tienda-g5-dev = "http://localhost:8101"
    } -> null
```

`staging`
```
$ terraform workspace select staging
Switched to workspace "staging".

$ terraform plan -destroy -out=fase9-staging.tfplan
Terraform will perform the following actions:

  # module.sitio["blog"].docker_container.this will be destroyed
  # module.sitio["blog"].docker_image.this will be destroyed
  # module.sitio["docs"].docker_container.this will be destroyed
  # module.sitio["docs"].docker_image.this will be destroyed
  # module.sitio["tienda"].docker_container.this will be destroyed
  # module.sitio["tienda"].docker_image.this will be destroyed
  [...]

Plan: 0 to add, 0 to change, 6 to destroy.

Changes to Outputs:
  - red_driver = "bridge" -> null
  - urls       = {
      - blog-g5-staging   = "http://localhost:8202"
      - docs-g5-staging   = "http://localhost:8203"
      - tienda-g5-staging = "http://localhost:8201"
    } -> null
```

`prod`
```
$ terraform workspace select prod
Switched to workspace "prod".

$ terraform plan -destroy -out=fase9-prod.tfplan
Terraform will perform the following actions:

  # module.sitio["blog"].docker_container.this will be destroyed
  # module.sitio["blog"].docker_image.this will be destroyed
  # module.sitio["docs"].docker_container.this will be destroyed
  # module.sitio["docs"].docker_image.this will be destroyed
  # module.sitio["tienda"].docker_container.this will be destroyed
  # module.sitio["tienda"].docker_image.this will be destroyed
  [...]

Plan: 0 to add, 0 to change, 6 to destroy.

Changes to Outputs:
  - red_driver = "bridge" -> null
  - urls       = {
      - blog-g5-prod   = "http://localhost:8302"
      - docs-g5-prod   = "http://localhost:8303"
      - tienda-g5-prod = "http://localhost:8301"
    } -> null
```

`terraform apply` de cada plan aprobado, en el orden `dev`, `staging`, `prod`
```
$ terraform workspace select dev
Switched to workspace "dev".

$ terraform apply fase9-dev.tfplan
module.sitio["tienda"].docker_container.this: Destroying... [id=7b333687fe836d76f7b6cac44f7b3ca7a4dda91cc0a08e55af2ac66e24b5d1d3]
module.sitio["tienda"].docker_container.this: Destruction complete after 1s
module.sitio["tienda"].docker_image.this: Destroying... [id=sha256:a8b39bd9cf0f83869a2162827a0caf6137ddf759d50a171451b335cecc87d236nginx:1.28-alpine]
module.sitio["tienda"].docker_image.this: Destruction complete after 0s

Apply complete! Resources: 0 added, 0 changed, 2 destroyed.
[exit 0]

$ terraform state list   (workspace dev, debe quedar vacío)
[exit 0]

$ docker ps --filter name=g5
NAMES               IMAGE                STATUS          PORTS
docs-g5-prod        65645c7bb6a0         Up 29 minutes   0.0.0.0:8303->80/tcp
tienda-g5-prod      65645c7bb6a0         Up 29 minutes   0.0.0.0:8301->80/tcp
blog-g5-prod        65645c7bb6a0         Up 29 minutes   0.0.0.0:8302->80/tcp
tienda-g5-staging   a8b39bd9cf0f         Up 30 minutes   0.0.0.0:8201->80/tcp
docs-g5-staging     a8b39bd9cf0f         Up 30 minutes   0.0.0.0:8203->80/tcp
blog-g5-staging     a8b39bd9cf0f         Up 30 minutes   0.0.0.0:8202->80/tcp
tf-state-g5         postgres:17-alpine   Up 43 minutes   127.0.0.1:5436->5432/tcp
```
```
$ terraform workspace select staging
Switched to workspace "staging".

$ terraform apply fase9-staging.tfplan
module.sitio["blog"].docker_container.this: Destroying... [id=616fbfaa90cefaa258fc4a9f0bdec9d4495d90f659995bcd16bb01e796017cb1]
module.sitio["tienda"].docker_container.this: Destroying... [id=cf2c3074ee4512f1eaeecec406aa8cc88a4a3758eb6c3808a9c332a9186e3ac9]
module.sitio["docs"].docker_container.this: Destroying... [id=22f52013c97fabae75323d32710881377e33f512e0a5e3aed6b1629e797243d0]
[...]
Apply complete! Resources: 0 added, 0 changed, 6 destroyed.
[exit 0]

$ terraform state list   (workspace staging, debe quedar vacío)
[exit 0]

$ docker ps --filter name=g5
NAMES            IMAGE                STATUS          PORTS
docs-g5-prod     65645c7bb6a0         Up 29 minutes   0.0.0.0:8303->80/tcp
tienda-g5-prod   65645c7bb6a0         Up 29 minutes   0.0.0.0:8301->80/tcp
blog-g5-prod     65645c7bb6a0         Up 29 minutes   0.0.0.0:8302->80/tcp
tf-state-g5      postgres:17-alpine   Up 44 minutes   127.0.0.1:5436->5432/tcp
```
```
$ terraform workspace select prod
Switched to workspace "prod".

$ terraform apply fase9-prod.tfplan
module.sitio["blog"].docker_container.this: Destroying... [id=3c9810e14c6336ed68e60b06a42f71a07c8ce6cf5344b8b7bdb7b20beea66c8f]
module.sitio["docs"].docker_container.this: Destroying... [id=2a3693f53accf428b3884c7480852f209ff90021d4939a65fefcb08a2d3fd83c]
module.sitio["tienda"].docker_container.this: Destroying... [id=34405751e181792342d308659edc9661bdb45a84d83d1a2d87200613898b8b97]
[...]
Apply complete! Resources: 0 added, 0 changed, 6 destroyed.
[exit 0]

$ terraform state list   (workspace prod, debe quedar vacío)
[exit 0]

$ terraform workspace select default
Switched to workspace "default".

$ terraform workspace list
* default
  dev
  prod
  staging
```

`docker ps` con solo el backend (antes de eliminarlo)
```
$ docker ps --filter name=g5
NAMES         IMAGE                STATUS          PORTS
tf-state-g5   postgres:17-alpine   Up 45 minutes   127.0.0.1:5436->5432/tcp
```

Eliminación del backend (solo después de los tres `destroy`) y `docker ps` final
```
$ docker rm -f tf-state-g5
tf-state-g5

$ docker ps -a --filter name=g5
NAMES     IMAGE     STATUS
```
Ya no queda ningún contenedor del grupo: ni `web-g5`, ni los sitios, ni `clickops`, ni `prueba-g5`, ni `tf-state-g5`.

**Aprobación del revisor (por cada destroy):**
- `dev` — Aprobado (Revisor Samuel): Plan: 0 a crear, 0 a cambiar, 2 a destruir.
- `staging` — Aprobado (Revisor Samuel): Plan: 0 a crear, 0 a cambiar, 6 a destruir.
- `prod` — Aprobado (Revisor Samuel): Plan: 0 a crear, 0 a cambiar, 6 a destruir.

### Respuestas
1. ¿Qué anti-patrón encontraron en el otro grupo? ¿Y cuál les señalaron a ustedes?

Al grupo 2 le encontramos incumplido «Aplicar sin leer el plan», en dos puntos: un `terraform apply` sin cambios en su Fase 3 (`BITACORA.md`, líneas 357 a 365) sin aprobación anotada, y la prueba `despliegue_real` de su Fase 8, que crea y destruye un contenedor de verdad sin línea `Plan:` ni aprobación del revisor. Los otros cinco los cumplen; en secretos con una reserva, porque no tenemos su contraseña real y no pudimos buscarla literalmente. También vimos que su nota de la línea 1182 dice que buscar la contraseña de ejemplo de la guía «siempre dará vacío», pero `git log -p -S` con esa contraseña devuelve el commit `838b57d` por esa misma nota, que escribe el literal (no es una fuga). Del otro lado, la auditoría del grupo 2 a nuestro repositorio no nos señala el incumplimiento de ninguno de los seis anti-patrones: los marca como cumplidos, con la misma reserva en secretos (no tenían la contraseña real para buscarla literalmente). Lo que sí nos señala son dos hallazgos, y los dos son ciertos. El primero es código muerto y etiquetas que se perdieron al pasar al módulo: el local `etiquetas` está definido y no lo usa nadie (`infra/locals.tf`, líneas 20 a 23), la variable raíz `imagen` quedó sin uso desde la Fase 7 (`infra/variables.tf`, líneas 6 a 10, porque `infra/main.tf:24` toma la imagen de `local.amb.imagen`), y el contenedor del módulo no tiene `labels`, aunque en la Fase 5 sí los tuvo (`BITACORA.md`, líneas 910 y 914); lo comprobamos, y `terraform validate` no avisa de nada de esto. El segundo es que la evidencia de secretos y del bloqueo no se puede reproducir tal como está escrita: `git grep <CLAVE>` y `git log --all -p -S<CLAVE>` quedaron con el marcador literal, así que quien los copie buscará esa cadena y obtendrá «sin resultados» sin que eso pruebe nada, y las dos «terminales» del bloqueo fueron dos procesos lanzados desde un mismo script, como ya dice nuestra propia bitácora. No es una fuga ni un incumplimiento, pero un revisor tiene que creernos en lugar de poder verificarlo. Su recomendación es enchufar las etiquetas por el módulo (una variable `etiquetas` en `modules/sitio_web/variables.tf`, un `dynamic "labels"` en su `main.tf` y la llamada desde `infra/main.tf` con `local.etiquetas`), borrar la variable raíz `imagen` y agregar `tflint` a `validar.sh`, para que su regla de declaraciones sin uso atrape este tipo de descuido. Haríamos exactamente eso y, además, repetiríamos la evidencia de secretos y de bloqueo con comandos que un revisor pueda ejecutar: una contraseña que se le pueda entregar para que la busque de verdad, y dos terminales reales con la salida de cada una. En este entregable no cambiamos el código ni la infraestructura, y no probamos `tflint`, así que no podemos confirmar por nuestra cuenta que esa regla marque las dos piezas sin uso.

2. ¿Qué habría pasado si eliminaban el contenedor del backend antes de ejecutar los `destroy`?

Terraform no habría podido leer ni escribir el state de ningún ambiente, porque los cuatro states viven dentro de ese Postgres y cada `workspace select`, `plan -destroy` y `apply` empieza por conectarse al backend. Lo vimos en pequeño: cuando `PG_CONN_STR` quedó mal escrita, los seis comandos fallaron con `net/url: invalid userinfo` antes de tocar nada, ni siquiera se pudo seleccionar el workspace. Sin backend no se habría podido destruir nada con Terraform y los siete sitios y sus imágenes habrían quedado huérfanos en Docker, sin registro de que los creó Terraform, y habría que borrarlos a mano. Por eso eliminamos `tf-state-g5` al final, después de los tres `destroy` y de comprobar con `docker ps` que no quedaba nada más del grupo (Díaz Bautista, s. f.; HashiCorp, s. f.-e).

3. ¿Por qué `destroy` exige la misma disciplina de lectura que `apply`?

Porque `destroy` también se aplica sin vuelta atrás: borra infraestructura real, y ejecutarlo en el workspace equivocado habría borrado, por ejemplo, `prod`. Por eso antes de cada uno se leyó el plan: `dev` con `Plan: 0 to add, 0 to change, 2 to destroy` y `staging` y `prod` con 6 a destruir cada uno, con los nombres y puertos de los sitios, y se confirmó con `workspace select` el ambiente correcto. Además aplicamos el plan guardado (`terraform apply fase9-<ambiente>.tfplan`), de modo que se destruyó exactamente lo aprobado y nada más. La regla de no aplicar sin leer el plan incluye lo que se va a destruir (Díaz Bautista, s. f.).

---

## Referencias

Díaz Bautista, R. D. (s. f.). *Infraestructura como código: Fundamentos, módulos, testing y operación en producción* [Diapositivas del Tema VII]. Arquitectura de Software II, Corporación Universitaria Empresarial Alexander von Humboldt.

HashiCorp. (s. f.-a). *Purpose of Terraform state*. Terraform Language Documentation. https://developer.hashicorp.com/terraform/language/state/purpose

HashiCorp. (s. f.-b). *Dependency lock file*. Terraform Language Documentation. https://developer.hashicorp.com/terraform/language/files/dependency-lock

HashiCorp. (s. f.-c). *Manage sensitive data in your configuration*. Terraform Language Documentation. https://developer.hashicorp.com/terraform/language/manage-sensitive-data

HashiCorp. (s. f.-d). *Use input variables to add module arguments*. Terraform Language Documentation. https://developer.hashicorp.com/terraform/language/values/variables

HashiCorp. (s. f.-e). *Backend type: pg*. Terraform Language Documentation. https://developer.hashicorp.com/terraform/language/backend/pg

HashiCorp. (s. f.-f). *Write Terraform tests*. Terraform Language Documentation. https://developer.hashicorp.com/terraform/language/tests

---

## Declaración de uso de inteligencia artificial

En la realización de este taller se utilizó inteligencia artificial (Claude, de Anthropic) como herramienta de apoyo.
