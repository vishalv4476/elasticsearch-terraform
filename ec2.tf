## Master Node

resource "aws_instance" "master" {
	ami = lookup(var.ami, var.region)
	instance_type = var.instance-type-master
	count = var.master-count
	tenancy       = "default"
	key_name      = var.key
        vpc_security_group_ids = [aws_security_group.allow.id]
	iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
	root_block_device {
		volume_size = "8"
		volume_type = "gp2"
		delete_on_termination = true
	}

	provisioner "file" {
   		source      = "master.sh"
    	destination = "/tmp/master.sh"
  	}

  	provisioner "remote-exec" {
    		inline = [
	                "sudo hostnamectl set-hostname demo-elk-master-0${count.index}",
      				"sudo sh /tmp/master.sh",
   	 		]
  	}
	connection {
		   host        = self.public_ip
    		   user        = "centos"
                   type        = "ssh"
		password    = ""
    		private_key = file(var.pubkey)
  	}
		tags = {
   	 		Name = "demo-elk-master-0${count.index}"
			es_cluster = "demo-elasticsearch"
  	}
}



## Data Node

resource "aws_instance" "node" {
	ami = lookup(var.ami, var.region)
	instance_type = var.instance-type-node
	count = var.node-count
	tenancy       = "default"
	key_name      = var.key
    vpc_security_group_ids = [aws_security_group.allow.id]
	iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
	root_block_device {
		volume_size = "8"
		volume_type = "gp2"
		delete_on_termination = true
	}

	provisioner "file" {
   		source      = "node.sh"
    		destination = "/tmp/node.sh"
  	}

  	provisioner "remote-exec" {
    		inline = [
	                "sudo hostnamectl set-hostname demo-elk-node-0${count.index}",
      			"sudo sh /tmp/node.sh",
   	 		]
  	}

	connection {
			host        = self.public_ip
            user        = "centos"
			type        = "ssh"
			password    = ""
    		private_key = file(var.pubkey)
  	}
	
	tags = {
   	 	Name = "demo-elk-node-0${count.index}"
		es_cluster = "demo-elasticsearch"
  	}
}




