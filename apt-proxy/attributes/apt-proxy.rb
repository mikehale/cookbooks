apt_proxy Mash.new unless attribute?("apt_proxy")
apt_proxy[:server_url] = "http://localhost:9999" unless apt_proxy.has_key?(:server_url)