#vagrant plugin list
#hosts (0.1.1)
#puppet (5.3.3)
#vagrant-hosts (2.8.0)
#vagrant-share (1.1.9, system)
#vagrant-vbguest (0.15.0)

domain = 'bosco.local'
box = "debian/stretch64"

puppet_nodes = [
  {:hostname => 'chiodino', :ip => '172.16.32.11', :box => box, :fwdhost => 8001, :fwdguest => 3306},
  {:hostname => 'finferlo', :ip => '172.16.32.12', :box => box, :fwdhost => 8002, :fwdguest => 80},
  {:hostname => 'boletus',  :ip => '172.16.32.13', :box => box, :fwdhost => 8003, :fwdguest => 80},
  {:hostname => 'porcino',  :ip => '172.16.32.10', :box => box, :fwdhost => 8004, :fwdguest => 80},
]

Vagrant.configure("2") do |config|
  puppet_nodes.each do |node|
    config.vm.define node[:hostname] do |node_config|
      node_config.vm.box = node[:box] ? node[:box] : :box;
      node_config.vm.box_url = 'https://atlas.hashicorp.com/' + node_config.vm.box
      node_config.vm.hostname = node[:hostname] + '.' + domain
      node_config.vm.network :private_network, ip: node[:ip]

      config.vm.synced_folder "./viagrant-share", "/viagrant-share", type: "virtualbox" 

      config.vbguest.no_remote = true
      config.vbguest.iso_path = "/usr/share/virtualbox/VBoxGuestAdditions.iso"

      if node[:fwdhost]
        node_config.vm.network :forwarded_port, guest: node[:fwdguest], host: node[:fwdhost]
      end

      #memory = 2048
      memory = 512
      node_config.vm.provider :virtualbox do |vb|
        vb.customize [
          'modifyvm', :id,
          '--name', node[:hostname],
          '--memory', memory.to_s
        ]
      end

      node_config.vm.provision :hosts, :sync_hosts => true

      node_config.vm.provision "shell", path: "utils/deploy.sh"

    end
  end
end
