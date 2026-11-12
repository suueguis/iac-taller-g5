#!/usr/bin/env bash
set -e
terraform -chdir=infra fmt -check -recursive
terraform -chdir=infra validate
# TODO 2 resuelto: pruebas del módulo
terraform -chdir=infra/modules/sitio_web test
# TODO 3 resuelto: solo la política del equipo, "sin buckets públicos"
checkov -d seguridad --check CKV_AWS_53,CKV_AWS_54,CKV_AWS_55,CKV_AWS_56
echo "Validación completa: el cambio puede pasar a revisión"
