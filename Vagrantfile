Vagrant.configure("2") do |config|
  #config.vm.box = "generic/gentoo"
  config.vm.box = "gentoo-dev"

  # create 3 virtual machines
  #(1..3).each do |i|
  (1..1).each do |i|
    config.vm.define "node_#{i}" do |node|
      node.vm.provision "ansible" do |ansible|
        ansible.playbook = "playbooks/bootstrap.yml"

        ansible.groups = {
          "vagrant" => ["node_1", "node_2", "node_3"]
        }
      end
    end
  end


  # define what a libvirt VM looks like
  config.vm.provider :libvirt do |libvirt|
    config.vagrant.plugins = ["vagrant-libvirt"]
    #libvirt.cpus = 4
    #libvirt.memory = 2048
    libvirt.cpus = 12
    libvirt.memory = 6144
  end
end

