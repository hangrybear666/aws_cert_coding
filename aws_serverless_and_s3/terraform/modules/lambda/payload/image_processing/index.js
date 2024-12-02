const AWS = require("aws-sdk");

exports.handler = async (event) => {
  try {
    // Check if the request body exists
    if (!event.body) {
      return {
        statusCode: 400,
        body: JSON.stringify({ message: "No file found in the request body." }),
      };
    }

    // Decode the base64-encoded image file from the request body
    const isBase64Encoded = event.isBase64Encoded || false;
    const fileBuffer = isBase64Encoded
      ? Buffer.from(event.body, "base64")
      : Buffer.from(event.body);

    // Log the file size
    console.log(`File size: ${fileBuffer.length} bytes`);

    // Log the file name if provided in headers (e.g., "x-filename" header)
    const fileName = event.headers?.["x-filename"] || "Unknown filename";
    console.log(`File name: ${fileName}`);

    // Return success response
    return {
      statusCode: 200,
      body: JSON.stringify({
        message: "File received successfully.",
        fileName: fileName,
        fileSize: `${fileBuffer.length} bytes`,
      }),
    };
  } catch (error) {
    console.error("Error processing the file:", error);

    return {
      statusCode: 500,
      body: JSON.stringify({ message: "Internal Server Error", error: error.message }),
    };
  }
};