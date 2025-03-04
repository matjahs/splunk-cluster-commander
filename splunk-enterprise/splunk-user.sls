# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "splunk-enterprise/map.jinja" import host_lookup as config with context %}

# Configure additional settings for the splunk user
user-manage-splunk:
  user.present:
    - name: splunk
    - shell: /bin/bash
    - home: /opt/splunk
    - createhome: False
    - usergroup: True
    - optional_groups:
      - adm
      - syslog

/opt/splunk:
  file.directory:
    - user: splunk
    - group: splunk
    - mode: '0750'
    - makedirs: True
    - require:
      - user: user-manage-splunk

# Add sudoers config to allow service restarts as splunk user
/etc/sudoers.d/splunk:
  file.managed:
    - user: root
    - group: root
    - mode: '0440'
    - contents: |
        %splunk ALL = (root) NOPASSWD: /bin/systemctl start Splunkd.service
        %splunk ALL = (root) NOPASSWD: /bin/systemctl stop Splunkd.service
        %splunk ALL = (root) NOPASSWD: /bin/systemctl restart Splunkd.service
    - require:
      - user: user-manage-splunk

# Configure the initial password using a seed file
/opt/splunk/etc/system/local/user-seed.conf:
  file.managed:
    - user: splunk
    - group: splunk
    - mode: '0640'
    - contents: |
        [user_info]
        USERNAME = {{ config.splunk.admin_user }}
        PASSWORD = {{ config.splunk.current_admin_pass }}
    - output_loglevel: quiet
    - onchanges_in:
      - grains: grains-set-restart-status
      - cmd: command-restart-splunk
    - onlyif:
      - test ! -f /opt/splunk/etc/system/local/user-seed.conf && exit 0
      - test ! -f /opt/splunk/etc/passwd && exit 0

