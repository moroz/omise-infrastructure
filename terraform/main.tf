module "uploads" {
  source = "./modules/static-cdn"

  for_each    = toset(var.environments)
  bucket_name = "${var.project_name}-${each.key}-uploads"
}
