output "url" {
  value = "http://localhost:${var.puerto}"
}

# TODO 4 resuelto
output "contenedor" {
  description = "Nombre real del contenedor creado"
  value       = docker_container.web.name
}

# TODO 5 resuelto
output "red_driver" {
  description = "Driver de la red que lee el data source"
  value       = data.docker_network.bridge.driver
}
