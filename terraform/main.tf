provider "aws" {
    region = "us-east-1"
  
}

# Creation des 3 buckets S3

resource "aws_s3_bucket" "bucket_source" {
    bucket = "espoir-bucket-source"
    force_destroy = true
    
}

resource "aws_s3_bucket" "bucket_middle" {
    bucket = "espoir-bucket-middle"
    force_destroy = true
    
}

resource "aws_s3_bucket" "bucket_destination" {
    bucket = "espoir-bucket-destination"
    force_destroy = true
    
}

# Bloc de cretion de la fonction lambda1
data "archive_file" "lambda1_zip" {
   type        = "zip"
   source_file = "${path.module}/../lambda/lambda1/moveToS3Function.py"
   output_path = "${path.module}/lambda1.zip"
}

resource "aws_lambda_function" "lambda1" {
    filename         = "${path.module}/lambda1.zip"
    function_name    = "MoveToS3Function"
    role             = aws_iam_role.lambda1_role.arn
    handler          = "moveToS3Function.lambda_handler" # reference utiliser pour trouver le point d'entree de la fonction lambda
    runtime          = "python3.11"
    source_code_hash = data.archive_file.lambda1_zip.output_base64sha256
}


# Configuration de la politique IAM permettant à la fonction lambda1 d'etre invoquée par S3 
# et d'avoir les permissions necessaires pour interagir avec les buckets S3

resource "aws_lambda_permission" "lambda1_s3_permission" {
    statement_id = "AllowS3InvokeLambda1"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda1.function_name
    principal = "s3.amazonaws.com"
    source_arn = aws_s3_bucket.bucket_source.arn
  
}

# Associer la trigger au bucket source pour invoquer la fonction lambda1 
# lors de la creation d'un objet dans le bucket source
resource "aws_s3_bucket_notification" "bucket_source_notification" {
    bucket = aws_s3_bucket.bucket_source.id

    lambda_function {
        lambda_function_arn = aws_lambda_function.lambda1.arn
        events              = ["s3:ObjectCreated:*"]
    }

    depends_on = [aws_lambda_permission.lambda1_s3_permission]
  
}



data "archive_file" "lambda2_zip" {
   type        = "zip"
   source_file = "${path.module}/../lambda/lambda2/CreateThumbnailFunction.py"
   output_path = "${path.module}/lambda2.zip"
}

resource "aws_lambda_function" "lambda2" {
    filename         = "${path.module}/lambda2.zip"
    function_name    = "CreateThumbnailFunction"
    role             = aws_iam_role.lambda2_role.arn
    handler          = "CreateThumbnailFunction.lambda_handler" # reference utiliser pour trouver le point d'entree de la fonction lambda
    runtime          = "python3.11"
    layers = [ "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p311-Pillow:9" ]
    source_code_hash = data.archive_file.lambda2_zip.output_base64sha256
}

resource "aws_lambda_permission" "lambda2_s3_permission" {
    statement_id = "AllowS3InvokeLambda2"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda2.function_name
    principal = "s3.amazonaws.com"
    source_arn = aws_s3_bucket.bucket_middle.arn
  
}


resource "aws_s3_bucket_notification" "bucket_middle_notification" {
    bucket = aws_s3_bucket.bucket_middle.id

    lambda_function {
        lambda_function_arn = aws_lambda_function.lambda2.arn
        events              = ["s3:ObjectCreated:*"]
    }

    depends_on = [aws_lambda_permission.lambda2_s3_permission]
  
}






