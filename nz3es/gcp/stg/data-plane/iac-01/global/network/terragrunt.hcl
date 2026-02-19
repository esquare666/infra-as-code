include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "network" {
  path = "${get_repo_root()}/modules/network/terragrunt.hcl"
}

inputs = {
  project_id   = include.root.locals.project_id
  network_name = format("%s-%s", include.root.locals.environment, include.root.locals.project)

  subnets = [
    {
      subnet_name   = "ause2"
      subnet_ip     = "10.1.0.0/24"
      subnet_region = "australia-southeast2"
    },
    {
      subnet_name   = "ause1"
      subnet_ip     = "10.2.0.0/24"
      subnet_region = "australia-southeast1"
    },
  ]

  secondary_ranges = {
    "ause2" = [
      { range_name = "gke-pods", ip_cidr_range = "10.100.0.0/16" },
      { range_name = "gke-services", ip_cidr_range = "10.200.0.0/20" },
    ]
  }
}
