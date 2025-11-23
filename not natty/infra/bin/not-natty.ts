#!/usr/bin/env node
import * as cdk from "aws-cdk-lib";
import { NotNattyStack } from "../lib/not-natty-stack";

const app = new cdk.App();

// Allow override via context or environment; default to us-east-1 and provided account
const account =
  (app.node.tryGetContext("account") as string | undefined) ||
  process.env.CDK_DEFAULT_ACCOUNT ||
  "016442247702";

const region =
  (app.node.tryGetContext("region") as string | undefined) ||
  process.env.CDK_DEFAULT_REGION ||
  "us-east-1";

new NotNattyStack(app, "NotNattyStack", {
  env: { account, region },
  description:
    "Baseline CDK stack for Not Natty backend (scaffold only; add resources incrementally)",
});

