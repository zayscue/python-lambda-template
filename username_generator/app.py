import json
from random_username.generate import generate_username

def lambda_handler(event, context):

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": generate_username(1)[0]
        }),
    }
