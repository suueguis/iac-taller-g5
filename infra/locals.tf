locals {
  nombre = "web-g${var.grupo}"

  html = <<-EOT
    <h1>${var.mensaje}</h1>
    <p>Desplegado con Terraform por el grupo ${var.grupo}</p>
  EOT

  # TODO 2 resuelto
  etiquetas = {
    curso = "arquitectura-sw-2"
    grupo = tostring(var.grupo)
  }
}
