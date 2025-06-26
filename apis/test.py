import boto3

s3 = boto3.client(
    "s3",
    aws_access_key_id="AKIAYS7PWLLN2XDA3HGO",
    aws_secret_access_key="5B6SB438OdmBgY3/SvUVbGjpFdtk0uSdFbYqe2Q1",
    region_name="us-east-1"
)


# Your S3 bucket name
BUCKET_NAME = "wrestlingdocumentsbucket"

# Function to generate the document key
def get_document_key(full_name, doc_number):
    """
    Constructs the S3 object key using the full name and document number.
    Example:
      full_name = "John Doe"
      doc_number = "12345"
      Returns -> "documents/John_Doe_12345.pdf"
    """
    formatted_name = full_name.replace(" ", "_")  # Replace spaces with underscores
    document_key = f"WrestlersLicenseDocuments/{formatted_name}_{doc_number}.pdf"
    return document_key

# Function to generate a pre-signed URL for secure access
def get_presigned_url(full_name, doc_number, expiration=3600):
    document_key = get_document_key(full_name, doc_number)

    try:
        url = s3.generate_presigned_url(
            "get_object",
            Params={"Bucket": BUCKET_NAME, "Key": document_key},
            ExpiresIn=expiration  # Link valid for 1 hour
        )
        return url
    except Exception as e:
        return f"Error generating URL: {str(e)}"

# Example Usage
full_name = "Ionu Aurel"
doc_number = "1"

document_url = get_presigned_url(full_name, doc_number)
print("Access document at:", document_url)
