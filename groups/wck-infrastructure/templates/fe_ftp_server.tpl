write_files:
  - path: /etc/vsftpd/vsftpd.conf
    owner: root:root
    permissions: 0600
    content: |
      # Allow anonymous FTP? (Beware - allowed by default if you comment this out).
      anonymous_enable=YES
      anon_root=${root_dir}
      dirlist_enable=no
      #
      # Uncomment this to allow local users to log in.
      local_enable=NO
      #
      # Uncomment this to enable any form of FTP write command.
      write_enable=NO
      #
      # Default umask for local users is 077. You may wish to change this to 022,
      # if your users expect that (022 is used by most other ftpd's)
      local_umask=022
      #
      # Uncomment this to allow the anonymous FTP user to upload files. This only
      # has an effect if the above global write enable is activated. Also, you will
      # obviously need to create a directory writable by the FTP user.
      #anon_upload_enable=YES
      #
      # Uncomment this if you want the anonymous FTP user to be able to create
      # new directories.
      #anon_mkdir_write_enable=YES
      #
      # Activate directory messages - messages given to remote users when they
      # go into a certain directory.
      dirmessage_enable=YES
      #
      # The target log file can be vsftpd_log_file or xferlog_file.
      # This depends on setting xferlog_std_format parameter
      xferlog_enable=YES
      #
      # Make sure PORT transfer connections originate from port 20 (ftp-data).
      connect_from_port_20=YES
      #
      # If you want, you can arrange for uploaded anonymous files to be owned by
      # a different user. Note! Using "root" for uploaded files is not
      # recommended!
      #chown_uploads=YES
      #chown_username=whoever
      #
      # The name of log file when xferlog_enable=YES and xferlog_std_format=YES
      # WARNING - changing this filename affects /etc/logrotate.d/vsftpd.log
      #xferlog_file=/var/log/xferlog
      #
      # Switches between logging into vsftpd_log_file and xferlog_file files.
      # NO writes to vsftpd_log_file, YES to xferlog_file
      xferlog_std_format=YES
      #
      # You may change the default value for timing out an idle session.
      #idle_session_timeout=600
      #
      # You may change the default value for timing out a data connection.
      #data_connection_timeout=120
      #
      # It is recommended that you define on your system a unique user which the
      # ftp server can use as a totally isolated and unprivileged user.
      #nopriv_user=ftpsecure
      #
      # Enable this and the server will recognise asynchronous ABOR requests. Not
      # recommended for security (the code is non-trivial). Not enabling it,
      # however, may confuse older FTP clients.
      #async_abor_enable=YES
      #
      # By default the server will pretend to allow ASCII mode but in fact ignore
      # the request. Turn on the below options to have the server actually do ASCII
      # mangling on files when in ASCII mode.
      # Beware that on some FTP servers, ASCII support allows a denial of service
      # attack (DoS) via the command "SIZE /big/file" in ASCII mode. vsftpd
      # predicted this attack and has always been safe, reporting the size of the
      # raw file.
      # ASCII mangling is a horrible feature of the protocol.
      #ascii_upload_enable=YES
      #ascii_download_enable=YES
      #
      # You may fully customise the login banner string:
      ftpd_banner=Companies House WebCHeck
      #
      # You may specify a file of disallowed anonymous e-mail addresses. Apparently
      # useful for combatting certain DoS attacks.
      #deny_email_enable=YES
      # (default follows)
      #banned_email_file=/etc/vsftpd/banned_emails
      #
      # You may specify an explicit list of local users to chroot() to their home
      # directory. If chroot_local_user is YES, then this list becomes a list of
      # users to NOT chroot().
      #chroot_local_user=YES
      #chroot_list_enable=YES
      # (default follows)
      #chroot_list_file=/etc/vsftpd/chroot_list
      #
      # You may activate the "-R" option to the builtin ls. This is disabled by
      # default to avoid remote users being able to cause excessive I/O on large
      # sites. However, some broken FTP clients such as "ncftp" and "mirror" assume
      # the presence of the "-R" option, so there is a strong case for enabling it.
      #ls_recurse_enable=YES
      #
      # When "listen" directive is enabled, vsftpd runs in standalone mode and
      # listens on IPv4 sockets. This directive cannot be used in conjunction
      # with the listen_ipv6 directive.
      listen=YES
      listen_port=21
      #
      # This directive enables listening on IPv6 sockets. To listen on IPv4 and IPv6
      # sockets, you must run two copies of vsftpd with two configuration files.
      # Make sure, that one of the listen options is commented !!
      #listen_ipv6=YES

      pam_service_name=vsftpd
      userlist_enable=YES
      tcp_wrappers=YES

      # Passive config
      pasv_enable=YES
      pasv_max_port=${int_passive_ports_end}
      pasv_min_port=${int_passive_ports_start}
      pasv_address=

  - path: /etc/vsftpd/vsftpd-external.conf
    owner: root:root
    permissions: 0600
    content: |
      # Allow anonymous FTP? (Beware - allowed by default if you comment this out).
      anonymous_enable=YES
      anon_root=${root_dir}
      dirlist_enable=no
      #
      # Uncomment this to allow local users to log in.
      local_enable=NO
      #
      # Uncomment this to enable any form of FTP write command.
      write_enable=NO
      #
      # Default umask for local users is 077. You may wish to change this to 022,
      # if your users expect that (022 is used by most other ftpd's)
      local_umask=022
      #
      # Uncomment this to allow the anonymous FTP user to upload files. This only
      # has an effect if the above global write enable is activated. Also, you will
      # obviously need to create a directory writable by the FTP user.
      #anon_upload_enable=YES
      #
      # Uncomment this if you want the anonymous FTP user to be able to create
      # new directories.
      #anon_mkdir_write_enable=YES
      #
      # Activate directory messages - messages given to remote users when they
      # go into a certain directory.
      dirmessage_enable=YES
      #
      # The target log file can be vsftpd_log_file or xferlog_file.
      # This depends on setting xferlog_std_format parameter
      xferlog_enable=YES
      #
      # Make sure PORT transfer connections originate from port 20 (ftp-data).
      connect_from_port_20=YES
      #
      # If you want, you can arrange for uploaded anonymous files to be owned by
      # a different user. Note! Using "root" for uploaded files is not
      # recommended!
      #chown_uploads=YES
      #chown_username=whoever
      #
      # The name of log file when xferlog_enable=YES and xferlog_std_format=YES
      # WARNING - changing this filename affects /etc/logrotate.d/vsftpd.log
      #xferlog_file=/var/log/xferlog
      #
      # Switches between logging into vsftpd_log_file and xferlog_file files.
      # NO writes to vsftpd_log_file, YES to xferlog_file
      xferlog_std_format=YES
      #
      # You may change the default value for timing out an idle session.
      #idle_session_timeout=600
      #
      # You may change the default value for timing out a data connection.
      #data_connection_timeout=120
      #
      # It is recommended that you define on your system a unique user which the
      # ftp server can use as a totally isolated and unprivileged user.
      #nopriv_user=ftpsecure
      #
      # Enable this and the server will recognise asynchronous ABOR requests. Not
      # recommended for security (the code is non-trivial). Not enabling it,
      # however, may confuse older FTP clients.
      #async_abor_enable=YES
      #
      # By default the server will pretend to allow ASCII mode but in fact ignore
      # the request. Turn on the below options to have the server actually do ASCII
      # mangling on files when in ASCII mode.
      # Beware that on some FTP servers, ASCII support allows a denial of service
      # attack (DoS) via the command "SIZE /big/file" in ASCII mode. vsftpd
      # predicted this attack and has always been safe, reporting the size of the
      # raw file.
      # ASCII mangling is a horrible feature of the protocol.
      #ascii_upload_enable=YES
      #ascii_download_enable=YES
      #
      # You may fully customise the login banner string:
      ftpd_banner=Companies House WebCHeck
      #
      # You may specify a file of disallowed anonymous e-mail addresses. Apparently
      # useful for combatting certain DoS attacks.
      #deny_email_enable=YES
      # (default follows)
      #banned_email_file=/etc/vsftpd/banned_emails
      #
      # You may specify an explicit list of local users to chroot() to their home
      # directory. If chroot_local_user is YES, then this list becomes a list of
      # users to NOT chroot().
      #chroot_local_user=YES
      #chroot_list_enable=YES
      # (default follows)
      #chroot_list_file=/etc/vsftpd/chroot_list
      #
      # You may activate the "-R" option to the builtin ls. This is disabled by
      # default to avoid remote users being able to cause excessive I/O on large
      # sites. However, some broken FTP clients such as "ncftp" and "mirror" assume
      # the presence of the "-R" option, so there is a strong case for enabling it.
      #ls_recurse_enable=YES
      #
      # When "listen" directive is enabled, vsftpd runs in standalone mode and
      # listens on IPv4 sockets. This directive cannot be used in conjunction
      # with the listen_ipv6 directive.
      listen=YES
      listen_port=2121
      #
      # This directive enables listening on IPv6 sockets. To listen on IPv4 and IPv6
      # sockets, you must run two copies of vsftpd with two configuration files.
      # Make sure, that one of the listen options is commented !!
      #listen_ipv6=YES

      pam_service_name=vsftpd
      userlist_enable=YES
      tcp_wrappers=YES

      # Passive config
      pasv_enable=YES
      pasv_max_port=${ext_passive_ports_end}
      pasv_min_port=${ext_passive_ports_start}
      pasv_address=


runcmd:
  - sed -i '/Required-Start/ s/$/ nfs-watcher httpd/'  /etc/init.d/vsftpd
  - |
    az=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
    int_ip=$(dig +short $${az}.${internal_nlb_name})
    ext_ip=$(dig +short $${az}.${external_nlb_name})
    sed -i "s/^pasv_address=.*/pasv_address=$${int_ip}/" /etc/vsftpd/vsftpd.conf
    sed -i "s/^pasv_address=.*/pasv_address=$${ext_ip}/" /etc/vsftpd/vsftpd-external.conf
  - 'echo "vsftpd: ALL" >> /etc/hosts.allow'
  - chkconfig vsftpd on
