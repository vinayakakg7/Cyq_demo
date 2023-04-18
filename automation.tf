provider "aws" {
  region = "ap-south-1"
  access_key = "AKIA2O2OMWUCJJF6HBUQ"
  secret_key = "eoJPNdVIlHBR56QgbB1JvW5hcDTkgEWJ3rxE5XVi"
}

data "aws_security_group" "example" {
  id = "sg-061d334e74d54ff97"
}

resource "aws_instance" "Automation" {
  ami = "ami-0376ec8eacdf70aae"
  instance_type = "t2.micro"
  subnet_id = "subnet-0c75140c32f8d4e76"
  key_name = "nexuskey"
  vpc_security_group_ids = [data.aws_security_group.example.id]
  associate_public_ip_address = true

  tags = {
    Name = "Automation_Server"
    OS   = "Amazon_Linux"
  }
}

output "public_ip" {
  value = aws_instance.Automation.public_ip
}

resource "null_resource" "remote" {
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./nexuskey.pem")
    host        = aws_instance.Automation.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum install nginx -y",
	    "sudo systemctl enable nginx",
	    "sudo systemctl start nginx"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install git -y",
	    "sudo yum install maven -y"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum install -y java",
      "sudo yum -y install wget",
      "sudo wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.73/bin/apache-tomcat-9.0.73.tar.gz",
	    "sudo yum -y install tar",
      "sudo tar -xvzf apache-tomcat-9.0.73.tar.gz",
      "sudo mv apache-tomcat-9.0.73 /usr/local/tomcat9",
	    "sudo rm -rf apache-tomcat-9.0.73.tar.gz",
	    "sudo chmod +x /usr/local/tomcat9/bin/startup.sh",
	    "sudo chmod +x /usr/local/tomcat9/bin//shutdown.sh",
	    "sudo ln -s /usr/local/tomcat9/bin/startup.sh /usr/local/bin/tomcatup",
	    "sudo ln -s /usr/local/tomcat9/bin/shutdown.sh /usr/local/bin/tomcatdown",
	    "sudo tomcatup"
    ]
  }
}


