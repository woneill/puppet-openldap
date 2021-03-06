require 'spec_helper'

describe 'openldap::client::config' do

  context 'on Debian' do

    let(:facts) {{
      :osfamily => 'Debian',
    }}

    context 'with no parameters' do
      let :pre_condition do
        "class {'openldap::client':}"
      end

      it { should compile.with_all_deps }
      it { should contain_class('openldap::client::config') }
      it { should_not contain_shellvar('ldap.conf+base') }
      it { should_not contain_shellvar('ldap.conf+uri') }
      it { should_not contain_shellvar('ldap.conf+cacert') }
    end

    context 'with base set' do
      let :pre_condition do
        "class {'openldap::client': base => 'dc=example,dc=com', }"
      end

      it { should compile.with_all_deps }
      it { should contain_class('openldap::client::config') }
      it { should contain_shellvar('ldap.conf+base')
        .with({
          :ensure   => :present,
	  :target   => '/etc/ldap/ldap.conf',
	  :variable => 'BASE',
	  :value    => 'dc=example,dc=com',
	})
      }
      it { should_not contain_shellvar('ldap.conf+uri') }
      it { should_not contain_shellvar('ldap.conf+tls_cacert') }
    end

    context 'with uri set' do
      let :pre_condition do
        "class {'openldap::client': uri => 'ldap://ldap.example.com', }"
      end

      it { should compile.with_all_deps }
      it { should contain_class('openldap::client::config') }
      it { should_not contain_shellvar('ldap.conf+base') }
      it { should contain_shellvar('ldap.conf+uri')
        .with({
          :ensure   => :present,
	  :target   => '/etc/ldap/ldap.conf',
	  :variable => 'URI',
	  :value    => 'ldap://ldap.example.com',
	})
      }
      it { should_not contain_shellvar('ldap.conf+tls_cacert') }
    end

    context 'with multiple uri set' do
      let :pre_condition do
        "class {'openldap::client': uri => ['ldap://ldap1.example.com', 'ldap://ldap2.example.com'] }"
      end

      it { should compile.with_all_deps }
      it { should contain_class('openldap::client::config') }
      it { should_not contain_shellvar('ldap.conf+base') }
      it { should contain_shellvar('ldap.conf+uri')
        .with({
          :ensure   => :present,
	  :target   => '/etc/ldap/ldap.conf',
	  :variable => 'URI',
	  :value    => ['ldap://ldap1.example.com', 'ldap://ldap2.example.com'],
	})
      }
      it { should_not contain_shellvar('ldap.conf+tls_cacert') }
    end

    context 'with an invalid tls_cacert set' do
      let :pre_condition do
        "class {'openldap::client': tls_cacert => 'foo', }"
      end

      it { expect { should compile }
        .to raise_error(Puppet::Error, /\"foo\" is not an absolute path/)
      }
    end

    context 'with a valid tls_cacert set' do
      let :pre_condition do
        "class {'openldap::client': tls_cacert => '/etc/ssl/certs/ca-certificates.crt', }"
      end

      it { should compile.with_all_deps }
      it { should contain_class('openldap::client::config') }
      it { should_not contain_shellvar('ldap.conf+base') }
      it { should_not contain_shellvar('ldap.conf+uri') }
      it { should contain_shellvar('ldap.conf+tls_cacert')
        .with({
          :ensure   => :present,
	  :target   => '/etc/ldap/ldap.conf',
	  :variable => 'TLS_CACERT',
	  :value    => '/etc/ssl/certs/ca-certificates.crt',
	})
      }
    end

  end

end

