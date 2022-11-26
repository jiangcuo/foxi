#!/bin/bash
#https://foxi.buduanwang.vip/virtualization/pve/592.html/

grub_check(){
    if [ -e /etc/kernel/proxmox-boot-uuids ]
    then
    echo "引导为Systemd-boot"
    echo "正在修改cmdline"
    edit_cmdline
    else
    echo "引导为grub"
    echo "正在修改grub"    
    edit_grub
    fi
}

modiy_modules(){
    echo "正在修改内核参数"
    cp /etc/modules /opt/foxi_backup/modules_$(date +%s)
    sed -i '/kvmgt/d' /etc/modules
    echo kvmgt >> /etc/modules
    sed -i '/915/d' /etc/modprobe.d/*
    sed -i '/8086/d' /etc/modprobe.d/*
    update-initramfs -u > /dev/null 2>&1
    echo "内核参数修改完成"
}


edit_cmdline(){
    cp /etc/kernel/cmdline /opt/foxi_backup/cmdline_$(date +%s)
    echo  `cat /etc/kernel/cmdline` 'quiet intel_iommu=on i915.enable_gvt=1' > /etc/kernel/cmdline
    proxmox-boot-tool refresh > /dev/null 2>&1
    echo "cmdline修改完成"
}
edit_grub(){
    cp /etc/default/grub  /opt/foxi_backup/grub_$(date +%s)
    sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/d' /etc/default/grub
    sed -i '/GRUB_CMDLINE_LINUX/i GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on i915.enable_gvt=1"' /etc/default/grub
    update-grub > /dev/null 2>&1
    echo "grub修改完成"
}


echo "这是一个自动配置gvt-g的脚本"
echo "本脚本不检测硬件类型，请自己确保符合条件"
echo "请访问 https://foxi.buduanwang.vip/virtualization/pve/592.html/ 查看更多"

read -p "请按y/Y继续" configure
if [ $configure = "y" ] || [ $configure = "Y" ] 
then
echo "开始检测引导类型"
mkdir /opt/foxi_backup > /dev/null 2>&1
grub_check
else
echo "输入错误，脚本退出"
exit 0
fi
modiy_modules
echo "脚本执行完成，请重启"
echo "其中grub和modules文件已经备份到/opt/foxi_backup目录下"
echo "重启之后，请运行命令 lsmod|grep kvmgt 有输出即代表成功"
