import json
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext
from random_username.generate import generate_username

logger = Logger()


@logger.inject_lambda_context(log_event=True)
def lambda_handler(event: dict, context: LambdaContext) -> dict:
    username = generate_username(1)[0]

    logger.info(username)

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": username
        }),
    }
