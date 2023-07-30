import json

def lambda_handler(event, context):
  # You can add more complex logic here to check the status of your system.
  # For simplicity, we'll just return a static status in this example.
  status = "ok"

  response = {
      "statusCode": 200,
      "body": json.dumps({"status": status}),
      "headers": {
          "Content-Type": "application/json"
      }
  }

  return response