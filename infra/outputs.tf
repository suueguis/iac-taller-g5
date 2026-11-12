output "red_driver" {
  description = "Driver de la red que lee el data source"
  value       = data.docker_network.bridge.driver
}

# TODO 2 resuelto
output "urls" {
  description = "URL de los tres sitios"
  value = [
    module.tienda.url,
    module.blog.url,
    module.docs.url,
  ]
}
