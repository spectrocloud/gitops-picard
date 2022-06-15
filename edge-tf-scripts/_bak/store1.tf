module "edge-001-ca-sj" {
  source = "./modules/edge"

  # Store Number/Location
  name = "edge-001-ca-sj"

  tags = {
    state = "Ca"
    city = "San Jose"
    type = "cafe"
    stage = "false"
    latlng = "37.366519,-121.919364"
  }

  # # Github Branch
  # branch = "dev"

  # Device UUIDs to be added
  device_uuid = [
    "8e4f1c2f85d4",
    "8e4f1c2f85d5",
    "33426b57d3ee"
  ]
  # Profiles to be added
  cluster_profiles = [
    { name = "store-edge-infra"
      tag  = "2.0.0"
      # packs = [
      #   {
      #     name = "opensuse-k3s"
      #     tag  = "1.21.12-k3s0"
      #     # values = file(local.value_files["k3s_config"].location)
      #   }
      # ]
    },
    {
      name = "store-edge-apps-base"
      tag  = "1.5.0"
    }
  ]
}
