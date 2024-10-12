# NT548-DevOps-Exercises
Lab 1: Sử dụng Terraform và Cloudformation để quản lý và triển khai cơ sở hạ tầng AWS

+ Các dịch vụ cần triển khai: VPC, Route Tables, Nat Gateway, EC2, Security Groups
      
+ Yêu cầu:
      
  + Các dịch vụ phải viết dưới dạng module
        
  +  Đảm bảo bảo mật cho EC2

+ Hướng dẫn chạy Terraform trên CLI: 

  + Tải AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

  + Tải Terraform: https://developer.hashicorp.com/terraform/install?product_intent=terraform

  + Hướng dẫn lấy Access key và Secret key trên tài khoản AWS: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html

  + Thêm Access key và Secret key trên Terminal:
      ```console
      username@linux:~$ aws configure 
      AWS Access Key ID [None]:
      AWS Secret Access Key [None]:
      Default region name [None]:
      Default output format [None]:  
      ```

  + Khởi tạo:

      ```console
      username@linux:~$ terraform init
      ```
  + Định dạng và xác thực:

      ```console
      username@linux:~$ terraform fmt
      ```

      ```console
      username@linux:~$ terraform validate
      Success! The configuration is valid.
      ```

  + Áp dụng cấu hình:

      ```console
      username@linux:~$ terraform apply
      ```
      Kiểm tra các thông tin dịch vụ triển khai:

      ```console
      username@linux:~$ terraform show
      ```


