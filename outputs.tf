output "vpc_id" {
  description = "VPC ID"
  value       = yandex_vpc_network.network.id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = yandex_vpc_subnet.public.id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = yandex_vpc_subnet.private.id
}

output "nat_private_ip" {
  description = "NAT instance private IP"
  value       = yandex_compute_instance.nat.network_interface[0].ip_address
}

output "nat_public_ip" {
  description = "NAT instance public IP"
  value       = yandex_compute_instance.nat.network_interface[0].nat_ip_address
}

output "bastion_private_ip" {
  description = "Bastion private IP"
  value       = yandex_compute_instance.bastion.network_interface[0].ip_address
}

output "bastion_public_ip" {
  description = "Bastion public IP"
  value       = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}

output "private_vm_ip" {
  description = "Private VM internal IP"
  value       = yandex_compute_instance.private.network_interface[0].ip_address
}
