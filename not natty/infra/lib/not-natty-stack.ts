import { Stack, StackProps, CfnOutput, RemovalPolicy, Duration, Aws } from "aws-cdk-lib";
import { Construct } from "constructs";
import * as s3 from "aws-cdk-lib/aws-s3";
import * as iam from "aws-cdk-lib/aws-iam";

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
  }
}

