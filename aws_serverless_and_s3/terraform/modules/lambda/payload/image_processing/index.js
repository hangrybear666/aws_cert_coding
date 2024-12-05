
const S3 = require("@aws-sdk/client-s3");
const sharp = require("sharp@0.33.5");
const s3Client = new S3.S3Client({
  region: "eu-central-1",
});

const processedImageBucket = "hangrybear-fiscalismia-image-storage";
const bucketObject = {
  "Bucket": processedImageBucket,
  "Key": "heidelbeere.jpg"
}

const listFilesInBucket = async ({ bucketName }) => {
  const command = new S3.ListObjectsV2Command({ Bucket: bucketName });
  const { Contents } = await s3Client.send(command);
  const contentsList = Contents.map((c) => ` • ${c.Key}`).join("\n");
  console.log("\nHere's a list of files in the bucket:");
  console.log(`${contentsList}\n`);
};

const getSingleObject = async (bucketObj) => {
  const command = new S3.GetObjectCommand(bucketObj);
  const response = await s3Client.send(command);
  console.log(`\nFile size: ${(Number(response.ContentLength) / 1000000).toFixed(2)}MB`)
}

const queryObjectWithSharp = async (bucketObj) => {
  try {
    const command = new S3.GetObjectCommand(bucketObj);
    const response = await s3Client.send(command);

    const fileStream = response.Body;

    // To get the file size, you can access the 'ContentLength' from the response
    const fileSize = response.ContentLength;

    // Process the image data using sharp
    const image = await sharp(fileStream).metadata();

    console.log("\nHere's the retrieved image metadata:");

    console.log("Filename:", bucketObj.Key);
    console.log("File size:", fileSize, "bytes");
    console.log("Width:", image.width);
    console.log("Height:", image.height);
  } catch (err) {
    console.error("Error retrieving or processing the image:", err);
  }
};


exports.handler = async (event) => {

  console.log("Logging event....")
  console.log(JSON.stringify(event, undefined, 2))
  await listFilesInBucket({bucketName: processedImageBucket})
  await getSingleObject(bucketObject)
  await queryObjectWithSharp(bucketObject)
  try {
    // Check if the request body exists
    if (!event.body) {
      return {
        statusCode: 400,
        body: JSON.stringify({ message: "No file found in the request body." })
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
      body: JSON.stringify({ message: "Internal Server Error", error: error.message })
    };
  }
};