import { Stack, StackProps, CfnOutput, RemovalPolicy } from "aws-cdk-lib";
import { Construct } from "constructs";

export class NotNattyStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);

    // Placeholder only. Next steps will add S3/DynamoDB/API resources incrementally.
    new CfnOutput(this, "Region", { value: Stack.of(this).region });
    new CfnOutput(this, "Account", { value: Stack.of(this).account });
  }
}

