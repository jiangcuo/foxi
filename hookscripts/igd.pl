#!/usr/bin/perl
#https://foxi.buduanwang.vip
use PVE::QemuServer;

use strict;
use warnings;

print "GUEST HOOK: ".join(' ', @ARGV).
"\n";

my $igd_id = system("lspci -n|grep '0:02.0'|cut -d ':' -f4|cut -c 1-4 > /tmp/igd_id");
my $vmid = shift;
my $conf = PVE::QemuConfig->load_config($vmid);
my $phase = shift;

if ($phase eq 'pre-start') {
  print "$vmid is starting, doing preparations.\n";
  system("echo 0000:00:02.0 > /sys/bus/pci/drivers/i915/unbind");
  system("modprobe  -r i915");
  system("echo 8086 `cat /tmp/igd_id`  > /sys/bus/pci/drivers/vfio-pci/new_id");
}
elsif($phase eq 'post-start') {
  print "$vmid started successfully.\n";
}
elsif($phase eq 'pre-stop') {
  print "$vmid will be stopped.\n";
}
elsif($phase eq 'post-stop') {
  print "$vmid stopped. Doing cleanup.\n";
  system("echo 8086 `cat /tmp/igd_id`  > /sys/bus/pci/drivers/vfio-pci/remove_id");
  system("echo 0000:00:02.0 > /sys/bus/pci/drivers/vfio-pci/unbind");
  system("modprobe i915");
} else {
  die "got unknown phase '$phase'\n";
}

exit(0);
