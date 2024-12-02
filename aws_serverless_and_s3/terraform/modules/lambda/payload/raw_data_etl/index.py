def handler(event, context):
  message = 'Hello from raw_data_etl {} !'.format(event['key1'])
  return {
    'message' : message
  }