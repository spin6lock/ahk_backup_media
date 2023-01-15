#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

count_img(path)
{
	count := 0
	Loop, Files, %path%\*.jpg, R
	{
		count += 1
	}
	Loop, Files, %path%\*.HIF, R
	{
		count += 1
	}
	Loop, Files, %path%\*.heic, R
	{
		count += 1
	}
	return count
}

count_video(path)
{
	count := 0
	Loop, Files, %path%\*.mp4, R
	{
		count += 1
	}
	return count
}


DriveGet, list, list
loop,Parse,list
{
	folder:=A_LoopField . ":\"
	DriveGet, type, type, %folder%
	if(Drive Type!= "Removable")
		continue
	DCIM_folder := folder "\DCIM"
	if not FileExist(DCIM_folder)
		continue
	img_count := count_img(DCIM_folder)
	video_count := count_video(DCIM_folder)
	video_folder := folder . "\M4ROOT\CLIP"
	video_count += count_video(video_folder)
	if (img_count == 0 and video_count == 0)
	{
		MsgBox, %folder% 没有媒体文件，准备退出
		return
	}
	FormatTime, CurrentDateTime,, yyyyMMdd ;20230107
	;倒计时5秒， 是/否对话框
	MsgBox, 4, , 发现相机卡: %folder%`n照片: %img_count%张`n视频: %video_count%个`n准备创建文件夹: %CurrentDateTime% 进行拷贝`n是否继续, 5
	IfMsgBox, No
		return
	dest_folder := A_Desktop "\" CurrentDateTime
	FileCreateDir, %dest_folder%
	move_files(DCIM_folder, dest_folder)
	move_files(video_folder, dest_folder)
	remove_files(DCIM_folder)
	MsgBox, 完成拷贝
}

move_files(source, dest)
{
	Loop, Files, %source%\*.mp4, R
		FileMove, %A_LoopFilePath%, %dest%
	
	Loop, Files, %source%\*.jpg, R
		FileMove, %A_LoopFilePath%, %dest%
	
	Loop, Files, %source%\*.xml, R
		FileMove, %A_LoopFilePath%, %dest%
	
	Loop, Files, %source%\*.heic, R
		FileMove, %A_LoopFilePath%, %dest%
	
	Loop, Files, %source%\*.HIF, R
		FileMove, %A_LoopFilePath%, %dest%\*.heic
}

remove_files(source)
{
	Loop, Files, %source%\*.LRF, R
		FileRecycle, %A_LoopFilePath%
}