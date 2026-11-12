# Archivo de práctica sobre AWS: nunca se aplica, solo se escanea.
# PASO 1: escanear tal cual (los cuatro valores en false).
# PASO 2: cambiar los cuatro valores a true y escanear de nuevo.
resource "aws_s3_bucket" "evidencias" {
  bucket = "evidencias-grupo-5"
}

resource "aws_s3_bucket_public_access_block" "evidencias" {
  bucket                  = aws_s3_bucket.evidencias.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
