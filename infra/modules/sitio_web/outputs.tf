output "url" {
  description = "URL del sitio"
  value       = "http://localhost:${var.puerto}"
}

output "nombre" {
  description = "Nombre real del contenedor"
  value       = docker_container.this.name
}
