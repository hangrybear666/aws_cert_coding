def lambda_handler(event, context):
  message = 'Hello from image_processing {} !'.format(event['key1'])
  return {
    'message' : message
  }