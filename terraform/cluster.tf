resource "digitalocean_droplet" "control_plane" {
  name = "control-plane"
  image = "centos-7-x64"
  region = "lon1"
  size = "s-1vcpu-1gb"

  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]

  provisioner "remote-exec" {
    inline = [
      "yum update -y"
    ]

    connection {
      host = self.ipv4_address
      user = "root"
      type = "ssh"
      private_key = file(var.pvt_key)
      timeout = "2m"
    }
  }
}

resource "digitalocean_droplet" "workers" {
  count = 1

  name = "worker-${count.index}"
  image = "centos-7-x64"
  region = "lon1"
  size = "s-1vcpu-1gb"

  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]

  provisioner "remote-exec" {
    inline = [
      "yum update -y"
    ]

    connection {
      host = self.ipv4_address
      user = "root"
      type = "ssh"
      private_key = file(var.pvt_key)
      timeout = "2m"
    }
  }
}

resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/templates/hosts.tftpl", {
    control_plane = digitalocean_droplet.control_plane.ipv4_address
    workers = digitalocean_droplet.workers[*].ipv4_address
  })

  filename = "../ansible/hosts.cfg"

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i ../ansible/hosts.cfg --private-key '${var.pvt_key}' -e 'pub_key=${var.pub_key}' ../ansible/playbooks/main.yaml"
  }
}

output "droplet_ips" {
  value = {
    control_plane = digitalocean_droplet.control_plane.ipv4_address
    workers = digitalocean_droplet.workers[*].ipv4_address
  }
}
