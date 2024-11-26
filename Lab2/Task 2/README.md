# CONFIGURATION

## Github

Cause the AWS CodeCommit is not supported anymore

We use GitHub to store source code

## IAM Role

1. Navigate to CodeBuild > on left side bar choose "Roles" > "Create Role"

2. Choose AWS Service and Use case is CloudFormation

3. Give the role policies

4. Name the role and Create

## CodeBuild

1. Navigate to CodeBuild > "Create Project" > Give Project a name

2. In "Source", connect to Github/CodeCommit and choose the repository needed

3. In "Buildspec" choose "Use a buildspec file"

4. Everything else is left as default

## CodePipeline

1. Navigate to CodeBuild > "Create Pipeline"

2. Step 1, choose "Build Custome Pipeline"

3. Step 2, give pipeline a name and leave everything else as default

4. Step 3, connect to to Github/CodeCommit and choose the repository needed

5. Step 4, choose the CodeBuild Created above

6. Step 5, choose AWS CloudFormation in "Deploy Provider" > in "Action Mode" choose "Create or update a stack" > Give a stack name and enter template used.

# USAGE

Pipeline will be automatically triggered when the repository has changes in branch main
