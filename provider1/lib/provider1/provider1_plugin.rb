module Provider1  
  class Plugin < ::Proxy::Provider    
    # General smart proxy configuration parameters:    
    plugin :provider1, ::Provider1::VERSION

    capability 'dhcp_filename_ipv4'
    capability 'dhcp_filename_hostname'

=begin
    default_settings :config => '/etc/dhcp/dhcpd.conf', :leases => '/var/lib/dhcpd/dhcpd.leases',
                     :omapi_port => '7911', :blacklist_duration_minutes => 30 * 60

    requires :dhcp, ::Proxy::VERSION
    validate_readable :config, :leases

    load_classes ::Proxy::DHCP::ISC::PluginConfiguration
    load_programmable_settings ::Proxy::DHCP::ISC::PluginConfiguration
    load_dependency_injection_wirings ::Proxy::DHCP::ISC::PluginConfiguration

    start_services :leases_observer, :free_ips
=end

  end
end