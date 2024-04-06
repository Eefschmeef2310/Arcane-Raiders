extends Resource
class_name PlayerCardRes

enum Selection {None, Raider,Loadout,Ready}

@export_group("Data")
@export var display_username : bool
@export var username : String 
@export var raiderRes : RaiderRes
@export var loadoutRes : LoadoutRes

@export_group("Usage")
@export var raider_number : int # these two number variable are for tracking the little pips 
@export var loadout_num : int  
@export var selected : Selection #tracks which panel is currently selected (and should be highlighted)
@export var ready : bool # tracks if the player has "locked in" their selection
