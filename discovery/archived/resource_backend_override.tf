terraform {
  backend "etcdv3" {
    endpoints =  ["35.203.171.218:2379"]
  }
}
