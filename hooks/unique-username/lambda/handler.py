"""
AWS Lambda function for Okta Import Inline Hook - Unique Username Generation

This Lambda ensures unique usernames during user imports. When a username
conflict is detected, it appends a random 4-character suffix to the login
(e.g., john.doe@example.com -> john.doe.x7k2@example.com).

Environment Variables:
    OKTA_ORG_URL: Okta org URL (e.g., https://demo-netappdemo.oktapreview.com)
    OKTA_API_TOKEN_SECRET: Name of Secrets Manager secret containing Okta API token
"""

import json
import logging
import os
import random
import string
import urllib.request
import urllib.error
import urllib.parse
import boto3
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Environment variables
OKTA_ORG_URL = os.environ.get('OKTA_ORG_URL', '')
OKTA_API_TOKEN_SECRET = os.environ.get('OKTA_API_TOKEN_SECRET', 'okta-api-token')

# Cache for Okta API token (persists across warm Lambda invocations)
_okta_api_token = None

# Random suffix characters (lowercase + digits, no ambiguous chars)
SUFFIX_CHARS = string.ascii_lowercase + string.digits
SUFFIX_LENGTH = 4
MAX_ATTEMPTS = 5


def get_okta_api_token():
    """Retrieve Okta API token from Secrets Manager (cached)."""
    global _okta_api_token
    if _okta_api_token:
        return _okta_api_token

    try:
        client = boto3.client('secretsmanager')
        response = client.get_secret_value(SecretId=OKTA_API_TOKEN_SECRET)
        _okta_api_token = response['SecretString']
        return _okta_api_token
    except ClientError as e:
        logger.error(f"Failed to retrieve Okta API token: {e}")
        raise


def generate_random_suffix():
    """Generate a random 4-character alphanumeric suffix."""
    return ''.join(random.choices(SUFFIX_CHARS, k=SUFFIX_LENGTH))


def check_login_exists(login):
    """
    Check if a user with the given login already exists in Okta.

    Args:
        login: The login (username) to check

    Returns:
        tuple: (exists: bool, error_message: str or None)
    """
    if not login:
        return False, None

    if not OKTA_ORG_URL:
        logger.error("OKTA_ORG_URL environment variable not set")
        return False, "Lambda configuration error: OKTA_ORG_URL not set"

    try:
        api_token = get_okta_api_token()

        # Search for user by login
        encoded_login = urllib.parse.quote(login)
        url = f"{OKTA_ORG_URL}/api/v1/users?filter=profile.login%20eq%20%22{encoded_login}%22&limit=1"

        req = urllib.request.Request(url)
        req.add_header('Authorization', f'SSWS {api_token}')
        req.add_header('Accept', 'application/json')

        with urllib.request.urlopen(req, timeout=10) as response:
            users = json.loads(response.read().decode())

            if users and len(users) > 0:
                logger.info(f"Login already exists: {login}")
                return True, None
            else:
                logger.info(f"Login is available: {login}")
                return False, None

    except urllib.error.HTTPError as e:
        error_body = e.read().decode() if e.fp else str(e)
        logger.error(f"Okta API error: {e.code} - {error_body}")
        return False, f"Error checking login: HTTP {e.code}"
    except urllib.error.URLError as e:
        logger.error(f"Network error calling Okta API: {e}")
        return False, f"Network error checking login: {str(e)}"
    except Exception as e:
        logger.error(f"Unexpected error checking login: {e}")
        return False, f"Unexpected error: {str(e)}"


def make_unique_login(original_login):
    """
    Generate a unique login by appending a random suffix.

    Takes john.doe@example.com and produces john.doe.x7k2@example.com

    Args:
        original_login: The original login/username

    Returns:
        str: A new login with random suffix inserted before the @ symbol
    """
    if '@' in original_login:
        local_part, domain = original_login.rsplit('@', 1)
        suffix = generate_random_suffix()
        return f"{local_part}.{suffix}@{domain}"
    else:
        suffix = generate_random_suffix()
        return f"{original_login}.{suffix}"


def handler(event, context):
    """
    AWS Lambda handler for Okta Import Inline Hook.

    Checks if the imported user's login already exists in Okta.
    If it does, generates a unique login with a random suffix.

    Args:
        event: API Gateway event containing inline hook payload
        context: Lambda context

    Returns:
        dict: API Gateway response with inline hook commands
    """
    logger.info(f"Received event: {json.dumps(event)}")

    try:
        # Parse the request body
        if isinstance(event.get('body'), str):
            body = json.loads(event['body'])
        else:
            body = event.get('body', event)

        # Handle Okta verification request (one-time setup)
        if body.get('verificationValue'):
            logger.info("Responding to Okta verification request")
            return {
                "statusCode": 200,
                "headers": {"Content-Type": "application/json"},
                "body": json.dumps({"verification": body['verificationValue']})
            }

        # Extract user data from inline hook payload
        # For Generic DB connector, the profile fields differ from standard SCIM:
        #   data.user.profile.login       = Okta user login (often the external ID)
        #   data.appUser.profile.ext_userName = actual DB username
        #   data.appUser.profile.userName = SCIM userName (external ID)
        data = body.get('data', {})
        app_user = data.get('appUser', {})
        app_profile = app_user.get('profile', {})
        user = data.get('user', {})
        user_profile = user.get('profile', {})

        # Use the Okta user login, falling back to ext_userName from app profile
        original_login = (
            user_profile.get('login')
            or app_profile.get('ext_userName')
            or app_profile.get('login')
            or ''
        )
        user_email = user_profile.get('email') or app_profile.get('ext_email') or 'unknown'

        logger.info(f"Checking username uniqueness for: {original_login} (email: {user_email})")

        if not original_login:
            logger.warning("No login found in profile, skipping")
            return {
                "statusCode": 204,
                "headers": {"Content-Type": "application/json"},
                "body": ""
            }

        # Check if login already exists
        exists, error = check_login_exists(original_login)

        if error:
            logger.error(f"Error checking login existence: {error}")
            # On error, allow the import to proceed without modification
            return {
                "statusCode": 204,
                "headers": {"Content-Type": "application/json"},
                "body": ""
            }

        if not exists:
            # Login is unique, no modification needed
            logger.info(f"Login {original_login} is unique, no changes needed")
            return {
                "statusCode": 204,
                "headers": {"Content-Type": "application/json"},
                "body": ""
            }

        # Login conflict found - generate a unique alternative
        new_login = None
        for attempt in range(1, MAX_ATTEMPTS + 1):
            candidate = make_unique_login(original_login)
            candidate_exists, check_error = check_login_exists(candidate)

            if check_error:
                logger.warning(f"Error checking candidate {candidate}: {check_error}")
                continue

            if not candidate_exists:
                new_login = candidate
                logger.info(f"Found unique login on attempt {attempt}: {candidate}")
                break

            logger.info(f"Candidate {candidate} also exists, retrying (attempt {attempt}/{MAX_ATTEMPTS})")

        if not new_login:
            logger.error(f"Failed to generate unique login after {MAX_ATTEMPTS} attempts for {original_login}")
            # Return error to block the import
            error_response = {
                "error": {
                    "errorSummary": "Unable to generate unique username",
                    "errorCauses": [
                        {
                            "errorSummary": f"Could not generate a unique login for {original_login} after {MAX_ATTEMPTS} attempts",
                            "reason": "USERNAME_CONFLICT"
                        }
                    ]
                }
            }
            return {
                "statusCode": 200,
                "headers": {"Content-Type": "application/json"},
                "body": json.dumps(error_response)
            }

        # Return command to update the login
        logger.info(f"Updating login: {original_login} -> {new_login}")
        response_body = {
            "commands": [
                {
                    "type": "com.okta.user.profile.update",
                    "value": {
                        "login": new_login
                    }
                }
            ]
        }

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(response_body)
        }

    except Exception as e:
        logger.error(f"Lambda error: {e}", exc_info=True)

        error_response = {
            "error": {
                "errorSummary": "Internal hook error",
                "errorCauses": [
                    {
                        "errorSummary": f"Lambda error: {str(e)}",
                        "reason": "INTERNAL_ERROR"
                    }
                ]
            }
        }

        return {
            "statusCode": 200,  # Okta expects 200 even for errors
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(error_response)
        }


# For local testing
if __name__ == "__main__":
    test_event = {
        "body": json.dumps({
            "data": {
                "appUser": {
                    "profile": {
                        "login": "john.doe@example.com",
                        "email": "john.doe@example.com",
                        "firstName": "John",
                        "lastName": "Doe"
                    }
                }
            }
        })
    }

    result = handler(test_event, None)
    print(json.dumps(json.loads(result.get('body', '{}') or '{}'), indent=2))
