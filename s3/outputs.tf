output "s3_id"{
    value = aws_s3_bucket.app_s3.id
}
output "s3_url"{
    value= aws_s3_bucket_website_configuration.my-static-website.website_endpoint
}