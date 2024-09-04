{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowExecuteCommand",
      "Effect": "Allow",
      "Action": [
          "ecs:ExecuteCommand"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "AllowSSMMessages",
      "Effect": "Allow",
      "Action": [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "Allow2PushLogs",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": [
        "arn:aws:logs:*:*:*"
      ]
    },
    {
      "Sid": "AllowS3Operations",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": ${s3_resources}
    },
    {
      "Sid": "AllowToGetSrcFromS3",
      "Action": ["s3:Get*", "s3:List*"],
      "Effect": "Allow",
      "Resource": ["*"]
    }
  ]
}
