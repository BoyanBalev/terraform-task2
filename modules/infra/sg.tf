#FIREWALL RULES

#ALLOW ONLY TRAFFIC FROM PORT 80 AND ONLY FROM PUBLIC SUBNET
resource "aws_security_group" "backend" {
  name        = "backend-sg-boyan-flatrock"
  vpc_id      = aws_vpc.this.id

  ingress {
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  cidr_blocks = [for s in aws_subnet.public : s.cidr_block]
}
 
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "backend-sg-boyan-flatrock"
  }
}


#ALLOW ONLY PORT 80 FROM ALL INTERNET (ITS GOOD TO RESTRICT WITH VARIABLE!!)
resource "aws_security_group" "lb" {
  name        = "lb-sg-boyan-flatrock"
  vpc_id      = aws_vpc.this.id

  ingress {
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
 
  
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [for s in aws_subnet.backend : s.cidr_block]
  }
  tags = {
    Name = "lb-sg-boyan-flatrock"
  }
}


#DB ALLOW ONLY 3306 FOR MARIADB
resource "aws_security_group" "db" {
  name        = "db-sg-boyan-flatrock"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [for s in aws_subnet.backend : s.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg-boyan-flatrock"
  }
}