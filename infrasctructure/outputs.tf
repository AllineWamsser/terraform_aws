output "ec2_public_ip" {
  description = "IP public EC2"
  value = aws_instance.grocery_ec2.public_ip
}

output "alb_dns" {
  description = "DNS public Laod Balancer"
  value = aws_lb.app_alb.dns_name
}

output "s3_bucket_name" {
  description = "Name of Bucket S3"
  value = aws_s3_bucket.grocery_bucket.id
}