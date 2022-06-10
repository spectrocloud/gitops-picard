module "edge-sanjose" {
  source = "./modules/edge"


  # Store Number/Location
  location = "sanjose"

  # Device UUIDs to be added
  # Virtualbox
  # device_uuid = [
  #   "c77c3759962b",
  #   "8f22d143249d",
  #   "3333dde37582"
  # ]

  # Baremetal
  # p6os-4: 1c697a091202
  device_uuid = [
    "1c697a091152",
    "d45ddf00d90c",
    "54b2030910d0"
  ]

  # Profiles to be added
  infra_profile = "md-edge-infra"
  app_profile   = "md-edge-apps"
}
