# = Define: rsyslog::imfile
#
# This defines creates an entry in rsyslod.d to manage via rsyslog
# an external log file. It's based on https://github.com/saz/puppet-rsyslog
#
# == Parameters
#
# [*file_name*]
#   The full path of the file to monitor. Required.
#
# [*file_tag*]
#   A custom tag for the file. Required.

# [*file_facility*]
#   The log facility. Default: user
#
# [*file_severity*]
#   The log severity. Default: notice
#
# [*polling_interval*]
#   Rsyslog polling interval on the log, in secords. Default: 10
#
# [*run_file_monitor*]
#   If to enable file monitoring. Default true
#
# [*template*]
#   Optional custom template to use to create the file in rsyslog.d
#   Default: 'rsyslog/imfile.erb'
#
# [*order*]
#   The order with which the file is created in rsyslog.d
#
# [*ensure*]
#   Default: present. Set to absent to remove a proviously defined file
#
# == Examples
#
#  rsyslog::imfile { 'apache-error':
#    file_name     => '/var/log/apache/error.log',
#    file_tag      => 'apache--error',
#    file_facility => 'warn',
#  }
#
define softec_rsyslog::imfile (
  $file_name,
  $file_dir,
  $file_tag,
  $file_facility    = 'user',
  $file_severity    = 'notice',
  $polling_interval = 10,
  $run_file_monitor = true ,
  $template         = 'rsyslog/imfile.erb',
  $order            = '25',
  $ensure           = present,
  $logrotate        = true,
  $rotate           = 'daily',
  $retention_days   = '180',
  $create           = '644 root super',
  ) {

  rsyslog::imfile {$name:
    file_name         => "${file_dir}/$file_name",
    file_tag          => $file_tag,
    file_facility     => $file_facility,
    file_severity     => $file_severity,
    polling_interval  => $polling_interval,
    run_file_monitor  => $run_file_monitor,
    template          => $template,
    order             => $order,
    ensure            => $ensure,
  }

  if $logrotate {
    logrotate::file { $name:
      log           => "${file_dir}/${file_name}",
      interval      => $rotate,
      rotation      => $retention_days,
      options       => [ 'missingok', 'compress', 'notifempty' ],
      archive       => true,
      olddir        => "${file_dir}/archives",
      olddir_owner  => 'root',
      olddir_group  => 'super',
      olddir_mode   => '644',
      postrotate    => "invoke-rc.d rsyslog reload > /dev/null",
      create        => $create
    }
  }
}
