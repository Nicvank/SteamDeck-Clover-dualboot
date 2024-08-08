#!/bin/bash
current_password=$(zenity --password --title "输入sudo密码")
echo -e "$current_password\n" | sudo -S ls &> /dev/null
if [ $? -ne 0 ]
then
    echo 您的sudo密码是错误的! | \
        zenity --text-info --title "Clover Toolbox" --width 400 --height 200
    exit
fi

while true
do
Choice=$(zenity --width 750 --height 450 --list --radiolist --multiple 	--title "Clover Toolbox"\
    --column "选择" \
    --column "选项" \
    --column="描述 - 请仔细阅读!"\
    FALSE Status "在提交错误报告时选择此项！"\
    FALSE Batocera "选择Batocera v39（及更高的版本）或v38（及更低的版本）的配置。"\
    FALSE Themes "选择静态主题或随机主题。"\
    FALSE Timeout "设置在等待1/5/10/15秒后，进入默认系统。"\
    FALSE Service "禁用或启用Clover EFI条目和Clover systemd服务。"\
    FALSE Boot "设置将要启动的默认系统。"\
    FALSE NewLogo "替换背景启动图标。"\
    False OldLogo "恢复背景启动图标为默认值。"\
    FALSE Resolution "设置屏幕分辨率，如果使用了DeckHD 1200p的屏幕。"\
    FALSE Custom "将Clover EFI替换为隐藏了选项按钮的自定义EFI。。"\
    FALSE Uninstall "选择该项以卸载Clover并恢复所有更改。"\
    TRUE EXIT "***** 退出 Clover Toolbox *****")

if [ $? -eq 1 ] || [ "$Choice" == "EXIT" ]
then
	echo 用户按了取消/退出。
	exit

elif [ "$Choice" == "Status" ]
then
	zenity --warning --title "Clover Toolbox" --text "$(fold -w 120 -s ~/1Clover-tools/status.txt)" --width 1000 --height 400

elif [ "$Choice" == "Batocera" ]
then
Batocera_Choice=$(zenity --width 550 --height 220 --list --radiolist --multiple --title "Clover Toolbox" --column "选择" \
	--column "选项" --column "描述 - 请仔细阅读!"\
	FALSE v39 "为Batocera v39及更高版本设置Clover配置。"\
	FALSE v38 "为Batocera v38及更低版本设置Clover配置。"\
	TRUE EXIT "***** 退出 Clover Toolbox *****")

	if [ $? -eq 1 ] || [ "$Batocera_Choice" == "EXIT" ]
	then
		echo 用户按了取消/退出。

	elif [ "$Batocera_Choice" == "v39" ]
	then
		# Update the config.plist for Batocera v39 and newer
		echo -e "$current_password\n" | sudo -S sed -i '/<string>os_batocera<\/string>/!b;n;n;c\\t\t\t\t\t<string>\\EFI\\batocera\\grubx64\.efi<\/string>' /esp/efi/clover/config.plist

		zenity --warning --title "Clover Toolbox" --text "Batocera v39及更高版本的Clover配置已经更新！" --width 450 --height 75

	elif [ "$Batocera_Choice" == "v38" ]
	then
		# Update the config.plist for Batocera v38 and older
		echo -e "$current_password\n" | sudo -S sed -i '/<string>os_batocera<\/string>/!b;n;n;c\\t\t\t\t\t<string>\\EFI\\BOOT\\BOOTX64\.efi<\/string>' /esp/efi/clover/config.plist

		zenity --warning --title "Clover Toolbox" --text "Batocera v38及更低版本的Clover配置已经更新！" --width 450 --height 75

	fi

elif [ "$Choice" == "Themes" ]
then
Theme_Choice=$(zenity --title "Clover Toolbox"	--width 200 --height 325 --list \
	--column "主题名称" $(echo -e "$current_password\n" | sudo -S ls /esp/efi/clover/themes) )

	if [ $? -eq 1 ]
	then
		echo 用户按了取消/退出。
	else
		echo -e "$current_password\n" | sudo -S sed -i '/<key>Theme<\/key>/!b;n;c\\t\t<string>'$Theme_Choice'<\/string>' /esp/efi/clover/config.plist
		zenity --warning --title "Clover Toolbox" --text "主题已更改为 $Theme_Choice!" --width 400 --height 75
	fi

elif [ "$Choice" == "Timeout" ]
then
Timeout_Choice=$(zenity --width 500 --height 300 --list --radiolist --multiple 	--title "Clover Toolbox" --column "选择" --column "选项" --column "描述 - 请仔细阅读!"\
	FALSE 1 "将默认超时设置为1秒。"\
	FALSE 5 "将默认超时设置为5秒。"\
	FALSE 10 "将默认超时设置为10秒。"\
	FALSE 15 "将默认超时设置为15秒。"\
 	FALSE 60 "将默认超时设置为60秒。"\
	TRUE EXIT "***** 退出 Clover Toolbox *****")

	if [ $? -eq 1 ] || [ "$Timeout_Choice" == "EXIT" ]
	then
		echo 用户按了取消/退出。
	else
		# change the Default Timeout in config.plist 
		echo -e "$current_password\n" | sudo -S sed -i '/<key>Timeout<\/key>/!b;n;c\\t\t<integer>'$Timeout_Choice'<\/integer>' /esp/efi/clover/config.plist
		zenity --warning --title "Clover Toolbox" --text "默认超时已设置为 $Timeout_Choice !" --width 400 --height 75
	fi

elif [ "$Choice" == "Service" ]
then
Service_Choice=$(zenity --width 650 --height 250 --list --radiolist --multiple --title "Clover Toolbox"\
	--column "选择" --column "选项" --column "描述 - 请仔细阅读!"\
	FALSE Disable "禁用Clover EFI条目和Clover systemd服务。"\
	FALSE Enable "启用Clover EFI条目和Clover systemd服务。"\
	TRUE EXIT "***** 退出 Clover Toolbox *****")

	if [ $? -eq 1 ] || [ "$Service_Choice" == "EXIT" ]
	then
		echo 用户按了取消/退出。

	elif [ "$Service_Choice" == "Disable" ]
	then
		# restore Windows EFI entry from backup
		echo -e "$current_password\n" | sudo -S cp /esp/efi/Microsoft/Boot/bootmgfw.efi.orig /esp/efi/Microsoft/Boot/bootmgfw.efi

		# make Windows the next boot option!
		Windows=$(efibootmgr | grep -i Windows | colrm 9 | colrm 1 4)
		echo -e "$current_password\n" | sudo -S efibootmgr -n $Windows &> /dev/null

		# disable the Clover systemd service
		echo -e "$current_password\n" | sudo -S systemctl disable --now clover-bootmanager
		zenity --warning --title "Clover Toolbox" --text "Clover systemd服务已禁用。Windows现已激活！" --width 500 --height 75

	elif [ "$Service_Choice" == "Enable" ]
	then
		# enable the Clover systemd service
		sudo systemctl enable --now clover-bootmanager
		echo -e "$current_password\n" | sudo -S /etc/systemd/system/clover-bootmanager.sh
		zenity --warning --title "Clover Toolbox" --text "Clover systemd服务已启用。Windows现在已禁用！" --width 500 --height 75
	fi

elif [ "$Choice" == "Boot" ]
then
Boot_Choice=$(zenity --width 550 --height 250 --list --radiolist --multiple --title "Clover Toolbox" --column "选择" \
	--column "选项" --column "描述 - 请仔细阅读!"\
	FALSE Windows "将Windows设置为默认启动操作系统。"\
	FALSE SteamOS "将Steam OS设置为默认启动操作系统。"\
	FALSE LastOS "最后启动的操作系统将是默认操作系统。"\
	TRUE EXIT "***** 退出 Clover Toolbox *****")

	if [ $? -eq 1 ] || [ "$Boot_Choice" == "EXIT" ]
	then
		echo 用户按了取消/退出。

	elif [ "$Boot_Choice" == "Windows" ]
	then
		# change the Default Loader to Windows in config,plist 

		echo -e "$current_password\n" | sudo -S sed -i '/<key>DefaultLoader<\/key>/!b;n;c\\t\t<string>\\EFI\\MICROSOFT\\bootmgfw\.efi<\/string>' /esp/efi/clover/config.plist
		echo -e "$current_password\n" | sudo -S sed -i '/<key>DefaultVolume<\/key>/!b;n;c\\t\t<string>esp<\/string>' /esp/efi/clover/config.plist

		zenity --warning --title "Clover Toolbox" --text "Windows 现在是Clover中的默认启动项！" --width 400 --height 75

	elif [ "$Boot_Choice" == "SteamOS" ]
	then
		# change the Default Loader in config,plist 
		echo -e "$current_password\n" | sudo -S sed -i '/<key>DefaultLoader<\/key>/!b;n;c\\t\t<string>\\EFI\\STEAMOS\\STEAMCL\.efi<\/string>' /esp/efi/clover/config.plist
		echo -e "$current_password\n" | sudo -S sed -i '/<key>DefaultVolume<\/key>/!b;n;c\\t\t<string>esp<\/string>' /esp/efi/clover/config.plist
		zenity --warning --title "Clover Toolbox" --text "SteamOS 现在是Clover中的默认启动项！" --width 400 --height 75

	elif [ "$Boot_Choice" == "LastOS" ]
	then
		# change the Default Volume in config,plist 
		echo -e "$current_password\n" | sudo -S sed -i '/<key>DefaultVolume<\/key>/!b;n;c\\t\t<string>LastBootedVolume<\/string>' /esp/efi/clover/config.plist
		zenity --warning --title "Clover Toolbox" --text "最后使用的操作系统现在是Clover中的默认启动项！" --width 425 --height 75
	fi

elif [ "$Choice" == "NewLogo" ]
then
Logo_Choice=$(zenity --title "Clover Toolbox"	--width 200 --height 350 --list \
	--column "Logo  名称" $(ls -l ~/1Clover-tools/logos/*.png | sed s/^.*\\/\//) )  
	if [ $? -eq 1 ]
	then
		echo 用户按了取消/退出。
	else
		echo -e "$current_password\n" | sudo -S cp ~/1Clover-tools/logos/$Logo_Choice /esp/efi/steamos/steamos.png
		zenity --warning --title "Clover Toolbox" --text "BGRT logo 已更改为 $Logo_Choice!" --width 400 --height 75
	fi

elif [ "$Choice" == "OldLogo" ]
then
	echo -e "$current_password\n" | sudo -S rm /esp/efi/steamos/steamos.png &> /dev/null
	zenity --warning --title "Clover Toolbox" --text "BGRT logo 已恢复为默认值！" --width 400 --height 75

elif [ "$Choice" == "Resolution" ]
then
Resolution_Choice=$(zenity --width 550 --height 250 --list --radiolist --multiple --title "Clover Toolbox"\
	--column "选择" --column "选项" --column "描述 - 请仔细阅读!"\
	FALSE 800p "使用默认屏幕分辨率 1280x800."\
	FALSE 1200p "使用DeckHD屏幕分辨率 1920x1200."\
	TRUE EXIT "***** 退出 Clover Toolbox *****")

	if [ $? -eq 1 ] || [ "$Resolution_Choice" == "EXIT" ]
	then
		echo 用户按了取消/退出。

	elif [ "$Resolution_Choice" == "800p" ]
	then
		# change the sceen resolution to 1280x800 in config,plist 
		echo -e "$current_password\n" | sudo -S sed -i '/<key>ScreenResolution<\/key>/!b;n;c\\t\t<string>1280x800<\/string>' /esp/efi/clover/config.plist
		zenity --warning --title "Clover Toolbox" --text "屏幕分辨率现在设置为 1280x800." --width 400 --height 75

	elif [ "$Resolution_Choice" == "1200p" ]
	then
		# change the sceen resolution to 1920x1200 in config,plist 
		echo -e "$current_password\n" | sudo -S sed -i '/<key>ScreenResolution<\/key>/!b;n;c\\t\t<string>1920x1200<\/string>' /esp/efi/clover/config.plist
		zenity --warning --title "Clover Toolbox" --text "屏幕分辨率现在设置为 1920x1200." --width 400 --height 75
	fi

elif [ "$Choice" == "Custom" ]
then
	echo -e "$current_password\n" | sudo -S cp ~/1Clover-tools/efi/custom_clover_5157.efi /esp/efi/clover/cloverx64.efi
	zenity --warning --title "Clover Toolbox" --text "自定义Clover EFI已安装！" --width 400 --height 75

elif [ "$Choice" == "Uninstall" ]
then
	# restore Windows EFI entry from backup
	echo -e "$current_password\n" | sudo -S mv /esp/efi/Microsoft/Boot/bootmgfw.efi.orig /esp/efi/Microsoft/Boot/bootmgfw.efi
	echo -e "$current_password\n" | sudo -S mv /esp/efi/boot/bootx64.efi.orig /esp/efi/boot/bootx64.efi
	echo -e "$current_password\n" | sudo -S rm /esp/efi/Microsoft/bootmgfw.efi

	# remove Clover from the EFI system partition
	echo -e "$current_password\n" | sudo -S rm -rf /esp/efi/clover

	for entry in $(efibootmgr | grep "Clover - GUI" | colrm 9 | colrm 1 4)
	do
		echo -e "$current_password\n" | sudo -S efibootmgr -b $entry -B &> /dev/null
	done

	# remove custom logo / BGRT
	echo -e "$current_password\n" | sudo -S rm /esp/efi/steamos/steamos.png &> /dev/null

	# delete systemd service
	echo -e "$current_password\n" | sudo -S steamos-readonly disable
	echo -e "$current_password\n" | sudo -S systemctl stop clover-bootmanager.service
	echo -e "$current_password\n" | sudo -S rm /etc/systemd/system/clover-bootmanager*
	echo -e "$current_password\n" | sudo -S sudo systemctl daemon-reload
	echo -e "$current_password\n" | sudo -S steamos-readonly enable

	# delete dolphin root extension
	rm ~/.local/share/kservices5/ServiceMenus/open_as_root.desktop

	rm -rf ~/SteamDeck-Clover-dualboot
	rm -rf ~/1Clover-tools/
	rm ~/Desktop/Clover-Toolbox
	
	zenity --warning --title "Clover Toolbox" --text "Clover已卸载，Windows EFI条目已激活！" --width 600 --height 75
	exit
fi
done
