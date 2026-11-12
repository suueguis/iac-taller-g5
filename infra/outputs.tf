output "red_driver" {
  description = "Driver de la red que lee el data source"
  value       = data.docker_network.bridge.driver
}

# TODO 3 resuelto: mapa nombre => url recorriendo module.sitio
output "urls" {
  description = "URL de cada sitio del ambiente activo"
  value       = { for k, m in module.sitio : m.nombre => m.url }
}
