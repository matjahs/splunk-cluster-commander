# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "splunk-enterprise/map.jinja" import host_lookup as config with context %}
{% if config.firewall.iptables.status == 'Active' %}

# add some firewall magic
include:
  - firewall.iptables

{% elif config.firewall.iptables.status == 'InActive' %}

# If no configuration is imported disable iptables
service-iptables:
  service.dead:
    - name: iptables
    - enable: False
    - unless: systemctl is-active iptables |grep inactive

{% endif %}
