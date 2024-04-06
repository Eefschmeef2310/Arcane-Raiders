extends Resource
class_name PlayerCardRes

enum Selection {Raider,Loadout,Ready}

@export_group("Data")
@export var portrait_path : String
@export var display_username : bool
@export var username : String 
@export var raider_name : String
@export var raider_desc : String
@export var loadout_name : String 
@export var loadout_desc : String 

@export_group("Usage")
@export var raider_number : int 
@export var loadout_num : int 
@export var selected : Selection
@export var ready : bool
