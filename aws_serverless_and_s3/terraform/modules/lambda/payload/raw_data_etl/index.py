import json
import base64
import tempfile
import requests # not in aws runtime
from openpyxl import load_workbook # not in aws runtime

def handler(event, context):
  body = event["body"]
  headers = event["headers"]
  contentLength = int(headers.get('Content-Length'))

  if event["body"] == None or contentLength == 0:
    return {
      "statusCode": 422,
      "body": json.dumps({"message": "please provide a payload. Received empty request body."})
    }
  encoded_string = "aGVsbG8gd29ybGQ="  # base64-encoded "hello world"
  decoded_bytes = base64.b64decode(encoded_string)
  decoded_string = decoded_bytes.decode("utf-8")
  extracedEventKeys = {
    "path" : event["path"],
    "authorization" : event["headers"].get('authorization', None),
    "forwardedFor" : headers.get('X-Forwarded-For'),
    "contentLength" : contentLength,
    "body": event["body"],
    "decodedBody" : decoded_string
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
