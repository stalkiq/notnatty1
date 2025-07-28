# AWS Amplify Deployment Guide

## Overview
This guide will help you deploy your Not Natty application to AWS Amplify.

## Prerequisites
1. AWS Account with appropriate permissions
2. AWS CLI installed and configured
3. Git repository with your code

## AWS Services You'll Need

### 1. AWS Amplify
- **Purpose**: Host your backend API
- **Cost**: Pay per request + data transfer
- **Setup**: Will be configured through Amplify Console

### 2. Amazon RDS (PostgreSQL)
- **Purpose**: Database for your application
- **Cost**: ~$15-30/month for db.t3.micro
- **Setup**: Create PostgreSQL instance in RDS

### 3. Amazon S3
- **Purpose**: File storage for uploads
- **Cost**: ~$0.023/GB/month
- **Setup**: Create bucket for file uploads

### 4. Amazon SES (Optional)
- **Purpose**: Email sending
- **Cost**: $0.10 per 1000 emails
- **Setup**: Configure for email verification

### 5. Amazon ElastiCache (Optional)
- **Purpose**: Redis caching
- **Cost**: ~$15-30/month
- **Setup**: Create Redis cluster

## Deployment Steps

### Step 1: Set Up AWS Amplify
1. Go to AWS Amplify Console
2. Click "New App" → "Host web app"
3. Connect your Git repository
4. Choose "Backend" as the app type
5. Configure build settings using the `amplify.yml` file

### Step 2: Configure Environment Variables
In Amplify Console, go to Environment Variables and add:

```
NODE_ENV=production
PORT=8080
FRONTEND_URL=https://your-amplify-app.amplifyapp.com
DB_HOST=your-rds-endpoint.region.rds.amazonaws.com
DB_PORT=5432
DB_NAME=not_natty_db
DB_USER=your_db_user
DB_PASSWORD=your_secure_password
DATABASE_URL=postgresql://user:password@host:5432/dbname
JWT_SECRET=your_super_secret_jwt_key_here
JWT_EXPIRES_IN=7d
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
AWS_REGION=us-east-1
AWS_S3_BUCKET=not-natty-uploads
```

### Step 3: Set Up RDS Database
1. Go to RDS Console
2. Create PostgreSQL instance
3. Choose Multi-AZ for production
4. Set up security groups to allow Amplify access
5. Note the endpoint URL for environment variables

### Step 4: Set Up S3 Bucket
1. Go to S3 Console
2. Create bucket named `not-natty-uploads`
3. Configure CORS policy
4. Set up IAM permissions for Amplify

### Step 5: Update iOS App
1. Replace the baseURL in `APIService.swift` with your Amplify backend URL
2. Test the connection
3. Update App Store deployment

## Security Considerations

### 1. Environment Variables
- Never commit secrets to Git
- Use AWS Systems Manager Parameter Store for sensitive data
- Rotate JWT secrets regularly

### 2. Database Security
- Use VPC for RDS
- Configure security groups properly
- Enable encryption at rest

### 3. API Security
- Implement proper rate limiting
- Use HTTPS everywhere
- Validate all inputs

## Cost Optimization

### 1. Database
- Use RDS Reserved Instances for production
- Consider Aurora Serverless for variable workloads

### 2. Storage
- Set up S3 lifecycle policies
- Use CloudFront for content delivery

### 3. Compute
- Monitor Amplify usage
- Set up billing alerts

## Monitoring and Logging

### 1. CloudWatch
- Set up log groups for your application
- Create dashboards for monitoring
- Set up alarms for errors

### 2. Application Monitoring
- Implement health checks
- Monitor response times
- Track user metrics

## Backup and Recovery

### 1. Database Backups
- Enable automated backups in RDS
- Test restore procedures
- Store backups in different regions

### 2. Application Backups
- Use Git for code versioning
- Backup environment configurations
- Document deployment procedures

## Troubleshooting

### Common Issues
1. **CORS Errors**: Check FRONTEND_URL environment variable
2. **Database Connection**: Verify RDS security groups
3. **File Uploads**: Check S3 bucket permissions
4. **Environment Variables**: Ensure all required vars are set

### Support Resources
- AWS Amplify Documentation
- AWS RDS Documentation
- AWS S3 Documentation
- AWS Support (if you have a support plan)

## Next Steps After Deployment

1. **Test Everything**: Verify all API endpoints work
2. **Update iOS App**: Deploy updated app with new backend URL
3. **Monitor Performance**: Set up monitoring and alerts
4. **Scale as Needed**: Adjust resources based on usage
5. **Security Audit**: Review security configurations
6. **Backup Strategy**: Implement comprehensive backup plan 