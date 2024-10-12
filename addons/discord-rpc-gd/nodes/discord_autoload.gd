## This is a GDscript Node wich gets automatically added as Autoload while installing the addon.
## 
## It can run in the background to comunicate with Discord.
## You don't need to use it. If you remove it make sure to run [code]DiscordRPC.run_callbacks()[/code] in a [code]_process[/code] function.
##
## @tutorial: https://github.com/vaporvee/discord-rpc-godot/wiki
extends Node

func _ready() -> void:
	DiscordRPC.app_id = 1294268451447242824 # Application ID
	DiscordRPC.details = "In the menus"
	#DiscordRPC.state = "Checkpoint 23/23" # floor number
	DiscordRPC.large_image = "game" # Image key from "Art Assets"
	DiscordRPC.large_image_text = "Download the demo on Steam!"
	DiscordRPC.small_image = "smol" # Image key from "Art Assets" # we could use the small image/text to display floor info?
	DiscordRPC.small_image_text = "Ver: " + ProjectSettings.get_setting("application/config/version", "0") + SteamManager.get_version_string()

	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system()) # "02:46 elapsed"
	# DiscordRPC.end_timestamp = int(Time.get_unix_time_from_system()) + 3600 # +1 hour in unix time / "01:00:00 remaining"

	DiscordRPC.refresh() # Always refresh after changing the values!

func  _process(_delta) -> void:
	DiscordRPC.run_callbacks()
