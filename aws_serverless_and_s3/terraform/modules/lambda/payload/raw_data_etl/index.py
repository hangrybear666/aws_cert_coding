import os
import json
import base64
import tempfile
import requests # not in aws runtime
from openpyxl import load_workbook # not in aws runtime

def handler(event, context):
  ALLOW_IP_BASED_ACCESS = False

  body = event["body"]
  headers = event["headers"]
  contentLength = int(headers.get('Content-Length'))
  authorization = headers.get('authorization', None)
  requestIp = headers.get('X-Forwarded-For')
  # block access if payload is empty
  if body == None or contentLength == 0:
    return {
      "statusCode": 422,
      "body": json.dumps({"message": "please provide a payload. Received empty request body."})
    }
  # block access if authorization header does not include the API TOKEN
  apiKeyEnvStr = os.getenv('API_KEY')
  if authorization == None or apiKeyEnvStr == None or authorization != apiKeyEnvStr:
    return {
      "statusCode": 403,
      "body": json.dumps({"message": "Invalid authorization header."})
    }
  # block access if requesting IP-address is not whitelisted
  ipWhitelistEnvStr = os.getenv('IP_WHITELIST')
  if ipWhitelistEnvStr == None or ipWhitelistEnvStr == "":
    return {
      "statusCode": 422,
      "body": json.dumps({"message": "ip address whitelist not found among environment variables."})
    }
  ipWhitelist = ipWhitelistEnvStr.split(",")
  if len(ipWhitelist) == 1 and ipWhitelist[0] == "0.0.0.0":
    ALLOW_IP_BASED_ACCESS = True
  elif len(ipWhitelist) > 1:
    for ip in ipWhitelist:
      if requestIp == ip:
        ALLOW_IP_BASED_ACCESS = True
  if not ALLOW_IP_BASED_ACCESS:
    return {
      "statusCode": 403,
      "body": json.dumps({"message": "IP based access denied."})
    }
  decodedBytes = base64.b64decode(body)
  decodedBody = decodedBytes.decode("utf-8")
  extracedEventKeys = {
    "path" : event["path"],
    "forwardedFor" : headers.get('X-Forwarded-For'),
    "contentLength" : contentLength,
    "body": event["body"],
    "ipWhitelist": ipWhitelist,
    "decodedBody" : decodedBody
  }
  return {"statusCode": 200,
          "body": json.dumps({
            "eventKeys": extracedEventKeys
          })}
  try:
    # Get the Google Sheets public link from the event
    sheet_url = event.get("sheet_url")
    if not sheet_url:
      return {
        "statusCode": 400,
        "body": json.dumps({"error": "Missing 'sheet_url' in the event"})
      }
    # Generate download link for Excel format
    if "docs.google.com/spreadsheets" in sheet_url:
      if "/edit" in sheet_url:
        sheet_url = sheet_url.replace("/edit", "/export?format=xlsx")
      elif "?usp=sharing" in sheet_url:
        sheet_url = sheet_url.replace("?usp=sharing", "/export?format=xlsx")
    else:
      return {
        "statusCode": 400,
        "body": json.dumps({"error": "Invalid Google Sheets link"})
      }

    # Download the file
    response = requests.get(sheet_url)
    print(response)
    if response.status_code != 200:
      return {
        "statusCode": 500,
        "body": json.dumps({"error": "Failed to download the sheet"})
      }
    # Save to a temporary file
    with tempfile.NamedTemporaryFile(delete=False, suffix=".xlsx") as temp_file:
        temp_file.write(response.content)
        temp_filename = temp_file.name

    # Open the file and list sheets
    workbook = load_workbook(filename=temp_filename)
    sheet_names = workbook.sheetnames

    return {
      "statusCode": 200,
      "body": json.dumps({"sheets": sheet_names})
    }

  except Exception as e:
    return {
        "statusCode": 500,
        "body": json.dumps({"error": str(e)})
    }
