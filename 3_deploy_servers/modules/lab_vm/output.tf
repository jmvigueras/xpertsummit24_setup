output "vm" {
  value = {
    //vm_id      = var.iam_profile == null ? aws_instance.vm.*.id[0] : aws_instance.vm_iam_profile.*.id[0]
    adminuser  = var.linux_os == "ubuntu" ? "ubuntu" : "ec2-user"
    private_ip = aws_instance.vm.private_ip
    //public_ip  = var.public_ip ? var.iam_profile == null ? aws_instance.vm.*.public_ip[0] : aws_instance.vm_iam_profile.*.public_ip[0] : ""
  }
}