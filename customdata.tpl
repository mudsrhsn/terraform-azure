#cloud-config
package_update: true
packages:
  - docker.io
runcmd:
  - sudo systemctl enable docker
  - sudo systemctl start docker
  - sudo usermod -aG docker $USER
  - echo "Docker installed and started"