{% if grains['os'] == "Windows" %}
update_config_fail:
  test.configurable_test_state:
    - name: update_config_fail
    - changes: False
    - result: False
    - comment: |
         NOTICE: update_config is not for Windows, probably you run rsnapshot_backup pipeline for Windows server - it is wrong.

{% elif pillar['rsnapshot_backup'] is defined and 'sources' in pillar['rsnapshot_backup'] %}

rsnapshot_backup_dir:
  file.directory:
    - name: /opt/sysadmws/rsnapshot_backup
    - user: root
    - group: root
    - mode: 775
    - makedirs: True

rsnapshot_backup_conf:
  file.serialize:
    - name: /opt/sysadmws/rsnapshot_backup/rsnapshot_backup.conf
    - user: root
    - group: root
    - mode: 660
    - show_changes: True
    - create: True
    - merge_if_exists: False
    - formatter: json
    - dataset:
        - enabled: False # The first item in the dataset list is always empty, just to have at least somthing in the list, if no backups found (empty dataset produces errors)
          comment: This file is managed by Salt, local changes will be overwritten.
  # Add negative priority items
  {%- for priority in [-10, -9, -8, -7, -6, -5, -4, -3, -2, -1] %}
    {%- for host, host_backups in pillar['rsnapshot_backup']['sources'].items()|sort %}
      {%- for host_backups_item in host_backups %}
        {%- if host_backups_item['type'] != 'SUPPRESS_COVERAGE' %}
          {%- for backup in host_backups_item['backups'] %}
            {%- if grains['fqdn'] == backup['host'] %}
              {%- if backup['priority'] is defined and backup['priority'] is not none and priority == backup['priority']|int %}
                {%- include 'rsnapshot_backup/update_config.jinja' with context %}
              {%- endif  %}
            {%- endif  %}
          {%- endfor %}
        {%- endif  %}
      {%- endfor %}
    {%- endfor %}
  {%- endfor %}
  # Add no priority items
  {%- for host, host_backups in pillar['rsnapshot_backup']['sources'].items()|sort %}
    {%- for host_backups_item in host_backups %}
      {%- if host_backups_item['type'] != 'SUPPRESS_COVERAGE' %}
        {%- for backup in host_backups_item['backups'] %}
          {%- if grains['fqdn'] == backup['host'] %}
            {%- if backup['priority'] is not defined or backup['priority'] is none %}
              {%- include 'rsnapshot_backup/update_config.jinja' with context %}
            {%- endif  %}
          {%- endif  %}
        {%- endfor %}
      {%- endif  %}
    {%- endfor %}
  {%- endfor %}
  # Add positive priority items
  {%- for priority in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] %}
    {%- for host, host_backups in pillar['rsnapshot_backup']['sources'].items()|sort %}
      {%- for host_backups_item in host_backups %}
        {%- if host_backups_item['type'] != 'SUPPRESS_COVERAGE' %}
          {%- for backup in host_backups_item['backups'] %}
            {%- if grains['fqdn'] == backup['host'] %}
              {%- if backup['priority'] is defined and backup['priority'] is not none and priority == backup['priority']|int %}
                {%- include 'rsnapshot_backup/update_config.jinja' with context %}
              {%- endif  %}
            {%- endif  %}
          {%- endfor %}
        {%- endif  %}
      {%- endfor %}
    {%- endfor %}
  {%- endfor %}

{% else %}
rsnapshot_backup_dir:
  file.directory:
    - name: /opt/sysadmws/rsnapshot_backup
    - user: root
    - group: root
    - mode: 775
    - makedirs: True

# Just empty config if not exists - not to overwrite manually created config
  {%- if not salt['file.file_exists']('/opt/sysadmws/rsnapshot_backup/rsnapshot_backup.conf') %}
rsnapshot_backup_conf:
  file.serialize:
    - name: /opt/sysadmws/rsnapshot_backup/rsnapshot_backup.conf
    - user: root
    - group: root
    - mode: 660
    - show_changes: True
    - create: True
    - merge_if_exists: False
    - formatter: json
    - dataset:
        - enabled: False # The first item in the dataset list is always empty, just to have at least somthing in the list, if no backups found (empty dataset produces errors)
          comment: This file is managed by Salt, local changes will be overwritten.

  {%- endif %}
{% endif %}
