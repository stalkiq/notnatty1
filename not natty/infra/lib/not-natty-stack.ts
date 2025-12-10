import { Stack, StackProps, CfnOutput, RemovalPolicy, Duration } from "aws-cdk-lib";
import { Construct } from "constructs";
import * as s3 from "aws-cdk-lib/aws-s3";
import * as iam from "aws-cdk-lib/aws-iam";
import * as dynamodb from "aws-cdk-lib/aws-dynamodb";

export class NotNattyStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);

    // Media bucket for user-uploaded images/videos. Access is via presigned URLs only.
    const bucketName = `not-natty-media-${Stack.of(this).account}-${Stack.of(this).region}`;
    const mediaBucket = new s3.Bucket(this, "MediaBucket", {
      bucketName,
      encryption: s3.BucketEncryption.S3_MANAGED,
      enforceSSL: true,
      blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,
      versioned: true,
      intelligentTieringConfigurations: [
        {
          name: "archive-after-30",
          archiveAccessTierTime: Duration.days(30),
        },
      ],
      removalPolicy: RemovalPolicy.RETAIN, // keep data across stack updates/deletes
      autoDeleteObjects: false,
    });

    // Explicit deny for non-SSL (in addition to enforceSSL) - some tools still check bucket policy
    mediaBucket.addToResourcePolicy(
      new iam.PolicyStatement({
        sid: "DenyInsecureTransport",
        actions: ["s3:*"],
        principals: [new iam.AnyPrincipal()],
        resources: [mediaBucket.arnForObjects("*"), mediaBucket.bucketArn],
        effect: iam.Effect.DENY,
        conditions: { Bool: { "aws:SecureTransport": "false" } },
      })
    );

    new CfnOutput(this, "MediaBucketName", { value: mediaBucket.bucketName });
    new CfnOutput(this, "MediaBucketArn", { value: mediaBucket.bucketArn });

    // DynamoDB: Users
    const usersTable = new dynamodb.Table(this, "UsersTable", {
      tableName: `not-natty-users-${Stack.of(this).account}-${Stack.of(this).region}`,
      partitionKey: { name: "userId", type: dynamodb.AttributeType.STRING },
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      pointInTimeRecovery: true,
      removalPolicy: RemovalPolicy.RETAIN,
    });
    new CfnOutput(this, "UsersTableName", { value: usersTable.tableName });

    // DynamoDB: Posts (query by userId + createdAt; GSI for postId lookup)
    const postsTable = new dynamodb.Table(this, "PostsTable", {
      tableName: `not-natty-posts-${Stack.of(this).account}-${Stack.of(this).region}`,
      partitionKey: { name: "userId", type: dynamodb.AttributeType.STRING },
      sortKey: { name: "createdAt", type: dynamodb.AttributeType.NUMBER },
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      pointInTimeRecovery: true,
      removalPolicy: RemovalPolicy.RETAIN,
    });
    postsTable.addGlobalSecondaryIndex({
      indexName: "postId",
      partitionKey: { name: "postId", type: dynamodb.AttributeType.STRING },
      projectionType: dynamodb.ProjectionType.ALL,
    });
    new CfnOutput(this, "PostsTableName", { value: postsTable.tableName });

    // DynamoDB: Cycles (query by userId + startDate; GSI for cycleId lookup)
    const cyclesTable = new dynamodb.Table(this, "CyclesTable", {
      tableName: `not-natty-cycles-${Stack.of(this).account}-${Stack.of(this).region}`,
      partitionKey: { name: "userId", type: dynamodb.AttributeType.STRING },
      sortKey: { name: "startDate", type: dynamodb.AttributeType.NUMBER },
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      pointInTimeRecovery: true,
      removalPolicy: RemovalPolicy.RETAIN,
    });
    cyclesTable.addGlobalSecondaryIndex({
      indexName: "cycleId",
      partitionKey: { name: "cycleId", type: dynamodb.AttributeType.STRING },
      projectionType: dynamodb.ProjectionType.ALL,
    });
    new CfnOutput(this, "CyclesTableName", { value: cyclesTable.tableName });

    // DynamoDB: Intakes (query by userId + time; GSI for supplementName)
    const intakesTable = new dynamodb.Table(this, "IntakesTable", {
      tableName: `not-natty-intakes-${Stack.of(this).account}-${Stack.of(this).region}`,
      partitionKey: { name: "userId", type: dynamodb.AttributeType.STRING },
      sortKey: { name: "time", type: dynamodb.AttributeType.NUMBER },
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      pointInTimeRecovery: true,
      removalPolicy: RemovalPolicy.RETAIN,
    });
    intakesTable.addGlobalSecondaryIndex({
      indexName: "bySupplement",
      partitionKey: { name: "supplementName", type: dynamodb.AttributeType.STRING },
      sortKey: { name: "time", type: dynamodb.AttributeType.NUMBER },
      projectionType: dynamodb.ProjectionType.ALL,
    });
    new CfnOutput(this, "IntakesTableName", { value: intakesTable.tableName });
  }
}

