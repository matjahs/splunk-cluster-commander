# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "splunk-enterprise/map.jinja" import host_lookup as config with context %}

install-pip:
  pkg.installed:
    - name: python3-pip
    - refresh: True

install-pyopenssl:
  pkg.installed:
    - name: {{ config.package.openssl_pkg_name }}
    - refresh: True

# Install/upgrade pip
pip-package-pip-splunk:
  pip.installed:
    - names:
       - pip
       - setuptools
    - upgrade: True
    - bin_env: {{ config.package.python_pip_cmd }}
    - user: root
    - reload_modules: True
    - require:
      - pkg: install-pip

# Install common utils using Pip
pip-package-install-common-pkg-splunk:
  pip.installed:
    - names:
      #- boto3
      #- awscli
      - python-dateutil
    - upgrade: True
    - bin_env: {{ config.package.python_pip_cmd }}
    - user: root
    - reload_modules: True
    - require:
      - pip: pip-package-pip-splunk

{% if grains['os_family'] == 'Debian' %}
install-acl:
  pkg.installed:
    - name: acl
    - refresh: True
{% endif %}

# Set package_source based on where the splunk package comes from
{% if config.package.install_type == 'download' %}
  {% set package_source = config.package.base_url + '/' + config.package.version + '/' + config.package.platform + '/' + config.package.file_name %}
{% elif config.package.install_type == 'local' %}
  {% set package_source = 'salt://files/' + config.package.file_name %}
{% endif %}

# Install Splunk
package-install-splunk:
  pkg.installed:
    - enable: True
    - sources:
        - splunk: {{ package_source }}
    - refresh: True
    - skip_verify: True
    # - onchanges_in:
    #   - grains: grains-set-restart-status
    #   - cmd: command-restart-splunk

# install-splunk:
#   pkg.installed:
#     - name: splunk
#     - enable: True
#     - skip_verify: True
#     - sources:
#       - splunk: {{ package_source }}
