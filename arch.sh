#!/bin/sh
: 'Copyright (C) 2019 Código Cristo

Copyright Original (C) del 2015
Por Andrés Quiceno Hernández y Mario Gordillo Ortiz
Licencia Pública General de GNU, ver <http://www.gnu.org/licenses/>'
#!/bin/bash

#Poniendo el sistema en español
clear
echo es_ES.UTF-8 UTF-8 > /etc/locale.gen
for i in $(seq 1 100)
do
    sleep 0.02
    echo $i
done | whiptail --title " Cargando Idioma " --gauge "$(locale-gen)" 7 60 0
echo LANG=es_ES.UTF-8 > /etc/locale.conf
export LANG=es_ES.UTF-8

#Inicio
#dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title " Bienvenido " --stdout --ok-label 'Siguiente' --msgbox 'Instalación en Español:' 5 32
dialog --backtitle "| Instalación de ArchLinux - https://t.me/ArchLinuxCristo |" --stdout --ok-label 'Siguiente' --title "| INICIO |" --msgbox "\n| Bienvenido a la instalación de Arch Linux en Español |" 7 60 



dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "Conexión WiFi" --yesno "¿Quieres conectarte a una red wifi?" 5 45 
case $? in 
	0) wifi-menu 
		wifinet=$(netctl list | awk -F " " '{print $2}');;
	1) 
esac
umount -R /mnt

selected=0 
while [ $selected == "0" ];do 
	locales="$(localectl list-keymaps | awk '$locales=$locales" Keyboard"')" && locales=$(echo "$locales") 
	keyboard=$(dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --clear --title "| Define la distribución del teclado: |" --menu " > la-latin1 (LatinoAmerica) \n > es (Español) \n > us (Americano)" 0 0 0 	${locales} 2>&1 > /dev/tty) 
	if [ $? == 0 ];then 
		loadkeys $keyboard 
		keymap=$keyboard 
		selected=1 
	else 
		dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| ERROR |" --stdout --ok-label 'Siguiente' --msgbox "Ingrese una distribución del teclado para continuar" 5 55 
	fi
done



dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| Importante |" --stdout  --ok-label 'Siguiente'  \
--msgbox "\n> UEFI trabaja con discos en GPT \n\n> UEFI su partición boot es formateada en FAT32 \n\n> BIOS LEGACY trabaja con discos en DOS/MBR\n\n> BIOS LEGACY su partición boot es formateada en EXT4\n( La partición boot en linux es opcional )" 14 0


part="$(echo "print devices" | parted | grep /dev/ | awk '{if (NR!=1) {print}}')" 
disk=$(dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --clear --title "| Selección de Disco |"  --menu "Elige el disco para Linux" 0 0 0 ${part} 2>&1 >/dev/tty)

fdisk -l $disk > /tmp/partitions


#SISTEMA UEFI O BIOS
uefi=$( parted $disk print | grep -ic gpt )

parted $disk print | grep gpt > uefi2.txt
echo "Partition Table: gpt" > uefi3.txt

if [ $uefi == 1 ] && [ -d /sys/firmware/efi ]
then
dialog --backtitle "|  SISTEMA UEFI Y DISCO GPT  |" --title "|  UEFI y su disco SI es compatible |"  --stdout --ok-label 'Siguiente' --msgbox "$(echo "" && cat /tmp/partitions | grep gpt && echo "" && cat /tmp/partitions | grep /dev/ )" 12 150

elif [ $uefi == 0 ] && [ -d /sys/firmware/efi ]
then
dialog --backtitle "| SISTEMA BIOS LEGACY Y DISCO INCOMPATIBLE |" --title "|  BIOS LEGACY y su disco NO es compatible |" \
--yesno "\nConvertir su disco DOS/MBR a GPT\nAl convertir su disco perderá toda su información \
\nSi tiene otras particiones en el Disco\nNo realice la conversión \n\n¿Desea convertir su disco Dos/MBR a GPT?" 12 65
case $? in 
	0)clear
	echo ""
	echo ""
	echo "        ///////////////////////////////////||"
	echo "        //                                 ||"
	echo "        //   Confirme escribiendo          ||"
	echo "        //                                 ||"
	echo "        //          >>> Yes   <<<          ||"
	echo "        //                                 ||"
	echo "        //      Y presionando ENTER        ||"
	echo "        //   Para realizar la conversión   ||"
	echo "        //                                 ||"
	echo "        ///////////////////////////////////||"
	echo ""
	echo ""
	parted "$disk" mklabel gpt
	sleep 2;;
	1)exit
esac

elif [ $uefi == 0 ]
then
dialog --backtitle "|  SISTEMA BIOS LEGACY Y DISCO DOS/MBR  |" --title "| BIOS LEGACY y su disco SI es compatible |"  --stdout --ok-label 'Siguiente' --msgbox "$(echo "" && cat /tmp/partitions | grep dos && echo "" && cat /tmp/partitions | grep /dev/ )" 12 150

else  

dialog --backtitle "| SISTEMA BIOS LEGACY Y DISCO INCOMPATIBLE |" --title "|  BIOS LEGACY y su disco NO es compatible |" \
--yesno "\nConvertir su disco GPT a DOS/MBR\nAl convertir su disco perderá toda su información \
\nSi tiene otras particiones en el Disco\nNo realice la conversión \n\n¿Desea convertir su disco GPT a DOS/MBR?" 12 65
case $? in 
	0)clear
	echo ""
	echo ""
	echo "        ///////////////////////////////////||"
	echo "        //                                 ||"
	echo "        //   Confirme escribiendo          ||"
	echo "        //                                 ||"
	echo "        //          >>> Yes   <<<          ||"
	echo "        //                                 ||"
	echo "        //      Y presionando ENTER        ||"
	echo "        //   Para realizar la conversión   ||"
	echo "        //                                 ||"
	echo "        ///////////////////////////////////||"
	echo ""
	echo ""
	parted "$disk" mklabel msdos
	sleep 2;;
	1)exit
esac
fi


partitioner=$(dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --clear --title "| ELIGE UN PROGRAMA PARA CREAR PARTICIONES |" --menu " " 0 0 0\
		"cfdisk" "Un particionador casi grafico" \
		"fdisk" "Un particionador de linea de comandos" \
		"parted" "Un particionador de linea de comandos" 2>&1 > /dev/tty)
$partitioner $disk

fdisk -l "$disk" > /tmp/partitions

partitions="$(cat /tmp/partitions | grep /dev/ | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1,$5}')"
p="$(echo "$partitions")"
part=$(dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --clear --title "| Elige la partición del Administrador |" \
	--menu "Root: /" 0 0 0 ${p} 2>&1 > /dev/tty)
rootfs=$part
p=$(echo "$p" | grep -v $part)


partitioning(){
	fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}' | grep -v cramfs | grep -v hfsplus | grep -v  bfs | grep -v msdos | grep -v minix)"
	format=$(dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --clear --title "| FORMATO DE PARTICIÓN |" \
					--menu "\nElige el tipo de sistema de archivos\n\nEXT4 >> Para Linux\nVFAT >> Para FAT32 UEFI\nNTFS >> Para Windows\n\n<Cancelar> para no formatear" 0 0 0 ${fs} 2>&1 > /dev/tty)
			
	case $format in
		ext4) dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| Formateando partición en EXT4 |" --stdout --ok-label "Siguiente" --prgbox "echo "" && mkfs.ext4 -F $part" 20 80;;
		reiserfs) mkfs.reiserfs -f -f "$part" | dialog --progressbox "Formateando partición en ReiserFS..." 50 20000; sleep 3;;
		vfat) dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| Formateando partición en FAT 32 | Uso General para particiones UEFI... |" --stdout --ok-label "Siguiente" --prgbox "echo "" && mkfs.fat -F 32 $part" 7 80;;
		ntfs) mkfs.ntfs -q "$part" | dialog --progressbox "Formateando partición en NTFS de Windows..." 50 20000; sleep 3;;
		jfs) mkfs.jfs -q "$part" | dialog --progressbox "Formateando partición en JFS..." 50 20000; sleep 3;;
		nilfs2) mkfs.nilfs2 -f "$part" | dialog --progressbox "Formateando partición en NILFS2..." 50 20000; sleep 3;;
		xfs) mkfs.xfs -f "$part" | dialog --progressbox "Formateando partición en XFS..." 50 20000; sleep 3;;
		btrfs) mkfs.btrfs -f "$part" | dialog --progressbox "Formateando partición en BTRFS..." 50 20000; sleep 3;;
	esac
}

partitioning


cmd=(dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --separate-output --checklist "Selecciona otros puntos de montajes:\n[SPACE] para marcar varias opciones" 0 0 0)
options=("/boot" "Archivos estáticos del cargador de arranque" off   
	"/home" "Archivos de usuario" off
	"/tmp" "Archivos temporales" off
	"/usr" "Datos estáticos" off
	"/var" "Datos de variables" off
	"/srv" "Datos de los servicios prestados por este sistema" off
	"/opt" "Aplicaciones de terceros o privativos" off
	"swap" "Memoria virtual RAM" off
	)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
	case $choice in
		"/boot")

#			dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| TIPO DE PARTICIÓN |" --stdout --ok-label 'Siguiente' --msgbox "$(echo "" && fdisk -l $disk | grep gpt && echo "" && fdisk -l $disk | grep /dev/ )" 11 150
			part=$(dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --clear --title "| Selecciona la partición |" \
				--menu "| Elige la partición que desea usar para: boot |" 0 0 0 ${p} 2>&1 > /dev/tty )
			bootfs="$part"

			partitioning
			bootdir="boot"
			p=$(echo "$p" | grep -v "$part")
			;;
		"/home")

#			dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| TIPO DE PARTICIÓN |" --stdout --ok-label 'Siguiente' --msgbox "$(echo "" && fdisk -l $disk | grep gpt && echo "" && fdisk -l $disk | grep /dev/ )" 11 150
			part=$(dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --clear --title "| Selecciona la partición |" \
				--menu "| Elige la partición que desea usar para: home |" 0 0 0 ${p} 2>&1 > /dev/tty )
			homefs="$part"

			partitioning
			homedir="home"
			p=$(echo "$p" | grep -v "$part")
			;;
		"/tmp")

#			dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| TIPO DE PARTICIÓN |" --stdout --ok-label 'Siguiente' --msgbox "$(echo "" && fdisk -l $disk | grep gpt && echo "" && fdisk -l $disk | grep /dev/ )" 11 150
			part=$(dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --clear --title "| Selecciona la partición |" \
				--menu "| Elige la partición que desea usar para: tmp |" 0 0 0 ${p} 2>&1 > /dev/tty )
			tmpfs="$part"

			partitioning
			tmpdir="tmp"
			p=$(echo "$p" | grep -v "$part")
			;;
		"/usr")

#			dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| TIPO DE PARTICIÓN |" --stdout --ok-label 'Siguiente' --msgbox "$(echo "" && fdisk -l $disk | grep gpt && echo "" && fdisk -l $disk | grep /dev/ )" 11 150
			part=$(dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --clear --title "| Selecciona la partición |" \
				--menu "| Elige la partición que desea usar para: usr |" 0 0 0 ${p} 2>&1 > /dev/tty )
			usrfs="$part"

			partitioning
			usrdir="usr"
			p=$(echo "$p" | grep -v "$part")
			;;
		"/var")

#			dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| TIPO DE PARTICIÓN |" --stdout --ok-label 'Siguiente' --msgbox "$(echo "" && fdisk -l $disk | grep gpt && echo "" && fdisk -l $disk | grep /dev/ )" 11 150
			part=$(dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --clear --title "| Selecciona la partición |" \
				--menu "| Elige la partición que desea usar para: var |" 0 0 0 ${p} 2>&1 > /dev/tty )
			varfs="$part"

			partitioning
			vardir="var"
			p=$(echo "$p" | grep -v "$part")
			;;
		"/srv")

#			dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| TIPO DE PARTICIÓN |" --stdout --ok-label 'Siguiente' --msgbox "$(echo "" && fdisk -l $disk | grep gpt && echo "" && fdisk -l $disk | grep /dev/ )" 11 150
			part=$(dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --clear --title "| Selecciona la partición |" \
				--menu "| Elige la partición que desea usar para: srv |" 0 0 0 ${p} 2>&1 > /dev/tty )
			srvfs="$part"

			partitioning
			srvdir="srv"
			p=$(echo "$p" | grep -v "$part")
			;;
		"/opt")

#			dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| TIPO DE PARTICIÓN |" --stdout --ok-label 'Siguiente' --msgbox "$(echo "" && fdisk -l $disk | grep gpt && echo "" && fdisk -l $disk | grep /dev/ )" 11 150
			part=$(dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --clear --title "| Selecciona la partición |" \
				--menu "| Elige la partición que desea usar para: opt |" 0 0 0 ${p} 2>&1 > /dev/tty )
			optfs="$part"

			partitioning
			optdir="opt"
			p=$(echo "$p" | grep -v "$part")
			;;
		"swap")
#			dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| TIPO DE PARTICIÓN |" --stdout --ok-label 'Siguiente' --msgbox "$(echo "" && fdisk -l $disk | grep gpt && echo "" && fdisk -l $disk | grep /dev/ )" 11 150
			part=$(dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --clear --title "| Selecciona la partición |" \
				--menu "| Elige la partición que desea usar para: swap |" 0 0 0 ${p} 2>&1 > /dev/tty)
			dialog --title "| Formateando Swap Linux |" --stdout --ok-label "Siguiente" --prgbox "echo "" && mkswap $part && swapon $part" 10 100

			swap="$part"
			p=$(echo "$p" | grep -v "$part")
	esac
done

clear
mount "$rootfs" /mnt
mkdir -p /mnt/{"$bootdir","$homedir","$tmpdir","$usrdir","$vardir","$srvdir","$optdir"}
mount "$bootfs" /mnt/boot
mount "$homefs" /mnt/home
mount "$tmpfs" /mnt/tmp
mount "$usrfs" /mnt/usr
mount "$varfs" /mnt/var
mount "$srvfs" /mnt/srv
mount "$optfs" /mnt/opt
clear
sed -i "/Color/s/^#//g" /etc/pacman.conf
sed -i "/TotalDonwload/s/^#//g" /etc/pacman.conf
sed -i "/VerbosePkgLists/s/^#//g" /etc/pacman.conf
sed -i "39iILoveCandy" /etc/pacman.conf

dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| Instalando Reflector en el LiveCD... |" --stdout --ok-label "Siguiente" --prgbox "pacman -Sy reflector --noconfirm" 25 80
clear
echo ""
pacman-key --populate archlinux 
echo ""
echo "  Claves Actualizadas del LiveCD, Espere..."
echo ""
echo ""
reflector -l 5 --sort rate --save /etc/pacman.d/mirrorlist
for i in $(seq 1 100)
do
    sleep 0.07 
    echo $i
done | whiptail --title ' Actualizando MirrorLists ' --gauge "\nActualizando MirrorList en el LiveCD..." 7 60 0

cat /etc/pacman.d/mirrorlist | dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --progressbox "Mirrors List del LiveCD > Actualizadas..." 25 2000; sleep 3




kernel_var=0 
while [ "$kernel_var" = "0" ] ; do

  kernel_select=`dialog --title "| KERNEL LINUX |" --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" \
    --stdout --no-cancel --menu "Elige que kernel necesitas: \nLinux Stable es la mejor opción para iniciar\nLas otras opciones tienen un estilo diferente para instalar Drivers\nLas otras modificaciones del kernel trabajan con Drivers Libres" 16 0 2000 linux-stable "Kernel en su versión estable y módulos de Vanilla Linux" linux-hardened "Kernel enfocado en Seguridad" linux-lts "Kernel con soporte de larga duración" linux-zen "Kernel del esfuerzo colaborativo de varios hackers"`
   
  if [ $kernel_select == linux-stable ]; then
dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| Instalando Sistema Base - Linux Stable |" --stdout --ok-label "Siguiente" --prgbox "pacstrap /mnt base base-devel linux linux-headers linux-firmware mkinitcpio pulseaudio pavucontrol nano reflector dhcp dhcpcd dhclient ppp netctl iw iwd net-tools networkmanager ifplugd openssh dialog" 25 80
dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "Conexión WiFi" --yesno "\n¿Tienes Tarjeta de Wifi?" 7 45 
case $? in 
	0) dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| Instalando Sistema Base - Linux Stable |" --stdout --ok-label "Siguiente" --prgbox "pacstrap /mnt broadcom-wl wireless-regdb wpa_supplicant wireless_tools" 25 80;;
	1) 
esac
dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "Laptops" --yesno "\n¿Tienes Touchpad?" 7 45 
case $? in 
	0) dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| Instalando Sistema Base - Linux Stable |" --stdout --ok-label "Siguiente" --prgbox "pacstrap  /mnt xf86-input-synaptics xf86-input-libinput xorg-xinput" 25 80;;
	1) 
esac
dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "Laptops" --yesno "\n¿Tienes Bluetooth?" 7 45 
case $? in 
	0) dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| Instalando Sistema Base - Linux Stable |" --stdout --ok-label "Siguiente" --prgbox "pacstrap /mnt bluez bluez-utils pulseaudio-bluetooth blueman" 25 80
	systemctl enable bluetooth.service;;
	1) 
esac
  kernel_var=1


  elif [ $kernel_select == linux-hardened ]; then
dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| Instalando Sistema Base - Linux Hardened |" --stdout --ok-label "Siguiente" --prgbox "pacstrap /mnt base base-devel linux-hardened linux-hardened-headers linux-firmware mkinitcpio pulseaudio pavucontrol nano reflector dhcp dhcpcd dhclient ppp netctl iw iwd net-tools networkmanager ifplugd openssh dialog" 25 80
dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "Conexión WiFi" --yesno "\n¿Tienes Tarjeta de Wifi?" 7 45 
case $? in 
	0) dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| Instalando Sistema Base - Linux Hardened |" --stdout --ok-label "Siguiente" --prgbox "pacstrap /mnt wpa_supplicant wireless_tools" 25 80;;
	1) 
esac
dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "Laptops" --yesno "\n¿Tienes Touchpad?" 7 45 
case $? in 
	0) dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| Instalando Sistema Base - Linux Hardened |" --stdout --ok-label "Siguiente" --prgbox "pacstrap  /mnt xf86-input-synaptics xf86-input-libinput xorg-xinput" 25 80;;
	1) 
esac
dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "Laptops" --yesno "\n¿Tienes Bluetooth?" 7 45 
case $? in 
	0) dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| Instalando Sistema Base - Linux Hardened |" --stdout --ok-label "Siguiente" --prgbox "pacstrap /mnt bluez bluez-utils pulseaudio-bluetooth blueman" 25 80
	systemctl enable bluetooth.service;;
	1) 
esac
  kernel_var=1


  elif [ $kernel_select == linux-lts ]; then
dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| Instalando Sistema Base - Linux LTS |" --stdout --ok-label "Siguiente" --prgbox "pacstrap /mnt base base-devel linux-lts linux-lts-headers linux-firmware mkinitcpio pulseaudio pavucontrol nano reflector dhcp dhcpcd dhclient ppp netctl iw iwd net-tools networkmanager ifplugd openssh dialog" 25 80
dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "Conexión WiFi" --yesno "\n¿Tienes Tarjeta de Wifi?" 7 45 
case $? in 
	0) dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| Instalando Sistema Base - Linux LTS |" --stdout --ok-label "Siguiente" --prgbox "pacstrap /mnt wpa_supplicant wireless_tools" 25 80;;
	1) 
esac
dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "Laptops" --yesno "\n¿Tienes Touchpad?" 7 45 
case $? in 
	0) dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| Instalando Sistema Base - Linux LTS |" --stdout --ok-label "Siguiente" --prgbox "pacstrap  /mnt xf86-input-synaptics xf86-input-libinput xorg-xinput" 25 80;;
	1) 
esac
dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "Laptops" --yesno "\n¿Tienes Bluetooth?" 7 45 
case $? in 
	0) dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| Instalando Sistema Base - Linux LTS |" --stdout --ok-label "Siguiente" --prgbox "pacstrap /mnt bluez bluez-utils pulseaudio-bluetooth blueman" 25 80
	systemctl enable bluetooth.service;;
	1) 
esac
  kernel_var=1  

  elif [ $kernel_select == linux-zen ]; then
  pacstrap  /mnt  | dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --progressbox "Instalando Kernel Linux ZEN ..." 27 2000; sleep 2;kernel_var=1
 dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| Instalando Sistema Base - Linux LTS |" --stdout --ok-label "Siguiente" --prgbox "pacstrap /mnt base base-devel linux-zen linux-zen-headers linux-firmware mkinitcpio pulseaudio pavucontrol nano reflector dhcp dhcpcd dhclient ppp netctl iw iwd net-tools networkmanager ifplugd openssh dialog" 25 80
dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "Conexión WiFi" --yesno "\n¿Tienes Tarjeta de Wifi?" 7 45 
case $? in 
	0) dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| Instalando Sistema Base - Linux LTS |" --stdout --ok-label "Siguiente" --prgbox "pacstrap /mnt wpa_supplicant wireless_tools" 25 80;;
	1) 
esac
dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "Laptops" --yesno "\n¿Tienes Touchpad?" 7 45 
case $? in 
	0) dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| Instalando Sistema Base - Linux LTS |" --stdout --ok-label "Siguiente" --prgbox "pacstrap  /mnt xf86-input-synaptics xf86-input-libinput xorg-xinput" 25 80;;
	1) 
esac
dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "Laptops" --yesno "\n¿Tienes Bluetooth?" 7 45 
case $? in 
	0) dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| Instalando Sistema Base - Linux LTS |" --stdout --ok-label "Siguiente" --prgbox "pacstrap /mnt bluez bluez-utils pulseaudio-bluetooth blueman" 25 80
	systemctl enable bluetooth.service;;
	1) 
esac
  kernel_var=1  
  fi
done


#FSTAB
rm /mnt/etc/fstab 
genfstab -U -p /mnt > /mnt/etc/fstab 
dialog --backtitle "|  SISTEMA UEFI Y DISCO GPT  |" --title "| FSTAB >> Confirme que tenga el formato y ruta correcta |"   --stdout --ok-label 'Siguiente' --msgbox "$(cat /mnt/etc/fstab)" 20 1000

locales="$(cat /mnt/etc/locale.gen | grep .UTF-8 | sed '1,4d' | sed 's/\(.\{1\}\)//')"
locale=$(dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --clear --title "| Selecciona tu país |" \
	--menu "Elige tu idioma" 0 0 0 ${locales} 2>&1 > /dev/tty)
sed -i "/${locale}/ s/# *//" /mnt/etc/locale.gen


locales="$(cat /mnt/etc/locale.gen | grep .UTF-8 | sed '/#/d')"
locale=$(dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --clear --title "| Selecciona tu país |" \
	--menu "Confirma tu idioma y país" 0 0 0 ${locales} 2>&1 > /dev/tty)


echo "LANG=$locale" > /mnt/etc/locale.conf && cat /mnt/etc/locale.conf | dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --progressbox "Idioma y teclado > Actualizando" 10 50; sleep 3

arch-chroot /mnt /bin/bash -c "locale-gen" | dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --progressbox "Idioma y teclado > Actualizando" 10 50; sleep 2

arch-chroot /mnt /bin/bash -c "export $(cat /mnt/etc/locale.conf)" 

echo "KEYMAP=$keymap" > /mnt/etc/vconsole.conf && cat /mnt/etc/vconsole.conf | dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --progressbox "Idioma y teclado > Actualizando" 10 50; sleep 3

#ZONA HORARIA
URL="https://ipapi.co/timezone"
wget "$URL" 2>&1 | \
 for i_conta_zona in $(seq 1 100)
do
    sleep 0.025 
    echo $i_conta_zona
done |  \
 dialog  --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| ZONA HORARIA |" --gauge "Gracias https://ipapi.co/timezone" 6 60

dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| ZONA HORARIA |" --yesno "\nTU ZONA HORARIA ES >>> $(cat timezone)\n¿Deseeas modificar tu Zona Horaria?" 8 40 


if [ "$?" = "0" ]; then

selected=0 
timezonedir=/usr/share/zoneinfo
while [ "$selected" = "0" ] 
do

	clear
	check=$(ls -l $timezonedir | grep -v .tab | awk '/drwx/' | awk -F " " '{print $9}' | awk '{if (NR!=1) {print}}' | head -1)
	if [[ $check != America ]]; then 
		echo "../ UP" >timezones 
	fi

	ls -l $timezonedir | grep -v .tab | awk '/drwx/' | awk -F " " '{print $9}' | awk '{print $0"/"}' | awk '$fs=$fs" Time"' | awk '{if (NR!=1) {print}}'>>timezones 
	
	ls -l $timezonedir | grep -v .tab | awk '/-rw-/' | awk -F " " '{print $9}' | awk '$fs=$fs" Time"' | awk '{if (NR!=1) {print}}'>>timezones
	timezones=$(cat timezones) 
	rm timezones 
	timezone=$(dialog --backtitle "| Instalación de ArchLinux |" --clear --title "Tu Zona Horaria es $(cat timezone): " \
			--menu "Ingresa la zona horaria" 0 0 0 ${timezones} 2>&1 >/dev/tty) 
	clear
	if [ "$?" = "0" ] 
	then
		if [[ $timezone == *"/"* ]]; then 
			timezonedir=$timezonedir/$timezone
		else 
			ln -sf $timezonedir${timezone} /mnt/etc/localtime
			selected=1
		fi
	fi
done

else

ln -sf /usr/share/zoneinfo/$(cat timezone) /mnt/etc/localtime

fi



#nombre de pc (hostname)
hostname=$(dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| Hostname |" --inputbox "|  Nombre del computador  |" 0 0 2>&1 > /dev/tty)
echo "$hostname" > /mnt/etc/hostname
dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| USUARIOS y CONTRASEÑAS |" --msgbox '\n> No se permite iniciar nombre de USUARIO\n> Con números / Caracteres especiales / Mayús\n> Máximo de 8 caracteres\n> En su CLAVE no use la letra “ñ”\n> Ni letras con tilde\n> Por ejemplo: è, ü, etc...\n> Ni otros caracteres especiales\n> ~!@#$%^&*_-+=|\(){}[]:;<;>;,.?/\n\n     >>  Ya que pueden causar errores  <<' 15 50
#Clave para root
while [ $rootpasswd != $rootpasswd2 ]
do 
    rootpasswd=$(dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "|  Clave de Root  |" --insecure --passwordbox "|  Ingrese contraseña de root  |" 8 40 2>&1 > /dev/tty)
    rootpasswd2=$(dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "|  Clave de Root |" --insecure --passwordbox "|  Confirme contraseña de root  |" 8 40 2>&1 > /dev/tty)
    if [ $rootpasswd != $rootpasswd2 ];then 
     dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| Clave incorrecta |" --msgbox 'Las contraseñas no coinciden\n      Intente nuevamente...' 6 50
  else 
    clear
  fi
done

dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| Clave Correcta |" --msgbox '\nContraseña Conrrecta!' 7 40
arch-chroot /mnt /bin/sh -c "echo root:$rootpasswd | chpasswd"



#Agregando usuario
username=$(dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "|  Creación de usuario  |" \
           --form "\nIngresa tu Usuario Nuevo\n\nDebe iniciar en letra y en minúscula\nNada de caracteres especiales\n " 0 0 0 \
           " Usuario Nuevo:" 1 1 "user" 1 17 25 30 2>&1 > /dev/tty)

user=$(echo "$username" | sed -n 1p)
arch-chroot /mnt /bin/sh -c "useradd -m -g users -G video,audio,lp,optical,games,power,wheel,storage -s /bin/bash $user"
while [ $userpasswd != $userpasswd2 ]
do 
    userpasswd=$(dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "|  Contraseña de $user  |" --insecure --passwordbox "Contraseña de $user" 8 36 2>&1 > /dev/tty)
    userpasswd2=$(dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "|  Contraseña de $user  |" --insecure --passwordbox "Confirma tu clave de $user" 8 36 2>&1 > /dev/tty)
    if [ $userpasswd != $userpasswd2 ];then 
     dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title " Clave incorrecta " --msgbox 'Las contraseñas no coinciden\n      Intente nuevamente...' 6 50
  else 
    clear
  fi
done
dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --title "| Clave Correcta |" --msgbox '\nContraseña Conrrecta!' 7 40
arch-chroot /mnt /bin/bash -c "echo $user:$userpasswd | chpasswd"
sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /mnt/etc/sudoers
arch-chroot /mnt /bin/bash -c "hwclock -w"

#activando servicios dhcpcd NetworkManager sshd
#Modificando pacman.conf
arch-chroot /mnt /bin/bash -c "sed -i "/Color/s/^#//g" /etc/pacman.conf"
arch-chroot /mnt /bin/bash -c "sed -i "/TotalDonwload/s/^#//g" /etc/pacman.conf"
arch-chroot /mnt /bin/bash -c "sed -i "/VerbosePkgLists/s/^#//g" /etc/pacman.conf"
arch-chroot /mnt /bin/bash -c "sed -i "37iILoveCandy" /etc/pacman.conf"

#Actualiza Servicios y Mirrors
arch-chroot /mnt /bin/bash -c "systemctl enable dhcpcd NetworkManager sshd"

sed -i '94d' /mnt/etc/pacman.conf
sed -i '95d' /mnt/etc/pacman.conf
sed -i "94i[multilib]" /mnt/etc/pacman.conf
sed -i "95iInclude = /etc/pacman.d/mirrorlist" /mnt/etc/pacman.conf
#printf "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" >>/mnt/etc/pacman.conf
clear
echo ""
arch-chroot /mnt /bin/bash -c "pacman-key --populate archlinux"
echo ""
echo "  Claves Actualizadas en el Sistema Base, Espere..."
echo ""
echo ""
#Copia Red
if [[ ! -z $wifinet ]];then
	cp /etc/netctl/$wifinet /mnt/etc/netctl/$wifinet
	arch-chroot /mnt /bin/bash -c "netctl enable $wifinet"
fi

arch-chroot /mnt /bin/bash -c "reflector -l 5 --sort rate --save /etc/pacman.d/mirrorlist"
for i in $(seq 1 100)
do
    sleep 0.07 
    echo $i
done | whiptail --title ' Actualizando MirrorLists ' --gauge "\nActualizando MirrorList en el Sistema Base..." 7 60 0

cat /mnt/etc/pacman.d/mirrorlist | dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --progressbox "Mirrors List del Sistema Base > Actualizadas..." 25 2000; sleep 3



uefi=$( parted $disk print | grep -ic gpt )

if [ $uefi == 1 ] && [ -d /sys/firmware/efi ]; then
dialog --backtitle "|  SISTEMA UEFI Y DISCO GPT  |" --msgbox "|      SU SISTEMA ES UEFI >> INSTALE GRUB UEFI...    |" 5 50

else
dialog --backtitle "|  SISTEMA BIOS LEGACY Y DISCO DOS/MBR  |" --msgbox ">>>  SU SISTEMA ES BIOS LEGACY  >> INSTALE GRUB LEGACY...    " 5 60
fi

grub_selec=0 
while [ "$grub_selec" = "0" ] ; do

  grub_var=`dialog --title "| Selector de Arranque |" --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" \
    --stdout --no-cancel --menu "             Instale GRUB en UEFI o BIOS LEGACY\n\nUEFI es el sistema Moderno\nBIOS Legacy es un sistema antiguo\n\n" 13 0 150 BIOS_LEGACY "Instala GRUB en sistemas de BIOS Legacy" UEFI_SYSTEM "Instala GRUB en sistemas de UEFI"`
  
  if [ $grub_var == BIOS_LEGACY ]; then

  arch-chroot /mnt /bin/bash -c "pacman -Sy grub os-prober --noconfirm" | dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --progressbox " GRUB BIOS LEGACY > Actualizando... " 30 2000; sleep 2
  echo -e '\033[44;1m'
  clear 
  echo ""
  echo "        /////////////////////////////////||"
  echo "        //                               ||"
  echo "        //    1 >> Instalando GRUB       ||"
  echo "        //                               ||"
  echo "        /////////////////////////////////||"
  echo ""
  echo ""
  arch-chroot /mnt /bin/bash -c "grub-install --target=i386-pc $disk"
  sed -i "6iGRUB_CMDLINE_LINUX_DEFAULT="loglevel=3"" /mnt/etc/default/grub
  sed -i '7d' /mnt/etc/default/grub
  echo "        /////////////////////////////////||"
  echo "        //                               ||"
  echo "        //     2 >> Generando GRUB       ||"
  echo "        //                               ||"
  echo "        /////////////////////////////////||"
  echo ""
  arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg" 
  echo ""
  echo "ls -l /mnt/boot" && ls -l /mnt/boot
  echo -e '\033[m'
  echo -e '\033[41;1m'
  echo "        /////////////////////////////////////////////////////////////||"
  echo "        //                                                           ||"
  echo "        /   Lea bien que no tenga ningún error marcado               ||"
  echo "        //  > Confirme tener las IMG de linux para el arranque       ||"
  echo "        //  > Confirme tener la carpeta de GRUB para el arranque     ||"
  echo "        //                                                           ||"
  echo "        /////////////////////////////////////////////////////////////||"
  echo -e '\033[m'
  echo ""
  read -p "Presiona ENTER para continuar..."
  echo ""
  grub_selec=1

  elif [ $grub_var == UEFI_SYSTEM ]; then
  arch-chroot /mnt /bin/bash -c "pacman -Sy grub efibootmgr os-prober --noconfirm" | dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --progressbox " GRUB UEFI > Actualizando... " 30 2000; sleep 2
  echo -e '\033[44;1m'
  clear 
  echo ""
  echo "        /////////////////////////////////||"
  echo "        //                               ||"
  echo "        //    1 >> Instalando GRUB       ||"
  echo "        //                               ||"
  echo "        /////////////////////////////////||"
  echo ""
  echo ""
  arch-chroot /mnt /bin/bash -c "grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch" 
  echo ""
  echo ""
  arch-chroot /mnt /bin/bash -c "grub-install --target=x86_64-efi --efi-directory=/boot --removable"
  echo ""
  echo ""
  sed -i "6iGRUB_CMDLINE_LINUX_DEFAULT="loglevel=3"" /mnt/etc/default/grub
  sed -i '7d' /mnt/etc/default/grub
  echo ""
  echo -e '         /////////////////////////////////|| '
  echo -e '         //                               || '
  echo -e '         //     2 >> Generando GRUB       || '
  echo -e '         //                               || '
  echo -e '         /////////////////////////////////|| '
  echo ""
  arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"

  echo ""
  echo "ls -l /mnt/boot" && ls -l /mnt/boot
  echo -e '\033[m'
  echo -e '\033[41;1m'
  echo "        ////////////////////////////////////////////////////////////////||"
  echo "        //                                                              ||"
  echo "        /   Lea bien que no tenga ningún error marcado                  ||"
  echo "        //  > Confirme tener las IMG de linux para el arranque          ||"
  echo "        //  > Confirme tener la carpeta de GRUB y EFI para el arranque  ||"
  echo "        //                                                              ||"
  echo "        ////////////////////////////////////////////////////////////////||"
  echo -e '\033[m'
  echo ""
  read -p "Presiona ENTER para continuar..."
  echo ""
  grub_selec=1

  fi
done

arch-chroot /mnt /bin/bash -c "pacman -Sy neofetch git wget lsb-release xdg-user-dirs --noconfirm && xdg-user-dirs-update"  | dialog --backtitle "Instalación de ArchLinux - https://t.me/ArchLinuxCristo" --progressbox "Actualizando Sistema..." 30 2000; sleep 2
dialog --backtitle "| Instalación de ArchLinux - https://t.me/ArchLinuxCristo |" --stdout --ok-label 'Reiniciar' --title "| Finalizar |" --msgbox "\n| La computadora se reiniciara para finalizar la instalación |" 7 66
clear
echo ""
echo ""
echo ""
echo "      /////////////////////////////////||"
echo "      //                               ||"
echo "      //   Bienvenido a Arch Linux     ||"
echo "      //                               ||"
echo "      /////////////////////////////////||"
echo ""
echo ""
export $(cat /mnt/etc/locale.conf)
echo ""
arch-chroot /mnt /bin/bash -c "pacman -Syu && neofetch"; sleep 5
umount -R /mnt
reboot
    



