class R2Config {
  const R2Config._();

  // Cloudflare Account ID (R2 -> Account ID)
  static const String accountId = String.fromEnvironment(
    'R2_ACCOUNT_ID',
  );

  // R2 bucket name
  static const String bucketName = String.fromEnvironment(
    'R2_BUCKET_NAME',
  );

  // R2 API Tokens -> Access Key ID / Secret Access Key
  static const String accessKeyId = String.fromEnvironment(
    'R2_ACCESS_KEY_ID',
  );
  static const String secretAccessKey = String.fromEnvironment(
    'R2_SECRET_ACCESS_KEY',
  );

  // Optional custom public domain for your bucket.
  // Example: https://assets.example.com
  // If empty, fallback is https://pub-xxxx.r2.dev (if your bucket has one).
  static const String publicBaseUrl = String.fromEnvironment(
    'R2_PUBLIC_BASE_URL',
  );

  // Optional folder (prefix) in the bucket where images will be stored.
  static const String objectPrefix = String.fromEnvironment(
    'R2_OBJECT_PREFIX',
    defaultValue: 'assets',
  );
}
