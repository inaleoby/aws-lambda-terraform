
resource "aws_iam_role" "lambda1_role" {
    name = "MoveToS3MiddleRole"
    assume_role_policy = jsonencode({ # This policy allows AWS Lambda to assume this role
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_policy" "lambda1_policy" {
    name = "MoveToS3MiddlePolicy"
    policy = jsonencode({
        Version = "2012-10-17"
        # Allow Lambda to get and delete objects from the source bucket
        Statement = [
            {
                Action = [
                    "s3:GetObject",
                    "s3:DeleteObject",
                ]
                Effect = "Allow"
                Resource = [
                    aws_s3_bucket.bucket_source.arn,
                    "${aws_s3_bucket.bucket_source.arn}/*",
                ]
            },

            {
                Action = [
                    "s3:PutObject",
                ]
                Effect = "Allow"
                Resource = [
                    aws_s3_bucket.bucket_middle.arn,
                    "${aws_s3_bucket.bucket_middle.arn}/*",
                ]

            },

            {
               Action = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents",
                ]
                Effect = "Allow"
                Resource = "arn:aws:logs:*:*:*"
            }
        ]
     
    })
}

# Attach the plicy to the role MoveToS3MiddleRole
resource "aws_iam_role_policy_attachment" "lambda1_policy_attachment" {
    role = aws_iam_role.lambda1_role.name
    policy_arn = aws_iam_policy.lambda1_policy.arn
}



resource "aws_iam_role" "lambda2_role" {
    name = "MoveToS3DestinationRole"
    assume_role_policy = jsonencode({ # This policy allows AWS Lambda to assume this role
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
            }
        ]
    })
  
}


resource "aws_iam_policy" "lambda2_policy" {
    name = "MoveToS3DestinationPolicy"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            
            {
                Action = [
                    "s3:GetObject",
                ]
                Effect = "Allow"
                Resource = [
                    aws_s3_bucket.bucket_middle.arn,
                    "${aws_s3_bucket.bucket_middle.arn}/*",
                ]
            },

            {

                Action = [
                    "s3:PutObject",
                ]
                Effect = "Allow"
                Resource = [
                    aws_s3_bucket.bucket_destination.arn,
                    "${aws_s3_bucket.bucket_destination.arn}/*",
                ]
            },

            {
               Action = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents",
                ]
                Effect = "Allow"
                Resource = "arn:aws:logs:*:*:*"

            }
        ]
    })
}

# Attach the policy to the role MoveToS3DestinationRole
resource "aws_iam_role_policy_attachment" "lambda2_policy_attachment" {
    role = aws_iam_role.lambda2_role.name
    policy_arn = aws_iam_policy.lambda2_policy.arn
}




