variable "cluster_name" {
  type    = string
  default = "mikes-cluster"
}

variable "region" {
  type    = string
  default = "us-east-2"
}

variable "subnet_ids" {
  type    = list(string)
  default = [
    "subnet-02fade20759ea9048",
    "subnet-0476b7fa27309a259",
    "subnet-01da20e70684fdc33",
  ]
}
