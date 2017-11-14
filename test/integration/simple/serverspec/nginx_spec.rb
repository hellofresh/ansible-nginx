require 'serverspec'

# Required by serverspec
set :backend, :exec

describe 'Package Service' do
    describe package('nginx') do
      it { should be_installed }
    end

    describe service('nginx') do
      it { should be_enabled }
      it { should be_running }
    end

    describe port(1080) do
      it { should be_listening }
    end

end

describe 'NGinx sites-enabled' do

  describe file('/etc/nginx/sites-enabled/default') do
    it { should be_symlink }
    it { should be_linked_to '/etc/nginx/sites-available/default' }
  end

  describe file('/etc/nginx/sites-enabled/test.conf') do
    it { should be_symlink }
    it { should be_linked_to '/etc/nginx/sites-available/test.conf' }
  end

end

describe 'Nginx locations' do
  describe file('/etc/nginx/include.d/') do
    it { should be_directory }
  end
  describe file('/etc/nginx/include.d/fragment_locations.conf') do
    it { should exist }
    it { should contain 'location ~* ^/fragment1($|/.*$) {'}
    it { should contain 'proxy_pass http://some-upstream;'}
    it { should contain 'proxy_set_header X-Forwarded-Proto https'}
    it { should contain 'proxy_set_header Proxy \'\''}
  end
  describe file('/etc/nginx/include.d/fragment_locations.conf') do
    it { should exist }
    it { should contain 'location ~* ^/fragment2($|/.*$) {'}
    it { should contain 'proxy_pass http://some-upstream;'}
    it { should contain 'proxy_set_header Proxy \'XYZZY\''}
  end
  describe file('/etc/nginx/include.d/other_locations.conf') do
    it { should exist }
    it { should contain 'location ~* ^/external($|/.*$) {'}
    it { should contain 'proxy_pass http://some-upstream;'}
  end
end

describe 'Nginx upstreams' do
  describe file('/etc/nginx/upstreams.d/') do
    it { should be_directory }
  end
  describe file('/etc/nginx/upstreams.d/fragments_upstreams.conf') do
    it { should exist }
    it { should contain 'upstream some-upstream {'}
    it { should contain 'server 127.0.0.1:1337'}
    it { should contain 'upstream example.com:8080 {'}
    it { should contain 'server example.com:8080'}
  end
  describe file('/etc/nginx/upstreams.d/other_upstreams.conf') do
    it { should exist }
    its(:content)  { is_expected.not_to include('upstream some-upstream {') }
    its(:content)  { is_expected.not_to include('server localhost')}
  end
end

describe 'NGinx http content' do

 describe command "curl -s -L http://127.0.0.1:1080" do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should match "Hello test1" }
      end
end

