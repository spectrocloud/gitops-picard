variable "device_uuid" {
  type = list(string)
}

variable "name" {
  type = string
}

variable "tags" {
  type = object({
    state = string
    city = string
    type = string
    latlng = string
    stage = string
  })
}

variable "cluster_profiles" {
  type = list(object({
    name = string
    tag  = optional(string)
    packs = optional(list(object({
      name   = string
      tag    = string
      values = optional(string)
      manifest = optional(list(object({
        name    = string
        tag     = string
        content = string
      })))
    })))
  }))
}
