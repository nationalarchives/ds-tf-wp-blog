output "instance_public_ip" {
    value = aws_instance.wp_primer.public_ip
}

output "instance_public_dns" {
    value = aws_instance.wp_primer.public_dns
}

output "instance_private_ip" {
    value = aws_instance.wp_primer.private_ip
}

output "instance_private_dns" {
    value = aws_instance.wp_primer.private_dns
}

output "instance_id" {
    value = aws_instance.wp_primer.id
}

output "instance_arn" {
    value = aws_instance.wp_primer.arn
}