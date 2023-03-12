data "aws_iam_policy_document" "lambda_role_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-lambdaRole-waf"
  assume_role_policy = data.aws_iam_policy_document.lambda_role_policy.json
}
 
# Arquive the script
data "archive_file" "this" {
  type = "zip"
  source_file = "./etc/lambda-functions/hello-world.py"
  output_path = "hello-world.zip"
}

# Create the lamda function
resource "aws_lambda_function" "this" {
    function_name = "lambdaTest"
    
    filename      = "hello-world.zip"
    source_code_hash = data.archive_file.this.output_base64sha256
    role          = aws_iam_role.lambda_role.arn
    runtime       = "python3.9"
    handler       = "hello-world.lambda_handler"
    timeout       = 10
}