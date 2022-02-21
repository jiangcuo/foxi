#!/usr/bin/perl
#https://foxi.buduanwang.vip
use PVE::QemuServer;

use strict;
use warnings;

print "GUEST HOOK: ".join(' ', @ARGV).
"\n";
my $vmid = shift;
my $conf = PVE::QemuConfig->load_config($vmid);
my $phase = shift;
my $vmpath = "/mnt/pve/Nvme"
my $cmd ="qemu-img snapshot -a snapshot $vmpath/images/$vmid/vm-$vmid-disk-0.qcow2";

if ($phase eq 'pre-start') {
  print "$vmid is starting, doing preparations.\n";
}
elsif($phase eq 'post-start') {
  print "$vmid started successfully.\n";
}
elsif($phase eq 'pre-stop') {
  print "$vmid will be stopped.\n";
}
elsif($phase eq 'post-stop') {
  print "$vmid stopped. Doing cleanup.\n";
  system("$cmd");
  print "done\n";
} else {
  die "got unknown phase '$phase'\n";
}
exit(0);