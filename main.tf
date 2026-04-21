resource "aws_launch_template" "web_server_as" {
  name = "myproject"

  image_id      = "ami-0e12ffc2dd465f6e4"
  instance_type = "t3.micro"
  key_name      = "Arun_key"

  vpc_security_group_ids = [
    aws_security_group.web_server.id
  ]

  tags = {
    Name = "DevOps"
  }
}
   


 resource "aws_elb" "web_server_lb" {
  name            = "web-server-lb"
  security_groups = [aws_security_group.web_server.id]

  subnets = [
    "subnet-02fc6aa492fa01293",
    "subnet-08b9c82044e995962"
  ]

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  tags = {
    Name = "terraform-elb"
  }
}

resource "aws_autoscaling_group" "web_server_asg" {
  name             = "web-server-asg"
  min_size         = 1
  max_size         = 3
  desired_capacity = 2

  # ✅ REQUIRED: Tell ASG where to launch instances
  vpc_zone_identifier = [
    "subnet-02fc6aa492fa01293",
    "subnet-08b9c82044e995962"
  ]

  launch_template {
    id      = aws_launch_template.web_server_as.id
    version = "$Latest"
  }

  load_balancers    = [aws_elb.web_server_lb.name]
  health_check_type = "EC2"

  tag {
    key                 = "Name"
    value               = "web-server"
    propagate_at_launch = true
  }
}
