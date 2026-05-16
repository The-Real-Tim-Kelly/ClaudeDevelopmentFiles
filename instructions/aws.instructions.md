# AWS Services Instructions (S3, SQS, SNS)

> **Claude Code:** Reference this file with `@instructions/aws.instructions.md` when working on S3, SQS, or SNS integrations. For DynamoDB, use `@instructions/dynamodb.instructions.md` instead.

---

## General AWS Rules

- All AWS clients are registered as **singletons** in DI
- All resource names (bucket names, queue URLs, topic ARNs) come from **`IOptions<T>` / `appsettings.json`** — never hardcoded
- Always use **async SDK methods** — no synchronous AWS SDK calls
- Use `CancellationToken` on every async AWS call
- Wrap AWS calls in try/catch for `AmazonServiceException` at the infrastructure boundary; let domain exceptions propagate upward

---

## Amazon S3

### Registration

```csharp
services.AddSingleton<IAmazonS3, AmazonS3Client>();
services.Configure<S3Options>(config.GetSection(S3Options.SectionName));
```

### Options

```csharp
public sealed class S3Options
{
    public const string SectionName = "S3";
    public string DocumentsBucketName { get; init; } = default!;
}
```

### Upload (small files — up to ~5 MB)

```csharp
var request = new PutObjectRequest
{
    BucketName = _opts.Value.DocumentsBucketName,
    Key        = $"documents/{userId}/{fileName}",
    InputStream = stream,
    ContentType = contentType,
    ServerSideEncryptionMethod = ServerSideEncryptionMethod.AES256
};
await _s3.PutObjectAsync(request, ct);
```

### Upload (large files — over 5 MB)

Use `TransferUtility` for multipart upload handling:

```csharp
var utility = new TransferUtility(_s3);
await utility.UploadAsync(stream, _opts.Value.DocumentsBucketName, key, ct);
```

### Download

```csharp
var response = await _s3.GetObjectAsync(
    _opts.Value.DocumentsBucketName, key, ct);
// response.ResponseStream is the file — copy to your destination stream
```

### Presigned URLs (time-limited access, no credentials in URL)

```csharp
var urlRequest = new GetPreSignedUrlRequest
{
    BucketName = _opts.Value.DocumentsBucketName,
    Key        = key,
    Expires    = DateTime.UtcNow.AddMinutes(15),
    Verb       = HttpVerb.GET
};
string url = _s3.GetPreSignedURL(urlRequest);
```

### Key Design

- Use meaningful, structured key prefixes: `documents/{tenantId}/{userId}/{filename}`
- Never expose raw S3 keys to API callers; return presigned URLs instead
- Enforce server-side encryption (`AES256` or `aws:kms`) on all uploads

---

## Amazon SQS

### Registration

```csharp
services.AddSingleton<IAmazonSQS, AmazonSQSClient>();
services.Configure<SqsOptions>(config.GetSection(SqsOptions.SectionName));
```

### Options

```csharp
public sealed class SqsOptions
{
    public const string SectionName = "Sqs";
    public string OrderProcessingQueueUrl { get; init; } = default!;
}
```

### Sending a Message

```csharp
var request = new SendMessageRequest
{
    QueueUrl    = _opts.Value.OrderProcessingQueueUrl,
    MessageBody = JsonSerializer.Serialize(message),
    MessageAttributes = new Dictionary<string, MessageAttributeValue>
    {
        ["MessageType"] = new MessageAttributeValue
        {
            DataType    = "String",
            StringValue = nameof(OrderPlacedMessage)
        }
    }
};
await _sqs.SendMessageAsync(request, ct);
```

### Receiving & Processing Messages

```csharp
var response = await _sqs.ReceiveMessageAsync(new ReceiveMessageRequest
{
    QueueUrl            = _opts.Value.OrderProcessingQueueUrl,
    MaxNumberOfMessages = 10,
    WaitTimeSeconds     = 20,  // long polling — always use this
    MessageAttributeNames = new List<string> { "All" }
}, ct);

foreach (var message in response.Messages)
{
    try
    {
        await ProcessMessageAsync(message, ct);
        await _sqs.DeleteMessageAsync(
            _opts.Value.OrderProcessingQueueUrl,
            message.ReceiptHandle, ct);
    }
    catch (Exception ex)
    {
        // Log and do NOT delete — message returns to queue / DLQ after visibility timeout
        _logger.LogError(ex, "Failed to process message {MessageId}", message.MessageId);
    }
}
```

### SQS Rules

- **Always use long polling** (`WaitTimeSeconds = 20`) — short polling wastes money and CPU
- **Only delete a message after successful processing** — failed messages must return to the queue or DLQ
- Configure a **Dead Letter Queue (DLQ)** for every queue with a `maxReceiveCount` of 3–5
- Set **visibility timeout** longer than your maximum expected processing time to avoid duplicate processing
- Use **FIFO queues** only when strict ordering is required — they are slower and more expensive
- Never put PII or sensitive data in message attributes — keep it in the body (which is encrypted in transit/at rest)

---

## Amazon SNS

### Registration

```csharp
services.AddSingleton<IAmazonSimpleNotificationService, AmazonSimpleNotificationServiceClient>();
services.Configure<SnsOptions>(config.GetSection(SnsOptions.SectionName));
```

### Options

```csharp
public sealed class SnsOptions
{
    public const string SectionName = "Sns";
    public string OrderEventsTopicArn { get; init; } = default!;
}
```

### Publishing a Message

```csharp
var request = new PublishRequest
{
    TopicArn = _opts.Value.OrderEventsTopicArn,
    Message  = JsonSerializer.Serialize(eventPayload),
    MessageAttributes = new Dictionary<string, MessageAttributeValue>
    {
        ["EventType"] = new MessageAttributeValue
        {
            DataType    = "String",
            StringValue = "OrderPlaced"
        }
    }
};
await _sns.PublishAsync(request, ct);
```

### SNS Rules

- Topic ARNs always come from configuration — never hardcoded
- Use **message attributes** for routing/filtering so subscribers can filter without parsing the body
- For SNS → SQS fan-out, configure the SQS queue's access policy to allow `sns:Publish` from the topic
- Use **FIFO topics** only when paired with FIFO queues for strict ordering
- Add a **`MessageGroupId`** when publishing to FIFO topics

---

## Secrets & Credentials

- Never put AWS access keys in `appsettings.json` or source code
- In AWS-hosted environments: use **IAM roles** (EC2 instance profile, ECS task role, Lambda execution role)
- In local development: use `~/.aws/credentials` or environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
- For cross-account or external tools: use **AWS Secrets Manager** and fetch on startup via `IConfiguration` with the AWS Secrets Manager configuration provider
