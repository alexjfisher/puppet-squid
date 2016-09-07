require 'spec_helper'

describe 'squid::extra_config_section' do
  let :pre_condition do
    ' class{"::squid":
        config => "/tmp/squid.conf"
      }
    '
  end

  expected_config_section  = %(# my config section\n)
  expected_config_section += %(ssl_bump server-first all\n)
  expected_config_section += %(sslcrtd_program /usr/lib64/squid/ssl_crtd -s /var/lib/ssl_db -M 4MB\n)
  expected_config_section += %(sslcrtd_children 8 startup=1 idle=1\n)
  expected_config_section += %(\n)

  let(:title) { 'my config section' }
  context 'when config entry parameters are strings' do
    let(:params) do
      {
        config_entries: {
          'ssl_bump'         => 'server-first all',
          'sslcrtd_program'  => '/usr/lib64/squid/ssl_crtd -s /var/lib/ssl_db -M 4MB',
          'sslcrtd_children' => '8 startup=1 idle=1'
        }
      }
    end
    it { should contain_concat_fragment('squid_extra_config_section_my config section').with_target('/tmp/squid.conf') }
    it { should contain_concat_fragment('squid_extra_config_section_my config section').with_order('50-my config section') }
    it 'config section' do
      content = catalogue.resource('concat_fragment', 'squid_extra_config_section_my config section').send(:parameters)[:content]
      expect(content).to match(expected_config_section)
    end
  end
  context 'when config entry parameters are arrays' do
    let(:params) do
      {
        config_entries: {
          'ssl_bump'         => ['server-first', 'all'],
          'sslcrtd_program'  => ['/usr/lib64/squid/ssl_crtd', '-s', '/var/lib/ssl_db', '-M', '4MB'],
          'sslcrtd_children' => ['8', 'startup=1', 'idle=1']
        }
      }
    end
    it 'config section' do
      content = catalogue.resource('concat_fragment', 'squid_extra_config_section_my config section').send(:parameters)[:content]
      expect(content).to match(expected_config_section)
    end
  end
end
