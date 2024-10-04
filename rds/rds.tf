provider "aws" {
  region = "us-east-1"
}

# RDS Instance (MariaDB)
resource "aws_db_instance" "wordpress_rds" {
  allocated_storage    = 20
  engine               = "mariadb"  
  engine_version       = "10.5"     
  instance_class       = "db.t3.micro"
  db_name                 = "wordpress"   
  username             = "adminHelen"        
  password             = "123pashelen"  
  parameter_group_name = "default.mariadb10.5"
  publicly_accessible  = false         
  vpc_security_group_ids = [
    "sg-091e9dd90f4097ee0"       
  ]
  skip_final_snapshot  = true

  # Connecting to the private subnet
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name

  tags = {
    Name = "wordpress-rds-instance"
  }
}

# RDS Subnet Group (for private subnets)
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  # Hardcoded subnet IDs, but best practice is: ensure these subnets are in different AZs for RDS availability
  subnet_ids = ["subnet-0bccee867344d44c2","subnet-028e3588f88de1369"]  
  tags = {
    Name = "rds-subnet-group"
  }
}
