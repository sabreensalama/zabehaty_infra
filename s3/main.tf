resource "aws_s3_bucket" "app_s3" {
  bucket = var.bucket_name

  tags = {
    Name        = "zabehaty_static_s3"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.app_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_website_configuration" "my-static-website" {
  bucket = aws_s3_bucket.app_s3.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}
# S3 bucket policy
 
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.app_s3.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "*"
        ]},
      "Action": [  "s3:GetObject" ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.app_s3.bucket}/*"

      ]
    }
  ]
}
EOF
}