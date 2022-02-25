# ------------------------------------------------------------------------------
# WCK Key Pair
# ------------------------------------------------------------------------------
resource "aws_key_pair" "wck_keypair" {
  key_name   = var.application
  public_key = local.wck_ec2_data["public-key"]
}

