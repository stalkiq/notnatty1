# Not Natty Infra (AWS CDK v2)

Backend infrastructure for the Not Natty iOS app, provisioned with AWS CDK (TypeScript).

This repo uses account `016442247702` and defaults to region `us-east-1`. You can override via CDK context or environment variables.

## Prerequisites
- Node.js 18+ and npm
- AWS CLI v2 (configured with a profile or SSO)
- AWS CDK v2 (`npm i -g aws-cdk`)

## Setup
```bash
cd \"not natty/infra\"
npm install
# Optionally set region/account:
# cdk synth -c account=016442247702 -c region=us-east-1
```

## Bootstrap (once per account/region)
```bash
cdk bootstrap aws://016442247702/us-east-1
```
If using a named profile:
```bash
AWS_PROFILE=your-profile cdk bootstrap aws://016442247702/us-east-1
```

## Deploy
```bash
cdk deploy
```
or
```bash
AWS_PROFILE=your-profile cdk deploy
```

### Outputs
- `MediaBucketName` and `MediaBucketArn` will be printed after deploy.
  - Access pattern: generate presigned PUT/GET URLs from a Lambda (to be added next).

## Next Steps (will be added incrementally)
1) DynamoDB tables (users, posts, cycles, intakes)  
2) API Gateway + Lambda (REST)  
3) Cognito User Pool (auth)  
4) Notifications/Reminders (EventBridge + SNS)  

Resources will be added to `lib/not-natty-stack.ts` in small, reviewable increments.

