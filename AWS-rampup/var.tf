variable "AWS_ACCESS_KEY" {}
variable  "AWS_SECRET_KEY" {}
variable  "AWS_REGION" {}

variable "AMIS" {
    type = map
    default = {
        us-east-1 = "ami-04902260ca3d33422"
        us-east-2 = "ami-0d718c3d715cec4a7"
        us-west-1 = "ami-0d5075a2643fdf738"
    }
}