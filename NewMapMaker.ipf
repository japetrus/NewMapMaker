#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Menu "Mapping"
	"Make map", MakeMapPrompt()
	"Automate export", AutomateMapSaving()
End

Function AutomateMapSaving()

	// Setup settings wave
	Variable NumberOfMaps = ItemsInList(WaveList("*Map", ";", ""))
	Variable Counter

	Wave/T MapSettingsWave = $ioliteDFpath("images", "MapSettingsWave")	
	If (!WaveExists(MapSettingsWave))
		Print "You should setup the common settings first then run this..."
		Return -1
	EndIf
	
	// Get a path to save the maps to:
	NewPath/C/O AutomateMapPath

	If (V_flag != 0)
		PathInfo AutomateMapPath
		print V_flag, S_path	
		Return -1
	EndIf
	
	PathInfo AutomateMapPath	
	print V_flag, S_path
	
	// Prompt for:
	// map name
	// rows/cols of overviews
	String/G $ioliteDFpath("images", "AutomateName")
	SVar AutomateName = $ioliteDFpath("images", "AutomateName")
	String/G $ioliteDFpath("images", "AutomateOverviewDimensions")
	SVar AutomateOverviewDimensions
	
	String AutomateNameTemp, AutomateOverviewDimensionsTemp
	
	Variable NumberOfMapsInUse = 0
	
	For (Counter = 0; Counter < dimsize(MapSettingsWave,0); Counter += 1)
		String ThisMapName = GetDimLabel(MapSettingsWave, 0, Counter)
		String ThisMapSettings = MapSettingsWave[%$ThisMapName]

		If (GrepString(StringByKey("INCLUDEINOVERVIEW", ThisMapSettings), "(?i)yes"))
			NumberOfMapsInUse += 1
		EndIf
		
	EndFor		
	
	String DimStringOptions  = ""
	
	For (Counter = 2; Counter < 9; Counter += 1)
		DimStringOptions += num2str(Counter)+"x"+num2str(ceil(NumberOfMapsInUse/Counter))+";"
	EndFor
	
	Prompt AutomateNameTemp, "Name for map: "
	Prompt AutomateOverviewDimensionsTemp, "Layout for overview: ", popup, DimStringOptions
	DoPrompt "Setup", AutomateNameTemp, AutomateOverviewDimensionsTemp

	If (V_flag)
		Return -1
	EndIf
	
	AutomateName = AutomateNameTemp
	AutomateOverviewDimensions = AutomateOverviewDimensionsTemp

	SetDataFolder $ioliteDFpath("images", "")
	
	String ListOfMaps = WaveList("*Map", ";", "")
	

	// Set to linear Med +- 3SD
	For (Counter = 0; Counter < NumberOfMaps; Counter += 1)
		String CurrentMap = StringFromList(Counter, ListOfMaps)
		MapSettingsWave[%$CurrentMap] = ReplaceStringByKey("RANGEMODE", MapSettingsWave[%$CurrentMap],"Med±3se")
		MapSettingsWave[%$CurrentMap] = ReplaceStringByKey("SCALE", MapSettingsWave[%$CurrentMap],"Linear")
	EndFor		

	BT_Overview("")
	ModifyGraph height=900
	SavePict/WIN=MapOverview/P=AutomateMapPath/E=-2 as AutomateName+" Overivew - Linear - Med+-3SD.pdf"
	KillWindow MapOverview
	
	PathInfo AutomateMapPath
	String AutomateSaveAllPath = S_path + "Linear - Med +- 3SD"
	NewPath/C/O AutomateMapAllPath, AutomateSaveAllPath
	
	BT_SaveAll("")

	// Set to linear Minmax
	For (Counter = 0; Counter < NumberOfMaps; Counter += 1)
		CurrentMap = StringFromList(Counter, ListOfMaps)
		MapSettingsWave[%$CurrentMap] = ReplaceStringByKey("RANGEMODE", MapSettingsWave[%$CurrentMap],"MinMax")
		MapSettingsWave[%$CurrentMap] = ReplaceStringByKey("SCALE", MapSettingsWave[%$CurrentMap],"Linear")
	EndFor		

	BT_Overview("")
	ModifyGraph height=900
	SavePict/WIN=MapOverview/P=AutomateMapPath/E=-2 as AutomateName+" Overivew - Linear - MinMax.pdf"
	KillWindow MapOverview
	
	PathInfo AutomateMapPath
	AutomateSaveAllPath = S_path + "Linear - MinMax"
	NewPath/C/O AutomateMapAllPath, AutomateSaveAllPath
	
	BT_SaveAll("")	
	
	// Set to log Minmax
	For (Counter = 0; Counter < NumberOfMaps; Counter += 1)
		CurrentMap = StringFromList(Counter, ListOfMaps)
		MapSettingsWave[%$CurrentMap] = ReplaceStringByKey("RANGEMODE", MapSettingsWave[%$CurrentMap],"MinMax")
		MapSettingsWave[%$CurrentMap] = ReplaceStringByKey("SCALE", MapSettingsWave[%$CurrentMap],"Logarithmic")
	EndFor		

	BT_Overview("")
	ModifyGraph height=900
	SavePict/WIN=MapOverview/P=AutomateMapPath/E=-2 as AutomateName+" Overivew - Logarithmic - MinMax.pdf"
	KillWindow MapOverview
	
	PathInfo AutomateMapPath
	AutomateSaveAllPath = S_path + "Logarithmic - MinMax"
	NewPath/C/O AutomateMapAllPath, AutomateSaveAllPath
	
	BT_SaveAll("")	
	
	// Set to ECDF Minmax
	For (Counter = 0; Counter < NumberOfMaps; Counter += 1)
		CurrentMap = StringFromList(Counter, ListOfMaps)
		MapSettingsWave[%$CurrentMap] = ReplaceStringByKey("RANGEMODE", MapSettingsWave[%$CurrentMap],"MinMax")
		MapSettingsWave[%$CurrentMap] = ReplaceStringByKey("SCALE", MapSettingsWave[%$CurrentMap],"ECDF")
	EndFor		

	BT_Overview("")
	ModifyGraph height=900
	SavePict/WIN=MapOverview/P=AutomateMapPath/E=-2 as AutomateName+" Overivew - ECDF - MinMax.pdf"
	KillWindow MapOverview
	
	PathInfo AutomateMapPath
	AutomateSaveAllPath = S_path + "ECDF - MinMax"
	NewPath/C/O AutomateMapAllPath, AutomateSaveAllPath
	
	BT_SaveAll("")	
	
	
	
	// Export the single file time series table:
	SVar AutomateSelectionGroup = $ioliteDFpath("images", "AutomateSelectionGroup")
	If (!SVar_exists(AutomateSelectionGroup))
	
		String ListOfIntegTypes = GetListOfIntegrationsInUse("no m_")		//Returns list of selection groups, without the m_ at the start of each name
		string SelectedInteg = ""

		IF(WhichListItem("Output_1", ListOfIntegTypes) > -1)		//If output_1 is in the list, use that by default. Otherwise, use the first item in the list
			SelectedInteg = "Output_1"
		ELSE
			SelectedInteg = stringfromlist(0,ListOfIntegTypes)
		ENDIF
		prompt SelectedInteg, "Selection group to use", popup, ListOfIntegTypes
	
		doprompt "Choose a selection group to make an image", SelectedInteg
		if(V_Flag==1) //if the user hits cancel this will stop here
			return -1
		endif
		String SelectionGrpName = SelectedInteg
	
	
		String/G $ioliteDFpath("images", "AutomateSelectionGroup")
		SVar AutomateSelectionGroup = $ioliteDFpath("images", "AutomateSelectionGroup")
		AutomateSelectionGroup = SelectedInteg	
	
	EndIf
	
	String ASG = AutomateSelectionGroup
	
	// Export the individual lines?	
	String/G $ioliteDFpath("output", "SelectedUncertainties")
	SVar SelectedUncertainties = $ioliteDFpath("output","SelectedUncertainties")
	SelectedUncertainties = "Internal and LOD"
	
	Variable/G $ioliteDFpath("Output", "ExportToDisk")
	NVar ExportToDisk = $ioliteDFpath("Output", "ExportToDisk")
	ExportToDisk = 1
	
	PathInfo AutomateMapPath
	NewPath/C/O p_ExportFolder, S_path
	SegmentAndSaveOutput(1, "Lines", ASG, "by Annotation", ExportPathFlag = 1)
	
	// Cleanup
	Killpath AutomateMapPath
	Killpath AutomateMapAllPath
	//KillStrings $ioliteDFpath("images", "AutomateSelectionGroup") // Don't want to kill this because it is only created when the map is first setup
	KillStrings $ioliteDFpath("images", "AutomateName")
	KillStrings $ioliteDFpath("images", "AutomateOverviewDimensions")

End


Function MakeMapPrompt()

	NewDataFolder/O/S root:Packages:iolite:images

	svar ListOfOutputNames=$ioliteDFpath("output","ListOfOutputChannels") //get list of outputwaves
	String errormsg
	IF(!svar_exists(ListOfOutputNames) || !strlen(ListOfOutputNames)) //if cannot find list of outputs or there are no outputs
		sprintf errormsg, "No output waves could be found - please process some data first"
		printabort (errormsg)
	endif
	String /G ListOfImageWaves = ListOfOutputNames //copy it to a local string
	String ListOfWavesToNOTprocess="Beam_Seconds;" //waves not to process as images
	ListOfImageWaves = RemoveFromList("Beam_Seconds", ListOfImageWaves  , ";"  ,0) //remove unwanted waves

	// Prompt for Selection Group and Map name
			
	String ListOfIntegTypes = GetListOfIntegrationsInUse("no m_")		//Returns list of selection groups, without the m_ at the start of each name
	string SelectedInteg = ""
	string MapName = ""
	IF(WhichListItem("Output_1", ListOfIntegTypes) > -1)		//If output_1 is in the list, use that by default. Otherwise, use the first item in the list
		SelectedInteg = "Output_1"
	ELSE
		SelectedInteg = stringfromlist(0,ListOfIntegTypes)
	ENDIF
	prompt SelectedInteg, "Selection group to use", popup, ListOfIntegTypes
	prompt MapName, "Name for map"
	doprompt "Choose a selection group to make an image", SelectedInteg, MapName
	if(V_Flag==1) //if the user hits cancel this will stop here
		//because the function that called this function will keep running after the below return am putting in a special flag value to let it know that it's cancelled
		return -1
	endif
	String SelectionGrpName = SelectedInteg
	
	
	String/G $ioliteDFpath("images", "AutomateSelectionGroup")
	SVar AutomateSelectionGroup = $ioliteDFpath("images", "AutomateSelectionGroup")
	AutomateSelectionGroup = SelectedInteg
	
	If (cmpstr(MapName, "") == 0)
		MapName = SelectedInteg
	EndIf
	
	Wave SelectionGrpMatrix = $ioliteDFpath("integration", "m_"+SelectionGrpName)		//Declare selection group matrix
	Variable/G NoOfSelections = dimsize(SelectionGrpMatrix, 0) - 1					//Get the number of selections in this group (minus 1 for default row at top)
	
	Wave SelectionsPointInfoWave = $MakeIoliteWave("images", "SelectionsPointInfoWave", N = NoOfSelections)
	Redimension /N=(-1,3)  SelectionsPointInfoWave		//Add columns to wave
	SelectionsPointInfoWave = Nan						//Ensure it's got no values in it
	
	//Ok, now getting some info about the DRS used, and then the number of points used and where the selections start and end
	SVAR IndexWaveName = $ioliteDFpath("DRSGlobals","IndexChannel") 	//Get the current index channel
	Wave IndexWave = $ioliteDFpath("Input",IndexWaveName)			//Now declare the index channel
	If(!Waveexists(IndexWave) )											//Print error and abort if index time wave does not exist
		PrintAbort("Could not find \""+IndexWaveName+"\" in the CurrentDRS datafolder. Make sure that you have a DRS selected, and that output channels are available. Process aborted.")
	Endif 
	
	//Now go through and extract the start, end and number of points for each selection 
	Variable SelectionCounter
	
	//NOTE: start at 1 to avoid default row.
	//NOTE: all wave point indices below are -1 to allow for this, and so that the first row contains info on the first selection
	For(SelectionCounter = 1; SelectionCounter < NoOfSelections + 1; SelectionCounter += 1)		
		String ThisSelStartAndEndPoint = ReturnStartAndEndPoints(SelectionGrpName, SelectionCounter)		//This function returns a string with the start and end point separated by a semi-colon
		Variable StartPoint = str2num(StringFromList(0,ThisSelStartAndEndPoint))
		Variable EndPoint = str2num(StringFromList(1,ThisSelStartAndEndPoint))
		//Set start or end point to the first or last point in IndexWave if -1 or -2 is returned
		StartPoint = StartPoint == -1 ? 0 : StartPoint
		StartPoint = StartPoint == -2 ? dimsize(IndexWave, 0)-1 : StartPoint
		EndPoint = EndPoint == -1 ? 0 : EndPoint
		EndPoint = EndPoint == -2 ? dimsize(IndexWave, 0)-1 : EndPoint
		
		SelectionsPointInfoWave[SelectionCounter-1][1] = StartPoint	//Record start point
		SelectionsPointInfoWave[SelectionCounter-1][2] = EndPoint	//Record end point
		SelectionsPointInfoWave[SelectionCounter-1][0] = SelectionsPointInfoWave[SelectionCounter-1][2] - SelectionsPointInfoWave[SelectionCounter-1][1]	//Record num of points		
	EndFor

	MDsort(SelectionsPointInfoWave, 1)		//Sort by start point
	
	//Now just do a quick check for the maximum number of points, and the minimum
	MatrixOp /O NumPointsWave = col(SelectionsPointInfoWave,  0)		//copy the first column of SelectionsPointInfoWave to a new wave
	Variable/G MaxNoOfPoints = WaveMax(NumPointsWave)
	Variable/G MinNoOfPoints = WaveMin(NumPointsWave)
	
	IF(MinNoOfPoints < 5)		//If there is a selection with less than 5 points in it, let the user know, but keep going
		//Find out which selection has less than five points
		Extract /INDX /O NumPointsWave, LowPointsWave, NumPointsWave < 5		//Store the indices of where the number of points is less than 5
		Wave LowPointsWave
		
		//Convert the first 4 points to a string. Don't want to print all of them because it could be hundreds, and what does it matter beyond a few
		String ListOfLowPointSelections = ""
		For(SelectionCounter = 0; SelectionCounter < 5; SelectionCounter += 1)
			IF(dimsize(LowPointsWave, 0)-1 < SelectionCounter)		//If we've reached the end of the wave, don't continue
				Break
			ENDIF			
			ListOfLowPointSelections += num2str(LowPointsWave[SelectionCounter]) + ", "		//Add this selection number to the list of low point selections	
		EndFor
		
		String alertStr		//Now alert the user that some selections are low on points...
		sprintf alertStr , "iolite notices that the following selections had less than 5 data points:\r %s \rThis may or may not be an error, but iolite thought you should know...", ListOfLowPointSelections
		DoAlert 0, alertStr
	ENDIF	
		
	//By default, all maps are initially created with Left alignment:
	String Alignment = "Justified"		//case-insensitive by the way, but looks nice with capital
//	String Alignment = "Left"
	//Can now create the maps. This function just takes the list of channels, and the SelectionPointInfoWave (plus a few other pieces of info) to create the maps
	String/G CurrScale
	String/G CurrScaleMode 

	CurrScale="Linear"
	CurrScaleMode = "Normal"	


	CreateChannelMaps(SelectionsPointInfoWave, ListOfImageWaves, Alignment, MaxNoOfPoints, NoOfSelections)

	MakeMap2(MapName, ResetSettings=1)
	
	// Figure out map dimensions from laser log?
	Wave Speed = root:Packages:iolite:Laserlogs:'ScanSpeed_um/s'
	Variable SpeedVar = Speed[5]
	Print "Speed um/s = ", SpeedVar
	Wave SpotSize = $ioliteDFpath("LaserLogs", "SpotSize_um")
	Print "Spot size um = ", StatsMedian(SpotSize)
	Variable SpotSizeVar = StatsMedian(SpotSize)
	
	Print "Number of lines = ", NoOfSelections

	
	String PUncert		
	MakePopulationStatsWaves(SelectionGrpName, "TotalBeam", PUncert, "Full")
	
	Wave PS_Durations = $ioliteDFpath("IoliteGlobals", "PopulationStats_Durations")
	WaveStats/Q PS_Durations
	
	Print "Duration s = ", V_avg
	Print "Suggested width um = ", round(SpeedVar*V_avg)
	Print "Suggested height um = ", round(SpotSizeVar*NoOfSelections)

	
End

//------------------------------------------------------------------------
// Notch filters noise (+ data!) at the specified frequency + bandwidth... not really recommended for use.
//------------------------------------------------------------------------
Function SmoothMap()

	SVAR ListOfInputChannels = $ioliteDFpath("input", "GlobalListOfInputChannels")
	Variable NoOfChannels = ItemsInList(ListOfInputChannels)
	
	Variable i
	For (i = 0; i < NoOfChannels; i = i + 1)
		String curChannel = "root:Packages:iolite:input:" + StringFromList(i, ListOfInputChannels)
		
		// Apply smoothing:
		
		// Boxcar:
		Smooth/B/E=3 3,$curChannel
		
		//Smooth/M=0/MPCT=(percentile) 8, $curChannel
	EndFor
End

//------------------------------------------------------------------------
// Notch filters noise (+ data!) at the specified frequency + bandwidth... not really recommended for use.
//------------------------------------------------------------------------
Function FilterMap()

	SVAR ListOfInputChannels = $ioliteDFpath("input", "GlobalListOfInputChannels")
	Variable NoOfChannels = ItemsInList(ListOfInputChannels)
	
	Variable f0, sf
	
	Prompt f0, "Center frequency [Hz]: "
	Prompt sf, "Sample freq [Hz]: "
	DoPrompt "Enter filter parameters", f0, sf
	If (V_Flag)
		Return -1
	EndIf
	
	f0 = f0/sf
	
	Make/O/D/N=0 coefs
	
	Variable i
	For (i = 0; i < NoOfChannels; i = i + 1)
		String curChannel = "root:Packages:iolite:input:" + StringFromList(i, ListOfInputChannels)
		FilterFIR/DIM=0/LO={f0,f0,101}/NMF={f0, f0, 9e-13, 3}/COEF coefs, $curChannel
	//	Duplicate/O root:Packages:iolite:input:Fe56, filtered; DelayUpdate
//Make/O/D/N=0 coefs; DelayUpdate
//FilterFIR/DIM=0/LO={0.131429,0.131429,101}/NMF={0.131429,0.131429,9.09495e-13,2}/COEF coefs, filtered
		
		
	EndFor
End

Function MakeMap2(MapName, [ResetSettings])
	String  MapName
	Variable ResetSettings
	
	If ( ParamIsDefault(ResetSettings) )
		ResetSettings = 0
	EndIf
		
	SetDataFolder $ioliteDFpath("images", "")
	
	String/G $ioliteDFpath("images", "SelectedMap")
	SVAR SelectedMap = $ioliteDFpath("images", "SelectedMap")
	String ListOfMaps = WaveList("*Map", ";", "")
	
	String FirstMap = StringFromList(0, ListOfMaps)
	SelectedMap = FirstMap

	DoWindow/K $MapName
	Display/N=$MapName/K=1
	
	SetWindow $MapName, hook(MapHook) = MapHook	
	
	String/G $ioliteDFpath("images", "ControlList") = ""
	Variable/G $ioliteDFpath("images", "ApplyToAll") = 1
	
	// Setup settings wave
	Variable NumberOfMaps = ItemsInList(WaveList("*Map", ";", ""))
	Variable Counter

	Variable LogWidth=100
	Variable LogHeight=100




	Wave/T MapSettingsWave = $ioliteDFpath("images", "MapSettingsWave")	
	If (!WaveExists(MapSettingsWave) || ResetSettings)
		Make/O/T/N=(NumberOfMaps) $ioliteDFpath("images", "MapSettingsWave")
		Wave/T MapSettingsWave = $ioliteDFpath("images", "MapSettingsWave")	
		
		For ( Counter = 0; Counter < NumberOfMaps; Counter += 1)
			String ThisMap = StringFromList(Counter, WaveList("*Map", ";", ""))
			SetDimLabel 0, Counter, $ThisMap, MapSettingsWave
			MapSettingsWave[%$ThisMap] = "SCALE:Linear;"
			MapSettingsWave[%$ThisMap] += "INTERP:Bilinear;"
			MapSettingsWave[%$ThisMap] += "RANGEMODE:MinMax;"
			MapSettingsWave[%$ThisMap] += "MIN:0;"
			MapSettingsWave[%$ThisMap] += "MAX:1e6;"
			MapSettingsWave[%$ThisMap] += "WIDTH:"+num2str(LogWidth)+";"
			MapSettingsWave[%$ThisMap] += "HEIGHT:"+num2str(LogHeight)+";"		
			MapSettingsWave[%$ThisMap] += "MASK:None;"
			MapSettingsWave[%$ThisMap] += "COLORMAP:ColdWarm;"
			MapSettingsWave[%$ThisMap] += "MULTIPLIER:1;"
			MapSettingsWave[%$ThisMap] += "AXESMODE:Both;"
			MapSettingsWave[%$thisMap] += "INCLUDEINOVERVIEW:Yes;"
			MapSettingsWave[%$thisMap] += "INTERNAL:No;"
			MapSettingsWave[%$thisMap] += "INTERNALVAL:1e6;"
			MapSettingsWave[%$thisMap] += "FILTER:avg;"
			MapSettingsWave[%$thisMap] += "FILTERN:3;"
			MapSettingsWave[%$thisMap] += "FILTERP:1;"
		EndFor
		
		String/G $ioliteDFpath("images", "LogicSettings") = "MAP1:"+FirstMap +";LOGIC1:Greater than;VALUE1:0;ACTIVE1:0;MAP2:"+FirstMap+";LOGIC2:Greater than;VALUE2:0;ACTIVE2:0;MAP3:"+FirstMap+";LOGIC3:Greater than;VALUE3:0;ACTIVE3:0;"
		String/G $ioliteDFpath("images", "FuzzySettings") = "MAP1:"+FirstMap+";MAP2:"+FirstMap+";MAP3:"+FirstMap+";FUZZYNUM:0;"
	EndIf
	
	DisplayMap(MapName)
End

Function ToggleControls(MapName, [On])
	String MapName
	Variable On
	
	SVAR ControlList = $ioliteDFpath("images", "ControlList")
	
	If ( ParamIsDefault(On) )
		If (ItemsInList(ControlList) == 0)
			On = 1
		Else
			On = 0
		EndIf
	EndIf
	
	If (On)
	
		// Retrieve values from map settings wave:
		SVAR SelectedMap = $ioliteDFpath("images", "SelectedMap")
		Wave/T MapSettingsWave = $ioliteDFpath("images", "MapSettingsWave")
		
		String Scale = StringByKey("SCALE", MapSettingsWave[%$SelectedMap])
		String InterpMode = StringByKey("INTERP", MapSettingsWave[%$SelectedMap])
		String RangeMode = StringByKey("RANGEMODE", MapSettingsWave[%$SelectedMap])
		Variable Cmin = NumberByKey("MIN", MapSettingsWave[%$SelectedMap])
		Variable Cmax = NumberByKey("MAX", MapSettingsWave[%$SelectedMap])
		Variable Width = NumberByKey("WIDTH", MapSettingsWave[%$SelectedMap])
		Variable Height = NumberByKey("HEIGHT", MapSettingsWave[%$SelectedMap])
		String Mask = StringByKey("MASK", MapSettingsWave[%$SelectedMap])
		String ColorMap = StringByKey("COLORMAP", MapSettingsWave[%$SelectedMap])
		String AxesMode = StringByKey("AXESMODE", MapSettingsWave[%$SelectedMap])
		Variable Multiplier = NumberByKey("MULTIPLIER", MapSettingsWave[%$SelectedMap])
		String IncludeInOverview = StringByKey("INCLUDEINOVERVIEW", MapSettingsWave[%$SelectedMap])
		String Internal = StringByKey("INTERNAL", MapSettingsWave[%$SelectedMap])		
		Variable InternalValue = NumberByKey("INTERNALVAL", MapSettingsWave[%$SelectedMap])
		String FilterName = StringByKey("FILTER", MapSettingsWave[%$SelectedMap])
		Variable FilterN = NumberByKey("FILTERN", MapSettingsWave[%$SelectedMap])
		Variable FilterP = NumberByKey("FILTERP", MapSettingsWave[%$SelectedMap])
		
		SetDataFolder ioliteDFpath("images", "")

		PopupMenu MapSelectorPU value=WaveList("*Map", ";", ""), mode=WhichListItem(SelectedMap, WaveList("*Map", ";", ""))+1, proc=PU_MapSelector, userdata(MapName)=MapName, size={175,30}
		CheckBox ApplyToAllCB userdata(MapName)=MapName, title="Apply to all?", variable=$ioliteDFpath("images", "ApplyToAll"), pos={0,30}
		PopupMenu InterpSelectorPU value="None;Bilinear;Spline;Spline FDS;", mode=WhichListItem(InterpMode, "None;Bilinear;Spline;Spline FDS;")+1, proc=PU_MapProc, userdata(MapName)=MapName, size={100,30}, pos={0,60}
		PopupMenu ScaleSelectorPU value="Linear;Logarithmic;ECDF;", mode=WhichListItem(Scale, "Linear;Logarithmic;ECDF;")+1, proc=PU_MapProc, userdata(MapName)=MapName, size={100,30}, pos={0,90}
		PopupMenu RangeModePU value="MinMax;Values;Avg±1se;Avg±2se;Avg±3se;Avg±4se;Med±1se;Med±2se;Med±3se;Med±4se;", mode=WhichListItem(RangeMode, "MinMax;Values;Avg±1se;Avg±2se;Avg±3se;Avg±4se;Med±1se;Med±2se;Med±3se;Med±4se;")+1, proc=PU_MapProc, userdata(MapName)=MapName, size={100,30}, pos={0,120}
		SetVariable MinSV live=1, proc=SV_Range, userdata(MapName)=MapName, title="Min:", value=_NUM:Cmin, size={100,30}, pos={0,150}
		SetVariable MaxSV live=1, proc=SV_Range, userdata(MapName)=MapName, title="Max:", value=_NUM:Cmax, size={100,30}, pos={0,180}
		SetVariable WidthSV live=1, proc=SV_Dimensions, userdata(MapName)=MapName, title="Width:", value=_NUM:Width, size={100,30}, pos={0,210}
		SetVariable HeightSV live=1, proc=SV_Dimensions, userdata(MapName)=MapName, title="Height:", value=_NUM:Height, size={100,30}, pos={0,240}
		PopupMenu MaskSelectorPU value="None;Fuzzy;Logic;ROI;", mode=WhichListItem(Mask, "None;Fuzzy;Logic;ROI;")+1, proc=PU_MapProc, userdata(MapName)=MapName, size={100,30}, pos={0,270}
		PopupMenu ColorScalePU value="*COLORTABLEPOP*", pos={0,300}, proc=PU_MapProc, userdata(MapName)=MapName, mode=WhichListItem(ColorMap, CTabList())+1
		SetVariable MultSV live=1, proc=SV_Mult, userdata(MapName)=MapName, title="Multiplier:", value=_NUM:Multiplier, size={100,30}, pos={0,330}
		PopupMenu AxesPU value = "Both;Bottom;Left;None;", pos={0,360}, proc=PU_MapProc, userdata(MapName)=MapName, mode=WhichListItem(AxesMode, "Both;Bottom;Left;None;")+1
		PopupMenu InOverviewPU value="Yes;No;", pos={0,390}, proc=PU_MapProc, userdata(MapName)=MapName, mode=WhichListItem(IncludeInOverview, "Yes;No;")+1
		PopupMenu InternalPU value="No;"+WaveList("*Map", ";", ""), pos={0,420}, proc=PU_MapProc, userdata(MapName)=MapName, mode=WhichListItem(Internal, "No;"+WaveList("*Map", ";", ""))+1
		SetVariable InternalSV live=1, proc=SV_Internal, userdata(MapName)=MapName, title="Int Val:", value=_NUM:InternalValue, size={100,30}, pos={0,450}
		PopupMenu FilterPU value="None;avg;gauss;max;median;hybridmedian;min;sharpen;sharpenmore;thin;FindEdges;", mode=WhichListItem(FilterName, "None;avg;gauss;max;median;hybridmedian;min;sharpen;sharpenmore;thin;FindEdges;")+1, proc=PU_MapProc, userdata(MapName)=MapName, size={100,30}, pos={0,480}
		SetVariable FilterNSV live=1, proc=SV_Filter, userdata(MapName)=MapName, title="N", value=_NUM:FilterN, size={60,30}, pos={80, 480}
		SetVariable FilterPSV live=1, proc=SV_Filter, userdata(MapName)=MapName, title="P", value=_NUM:FilterP, size={60,30}, pos={160, 480}
		
		StrSwitch (Mask)
			Case "ROI":
				Button AddROIBT title="Add ROI", size={100,25}, proc=BT_AddROI, userdata(MapName)=MapName, pos={200,0}
				Button AddToMaskBT title="Add to Mask", size={100,25}, proc=BT_AddROIToMask, userdata(MapName)=MapName, pos={300,0}
				Button ClearMaskBT title="Clear Mask", size={100,25}, proc=BT_ClearROIMask, userdata(MapName)=MapName, pos={400,0}
				Break
			Case "Logic":
				SVAR LogicSettings = $ioliteDFpath("images", "LogicSettings")
				PopupMenu Logic1MapPU value=WaveList("*Map", ";", ""), mode=WhichListItem(StringByKey("MAP1", LogicSettings), WaveList("*Map", ";", ""))+1, proc=PU_ProcLogic, userdata(MapName)=MapName, pos={200,0}
				PopupMenu Logic1LogicPU value="Less than;Greater than;", mode=WhichListItem(StringByKey("LOGIC1", LogicSettings), "Less than;Greater than;")+1, proc=PU_ProcLogic, userdata(MapName)=MapName, pos={200, 30}
				SetVariable Logic1SV proc=SV_ProcLogic, userdata(MapName)=MapName, title = " ", value=_NUM:NumberByKey("VALUE1", LogicSettings), pos={200, 60}
				CheckBox Logic1CB userdata(MapName)=MapName, title=" ", proc=CB_ProcLogic, value=NumberByKey("ACTIVE1", LogicSettings)
				
				PopupMenu Logic2MapPU value=WaveList("*Map", ";", ""), mode=WhichListItem(StringByKey("MAP2", LogicSettings), WaveList("*Map", ";", ""))+1, proc=PU_ProcLogic, userdata(MapName)=MapName, pos={350,0}
				PopupMenu Logic2LogicPU value="Less than;Greater than;", mode=WhichListItem(StringByKey("LOGIC2", LogicSettings), "Less than;Greater than;")+1, proc=PU_ProcLogic, userdata(MapName)=MapName, pos={350, 30}
				SetVariable Logic2SV proc=SV_ProcLogic, userdata(MapName)=MapName, title = " ", value=_NUM:NumberByKey("VALUE2", LogicSettings), pos={350, 60}
				CheckBox Logic2CB userdata(MapName)=MapName, title=" ", proc=CB_ProcLogic, value=NumberByKey("ACTIVE2", LogicSettings)
				
				PopupMenu Logic3MapPU value=WaveList("*Map", ";", ""), mode=WhichListItem(StringByKey("MAP3", LogicSettings), WaveList("*Map", ";", ""))+1, proc=PU_ProcLogic, userdata(MapName)=MapName, pos={500,0}
				PopupMenu Logic3LogicPU value="Less than;Greater than;", mode=WhichListItem(StringByKey("LOGIC3", LogicSettings), "Less than;Greater than;")+1, proc=PU_ProcLogic, userdata(MapName)=MapName, pos={500, 30}
				SetVariable Logic3SV proc=SV_ProcLogic, userdata(MapName)=MapName, title = " ", value=_NUM:NumberByKey("VALUE3", LogicSettings), pos={500, 60}
				CheckBox Logic3CB userdata(MapName)=MapName, title=" ", proc=CB_ProcLogic, value=NumberByKey("ACTIVE3", LogicSettings)
				Break
			Case "Fuzzy":
				SVAR FuzzySettings = $ioliteDFpath("images", "FuzzySettings")
				PopupMenu FuzzyMap1PU value=WaveList("*Map", ";", ""), mode=WhichListItem(StringByKey("MAP1", FuzzySettings), WaveList("*Map", ";", ""))+1, proc=PU_ProcFuzzy, userdata(MapName)=MapName, pos={200,0}
				PopupMenu FuzzyMap2PU value=WaveList("*Map", ";", ""), mode=WhichListItem(StringByKey("MAP2", FuzzySettings), WaveList("*Map", ";", ""))+1, proc=PU_ProcFuzzy, userdata(MapName)=MapName, pos={350,0}
				PopupMenu FuzzyMap3PU value=WaveList("*Map", ";", ""), mode=WhichListItem(StringByKey("MAP3", FuzzySettings), WaveList("*Map", ";", ""))+1, proc=PU_ProcFuzzy, userdata(MapName)=MapName, pos={500,0}	
				
				Variable FuzzyNum = NumberByKey("FUZZYNUM", FuzzySettings)
				SetVariable FuzzyNumSV proc=SV_ProcLogic, userdata(MapName)=MapName, title=" ", value=_NUM:FuzzyNum, pos={100,270}
				Button FuzzyMaskBT title="Segment!", size={100,25}, proc=BT_Fuzzy, userdata(MapName)=MapName, pos={650,0}
				Break
		EndSwitch
		
		GetWindow $MapName gsize
		Print V_bottom, V_right	
		
		Button SaveImageBT title="Save", size={100,25}, proc=BT_Save, userdata(MapName)=MapName, pos={V_right-200,V_bottom-25}
		Button SaveAllBT title="Save all", size={100,25}, proc=BT_SaveAll, userdata(MapName)=MapName, pos={V_right-100,V_bottom-25}
		
		Button DefinteProfileBT title="Define Profile", size={100,25}, proc=BT_AddROI, userdata(MapName)=MapName, pos={V_left,V_bottom-25}
		Button ShowProfileBT title="Show Profile", size={100,25}, proc=BT_Profile, userdata(MapName)=MapName, pos={V_left+100,V_bottom-25}
		Button ShowSpotsBT title="Show Spots", size={100,25}, proc=BT_Spots, userdata(MapName)=MapName, pos={V_left+200, V_bottom-25}
		
		Button OverviewBT title="Overview", size={100,25}, proc=BT_Overview, userdata(MapName)=MapName, pos={(V_left+V_right)/2, V_bottom-25}
		
		ControlList = "MapSelectorPU;ApplyToAllCB;InterpSelectorPU;ScaleSelectorPU;RangeModePU;MinSV;MaxSV;WidthSV;HeightSV;MaskSelectorPU;ColorScalePU;MultSV;AxesPU;InOverviewPU;"
		ControlList += "AddROIBT;AddToMaskBT;ClearMaskBT;"
		ControlList += "Logic1MapPU;Logic1LogicPU;Logic1SV;Logic1CB;" 
		ControlList += "Logic2MapPU;Logic2LogicPU;Logic2SV;Logic2CB;" 
		ControlList += "Logic3MapPU;Logic3LogicPU;Logic3SV;Logic3CB;" 
		ControlList += "FuzzyMap1PU;FuzzyMap2PU;FuzzyMap3PU;FuzzyMaskBT;FuzzyNumSV;"
		ControlList += "SaveImageBT;SaveAllBT;DefinteProfileBT;ShowProfileBT;ShowSpotsBT;OverviewBT;"
		ControlList += "InternalPU;InternalSV;"
		ControlList += "FilterPU;FilterNSV;FilterPSV;"
	Else
		// Remove all controls:
		Variable Counter
		For ( Counter = 0; Counter < ItemsInList(ControlList); Counter += 1)
			String ThisControlName = StringFromList(Counter, ControlList)
			KillControl $ThisControlName
		EndFor
		ControlList = ""
	EndIf
End

Function PU_ProcFuzzy(PU_Struct) : PopupMenuControl
	STRUCT WMPopupAction &PU_Struct
	
	If (PU_Struct.eventCode != 2)            //Only handle mouse up events
		Return 0
	EndIf	
	
	String MapName = GetUserData("", PU_Struct.ctrlName, "MapName")
	SVAR FuzzySettings = $ioliteDFpath("images", "FuzzySettings")
	String KeyString = ""
	String ValueString = PU_Struct.popStr
	
	StrSwitch (PU_Struct.ctrlName)
		Case "FuzzyMap1PU":
			KeyString = "MAP1"
			Break
		Case "FuzzyMap2PU":
			KeyString = "MAP2"
			Break
		Case "FuzzyMap3PU":
			KeyString = "MAP3"
			Break					
	EndSwitch
			
	FuzzySettings = ReplaceStringByKey(KeyString, FuzzySettings, ValueString)
End

Function UpdateFuzzyMask(MapName)
	String MapName
	
	SVAR FuzzySettings = $ioliteDFpath("images", "FuzzySettings")

	String Map1Name = StringByKey("MAP1", FuzzySettings)
	String Map2Name = StringByKey("MAP2", FuzzySettings)
	String Map3Name = StringByKey("MAP3", FuzzySettings)

	Wave Map1 = $ioliteDFpath("images", Map1Name)
	Wave Map2 = $ioliteDFpath("images", Map2Name)
	Wave Map3 = $ioliteDFpath("images", Map3Name)	
	
	//ImageInterpolate/D=2/F={1, dimsize(OriginalMap,0)/dimsize(OriginalMap,1)}/DEST=$(InterpMapName) Spline OriginalMap
	ImageInterpolate/D=2/F={1, dimsize(Map1,0)/dimsize(Map1,1)}/DEST=FuzzyMap1 Spline Map1
	ImageInterpolate/D=2/F={1, dimsize(Map2,0)/dimsize(Map2,1)}/DEST=FuzzyMap2 Spline Map2
	ImageInterpolate/D=2/F={1, dimsize(Map3,0)/dimsize(Map3,1)}/DEST=FuzzyMap3 Spline Map3
	
	Variable nx = dimsize(FuzzyMap1,0)
	Variable ny = dimsize(FuzzyMap1,1)
		
	Make/O/N=(nx, ny, 3) Fuzzy3DMatrix
	Fuzzy3DMatrix = Nan
	Fuzzy3DMatrix[][][0] = FuzzyMap1[p][q]
	Fuzzy3DMatrix[][][1] = FuzzyMap2[p][q]
	Fuzzy3DMatrix[][][2] = FuzzyMap3[p][q]
	
	ImageTransform/CLAM=2/CLAS=3/SEG fuzzyClassify Fuzzy3DMatrix
	Wave Segments = $("M_FuzzySegments")
	
	Redimension/B/U Segments
	
	ImageMorphology/I=2/E=3 Erosion Segments
	Wave Morph = $("M_ImageMorph")
	
	Variable Counter
	For (Counter = 0; Counter < 5; Counter += 1)
		ImageMorphology/O/E=(Counter+1) Erosion Morph
		ImageMorphology/O/E=(Counter+1) Dilation Morph
	EndFor

	Wave FuzzyMask = $IoliteDFpath("images", "FuzzyMask")
	//If (!WaveExists(FuzzyMask))
		Duplicate/O FuzzyMap1 FuzzyMask
		FuzzyMask =1
	//EndIf
	
	ImageStats Morph
	Variable MinMorph = V_min
	Variable MaxMorph = V_max
	Variable MidMorph = StatsMedian(Morph)

	Variable FuzzyNum = NumberByKey("FUZZYNUM", FuzzySettings)

	String SegmentOptions = num2str(MinMorph)+";"+num2str(MidMorph)+";"+num2str(MaxMorph)+";"
	Variable MorphValue = str2num(StringFromList(FuzzyNum, SegmentOptions))

	Redimension/D Morph
	FuzzyMask = SelectNumber(Morph[p][q] != MorphValue, 1, Nan)
	DisplayMap(MapName)

End

Function PU_ProcLogic(PU_Struct) : PopupMenuControl
	STRUCT WMPopupAction &PU_Struct
	
	If (PU_Struct.eventCode != 2)            //Only handle mouse up events
		Return 0
	EndIf	
	
	String MapName = GetUserData("", PU_Struct.ctrlName, "MapName")
	SVAR LogicSettings = $ioliteDFpath("images", "LogicSettings")
	String KeyString = ""
	String ValueString = PU_Struct.popStr
	
	StrSwitch (PU_Struct.ctrlName)
		Case "Logic1MapPU":
			KeyString = "MAP1"
			Break
		Case "Logic1LogicPU":
			KeyString = "LOGIC1"
			Break
		Case "Logic2MapPU":
			KeyString = "MAP2"
			Break
		Case "Logic2LogicPU":
			KeyString = "LOGIC2"
			Break
		Case "Logic3MapPU":
			KeyString = "MAP3"
			Break
		Case "Logic3LogicPU":
			KeyString = "LOGIC3"
			Break						
	EndSwitch
			
	LogicSettings = ReplaceStringByKey(KeyString, LogicSettings, ValueString)
	
	UpdateLogicMask(MapName)
End

Function CB_ProcLogic(CB_Struct) : CheckBoxControl
	STRUCT WMCheckBoxAction &CB_Struct
	
	If (CB_Struct.eventCode != 2)
		Return 0
	EndIf
	
	String MapName = GetUserData("", CB_Struct.ctrlName, "MapName")
	SVAR LogicSettings = $ioliteDFpath("images", "LogicSettings")	
	
	String KeyString = ""
	
	StrSwitch (CB_Struct.ctrlName)
		Case "Logic1CB":
			KeyString = "ACTIVE1"
			Break
		Case "Logic2CB":
			KeyString = "ACTIVE2"
			Break
		Case "Logic3CB":
			KeyString = "ACTIVE3"
			Break
	EndSwitch
	
	LogicSettings = ReplaceStringByKey(KeyString, LogicSettings, num2str(CB_Struct.checked))
	
	UpdateLogicMask(MapName)
End

Function SV_ProcLogic(SV_Struct) : SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct

	If (SV_Struct.eventCode != 2)            //Only handle enter (2) or live update (3?)
		Return 0
	EndIf	

	String MapName = GetUserData("", SV_Struct.ctrlName, "MapName")	
	SVAR LogicSettings = $ioliteDFpath("images", "LogicSettings")	
	SVAR FuzzySettings = $ioliteDFpath("images", "FuzzySettings")
	String KeyString = ""
	
	StrSwitch (SV_Struct.ctrlName)
		Case "Logic1SV":
			LogicSettings = ReplaceStringByKey("VALUE1", LogicSettings, num2str(SV_Struct.dval))			
			UpdateLogicMask(MapName)
			Break
		Case "Logic2SV":
			LogicSettings = ReplaceStringByKey("VALUE2", LogicSettings, num2str(SV_Struct.dval))
			UpdateLogicMask(MapName)
			Break
		Case "Logic3SV":
			LogicSettings = ReplaceStringByKey("VALUE3", LogicSettings, num2str(SV_Struct.dval))
			UpdateLogicMask(MapName)
			Break
		Case "FuzzyNumSV":
			FuzzySettings = ReplaceNumberByKey("FUZZYNUM", FuzzySettings, SV_Struct.dval)
			Wave Morph = $("M_ImageMorph")
			Wave FuzzyMask = $IoliteDFpath("images", "FuzzyMask")
			
			ImageStats Morph
			Variable MinMorph = V_min
			Variable MaxMorph = V_max
			Variable MidMorph = StatsMedian(Morph)

			Variable FuzzyNum = NumberByKey("FUZZYNUM", FuzzySettings)

			String SegmentOptions = num2str(MinMorph)+";"+num2str(MidMorph)+";"+num2str(MaxMorph)+";"
			Print SegmentOptions
			Variable MorphValue = str2num(StringFromList(FuzzyNum, SegmentOptions))

			Redimension/D Morph
			FuzzyMask = SelectNumber(Morph[p][q] != MorphValue, 1, Nan)
			DisplayMap(MapName)			
			Break
	EndSwitch
End

Function SV_Filter(SV_Struct) : SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct
	
	If (SV_Struct.eventCode != 2)            //Only handle enter (2) or live update (3?)
		Return 0
	EndIf	
	
	String MapName = GetUserData("", SV_Struct.ctrlName, "MapName")
	print MapName, SV_Struct.ctrlname, SV_Struct.dval
		
	Wave/T MapSettingsWave = $ioliteDFpath("images", "MapSettingsWave")
	SVAR SelectedMap = $ioliteDFpath("images", "SelectedMap")
	
	String AllMaps = WaveList("*Map", ";", "")
	NVAR ApplyToAll = $ioliteDFpath("images", "ApplyToAll")
	
	String MapsToApplyTo = SelectedMap
	If (ApplyToAll || 1) // || 1 to override. Probably only makes sense to apply this to all!
		MapsToApplyTo = AllMaps
	EndIf
	
	Variable NumMaps = ItemsInList(MapsToApplyTo)	
	String np = ""
	
	StrSwitch(SV_Struct.ctrlName)
		Case "FilterNSV":
			np = "FILTERN"
			Break
		Case "FilterPSV":
			np = "FILTERP"
			Break
	EndSwitch
	
	Variable Counter
	For (Counter = 0; Counter < NumMaps; Counter += 1)
		String CurrentMap = StringFromList(Counter, MapsToApplyTo)
		MapSettingsWave[%$CurrentMap] = ReplaceStringByKey(np, MapSettingsWave[%$CurrentMap], SV_Struct.sval)
	EndFor	
	
	DisplayMap(MapName)	
End

Function UpdateLogicMask(MapName)
	String MapName
	
	print "Updating logic mask..."
	SVAR LogicSettings = $ioliteDFpath("images", "LogicSettings")
	
	print LogicSettings
	
	Variable Counter
	
	SVAR SelectedMap = $ioliteDFpath("images", "SelectedMap")
	Wave InterpMap = $ioliteDFpath("images", SelectedMap+"_Interp")
	
	Duplicate/O InterpMap LogicMask
	Wave LogicMask = $ioliteDFpath("images", "LogicMask")
	LogicMask = 1

	For ( Counter = 1; Counter <= 3; Counter += 1)
		String Map = StringByKey("MAP"+num2str(Counter), LogicSettings)
		String Logic = StringByKey("LOGIC"+num2str(Counter), LogicSettings)
		Variable Active = str2num(StringByKey("ACTIVE"+num2str(Counter), LogicSettings))
		Variable Value = str2num(StringByKey("VALUE"+num2str(Counter), LogicSettings))
		
		If (Active)
			Wave MapWave = $ioliteDFpath("images", Map)	
			ImageInterpolate/F={1, dimsize(MapWave,0)/dimsize(MapWave,1)}/DEST=$("Map"+num2str(Counter)+"Interp") Bilinear MapWave		
			Wave MapWaveInterp = $ioliteDFpath("images", "Map"+num2str(Counter)+"Interp")
			StrSwitch (Logic)
				Case "Greater than":
					LogicMask = LogicMask*SelectNumber(MapWaveInterp[p][q] > Value, Nan, 1)
					Break
				Case "Less than":
					LogicMask = LogicMask*SelectNumber(MapWaveInterp[p][q] < Value, Nan, 1)
					Break
			EndSwitch
		EndIf
	EndFor
	
	DisplayMap(MapName)
End

Function BT_ClearROIMask(ctrlName) : ButtonControl
	String ctrlName

	Wave ROIMask = $ioliteDFpath("images", "ROIMask")	
	If (WaveExists(ROIMask))
		ROIMask = 1	
	EndIf

	String MapName = GetUserData("", ctrlName, "MapName")		
	DisplayMap(MapName)
	
End

Function BT_AddROIToMask(ctrlName) : ButtonControl
	String ctrlName
	
	String MapName = GetUserData("", ctrlName, "MapName")	
	SVAR SelectedMap = $ioliteDFpath("images", "SelectedMap")
	Wave InterpMap = $ioliteDFpath("images", SelectedMap + "_Interp")
	Variable nx = dimsize(InterpMap, 0)
	Variable ny = dimsize(InterpMap, 1)
	
	Duplicate/O InterpMap $ioliteDFpath("images", "ROIMask")
	Wave ROIMask = $ioliteDFpath("images", "ROIMask")	
	ROIMask = Nan
	
	Wave MapPolyY = $ioliteDFpath("images", "MapPolyY")
	Wave MapPolyX = $ioliteDFpath("images", "MapPolyX")
	
	Make/O/N=(1) xfinder, yfinder
	Wave xwave = $ioliteDFpath("images", "xwave")
	Wave ywave = $ioliteDFpath("images", "ywave")
	
	Wave/T MapSettingsWave = $ioliteDFpath("images", "MapSettingsWave")
	Variable width = str2num(StringByKey("WIDTH", MapSettingsWave[%$SelectedMap]))
	Variable height = str2num(StringByKey("HEIGHT", MapSettingsWave[%$SelectedMap]))
	
	// these are in coordinates not row/col
	Variable seedX = 1//MapPolyX[0]
	Variable seedY = 1//MapPolyY[0]	

	print nx, ny, width, height
	print MapPolyX
	print MapPolyY
	Duplicate/O MapPolyY MapPolyY_px
	Duplicate/O MapPolyX MapPolyX_px
	MapPolyY_px = MapPolyY*ny/height///ny
	MapPolyX_px = MapPolyX*nx/width///nx

	
	ImageBoundaryToMask ywave=MapPolyY_px, xwave=MapPolyX_px, width=nx, height=ny, seedX=(seedX), seedY=(seedY)
	Wave M_ROIMask = $"M_ROIMask"
	ROIMask = SelectNumber(M_ROIMask[p][q] > 0, 1, Nan)
	RemoveFromGraph/Z MapPolyY
	DisplayMap(MapName)
End

Function BT_Save(ctrlName) : ButtonControl
	String ctrlName
	
	String MapName = GetUserData("", ctrlName, "MapName")
	
	SavePict 
End

Function BT_SaveAll(ctrlName) : ButtonControl
	String ctrlName
	
	String MapName = GetUserData("", ctrlName, "MapName")
	String ListOfMaps = WaveList("*Map", ";", "")
	
	SVar AutomateName = $ioliteDFpath("images", "AutomateName")
	If (SVar_exists(AutomateName))
		MapName = AutomateName
	EndIf
	
	// Get a path to save the maps to:

	PathInfo AutomateMapAllPath
	If (V_flag == 0) // If 
		NewPath/C/O MapAllPath
	Else
		NewPath/C/O MapAllPath, S_path
	EndIf
	print V_flag, S_path

	Wave/T MapSettingsWave = $ioliteDFpath("images", "MapSettingsWave")
	
	Variable Counter
	For ( Counter = 0; Counter < ItemsInList(ListOfMaps); Counter += 1)
		String CurrentDataSource = StringFromList(Counter, ListOfMaps)
		String CurrentElement = StringFromList(0, CurrentDataSource, "_") +"_"+ StringFromList(3,CurrentDataSource, "_")
		
		String CurrentMapName = CurrentElement
		// Discordance
		If (GrepString(CurrentDataSource, "(?i)disc"))
			CurrentMapName = "Discordance"
		// Approx concentration from UPb DRS
		ElseIf (GrepString(CurrentDataSource, "(?i)Approx"))
			String ElStr = StringFromList(1, CurrentDataSource, "_")
			CurrentMapName = ElStr
		ElseIf (GrepString(CurrentDataSource, "(?i)U_Th_Ratio"))
			CurrentMapName = "U_Th"
		ElseIf (GrepString(CurrentDataSource, "(?i)Dose"))
			CurrentMapName = "Dose"
		// Age
		ElseIf (GrepString(CurrentDataSource, "(?i)FinalAge"))
			String NumerMass = CurrentDataSource[8, 10]
			String DenomMass = CurrentDataSource[12,14]
			String NumerEl = "Pb"
			String DenomEl = ""
			If (GrepString(DenomMass, "232"))
				DenomEl = "Th"
			ElseIf (GrepString(DenomMass, "206"))
				DenomEl = "Pb"
			Else
				DenomEl = "U"
			EndIf
		
			CurrentMapName = NumerMass+NumerEl+"_" + DenomMass+ DenomEl + "_Age"
		// Ratio
		ElseIf (GrepString(CurrentDataSource, "(?i)Final2"))
			NumerMass = CurrentDataSource[5,7]
			DenomMass = CurrentDataSource[9,11]
			NumerEl = "Pb"
			DenomEl = ""
		
			If (GrepString(DenomMass, "232"))
				DenomEl = "Th"
			ElseIf (GrepString(DenomMass, "206"))
				DenomEl = "Pb"
			Else
				DenomEl = "U"
			EndIf
		
			If (GrepString(NumerMass, "238"))
				NumerEl = "U"
			EndIf
		
			CurrentMapName = NumerMass+NumerEl+"_" + DenomMass+ DenomEl
			
		EndIf


		String SaveMap = StringByKey("INCLUDEINOVERVIEW", MapSettingsWave[%$CurrentDataSource])	
		If (GrepString(SaveMap, "(?i)Yes"))
		
			DisplayMap(MapName, DataSource=CurrentDataSource)
			Print "Saving ", CurrentDataSource, MapName
			SavePict/WIN=$MapName/P=MapAllPath/E=-2 as MapName+" "+CurrentMapName+".pdf"
			DoWindow ECDFColours
			If (V_flag)
				SavePict/WIN=ECDFColours/P=MapAllPath/E=-2 as MapName+" "+CurrentMapName+" ECDFColours.pdf"
			EndIf
		EndIf
	EndFor
End

Function BT_Profile(ctrlName) : ButtonControl
	String ctrlName
	
	String MapName = GetUserData("", ctrlName, "MapName")
	SVAR SelectedMap = $ioliteDFpath("images", "SelectedMap")
	Wave InterpMap = $ioliteDFpath("images", SelectedMap+"_Interp")
	Wave MapPolyX = $ioliteDFpath("images", "MapPolyX")
	Wave MapPolyY = $ioliteDFpath("images", "MapPolyY")
	
	ImageLineProfile/SC srcWave=InterpMap, xWave=MapPolyX, yWave=MapPolyY, width=5
	
	Wave ProfileWave = $"W_ImageLineProfile"
	Wave ProfileX = $"W_LineProfileX"
	Wave ProfileY = $"W_LineProfileY"
	
	Make/N=(dimsize(ProfileWave,0))/O ProfileD
	ProfileD = sqrt( (ProfileX[p]-ProfileX[0])^2 + (ProfileY[p]-ProfileY[0])^2)
	
	Display/N=ProfileGraph ProfileWave vs ProfileD
	
End

Function BT_Spots(ctrlName) : ButtonControl
	String ctrlName
	
	String MapName = GetUserData("", ctrlName, "MapName")
	SVAR SelectedMap = $ioliteDFpath("images", "SelectedMap")
	Wave InterpMap = $ioliteDFpath("images", SelectedMap+"_Interp")
	Wave MapPolyX = $ioliteDFpath("images", "MapPolyX")
	Wave MapPolyY = $ioliteDFpath("images", "MapPolyY")
	
	GraphNormal
	
	ImageLineProfile/SC/S srcWave=InterpMap, xWave=MapPolyX, yWave=MapPolyY, width=10
	
	Wave ProfileWave = $"W_ImageLineProfile"
	Wave ProfileX = $"W_LineProfileX"
	Wave ProfileY = $"W_LineProfileY"
	Wave ProfileStdv = $"W_LineProfileStdv"
	
	Make/N=(dimsize(ProfileWave,0))/O ProfileD
	ProfileD = sqrt( (ProfileX[p]-ProfileX[0])^2 + (ProfileY[p]-ProfileY[0])^2)
	
	Display/N=ProfileGraph ProfileWave vs ProfileD
	ErrorBars W_ImageLineProfile Y,wave=(ProfileStdv,ProfileStdv)	
	ModifyGraph mode=3
	ModifyGraph mirror=2,standoff=0;DelayUpdate
	Label left "Concentration";DelayUpdate
	Label bottom "Distance"
	ModifyGraph msize=8
End

Function BT_AddROI(ctrlName) : ButtonControl
	String ctrlName
	
	String MapName = GetUserData("", ctrlName, "MapName")
	GraphWaveDraw/W=$MapName/O MapPolyY, MapPolyX
End

Function BT_Fuzzy(ctrlName) : ButtonControl
	String ctrlName
	
	String MapName = GetUserData("", ctrlName, "MapName")
	UpdateFuzzyMask(MapName)
End

Function FuzzyClassifyMap()

	Wave Map1 = $ioliteDFpath("images", "Fe_ppm_SQ_m57_Map")
	Wave Map2 = $ioliteDFpath("images", "S_ppm_SQ_m33_Map")
	Wave Map3 = $ioliteDFpath("images", "Ni_ppm_SQ_m60_Map")	
	
	ImageInterpolate/F={1, dimsize(Map1,0)/dimsize(Map1,1)}/DEST=Map1Int Bilinear Map1
	ImageInterpolate/F={1, dimsize(Map2,0)/dimsize(Map2,1)}/DEST=Map2Int Bilinear Map2
	ImageInterpolate/F={1, dimsize(Map3,0)/dimsize(Map3,1)}/DEST=Map3Int Bilinear Map3
	
	Variable nx = dimsize(Map1Int,0)
	Variable ny = dimsize(Map1Int,1)
	print dimsize(Map1,0), dimsize(Map2,0)
	print dimsize(Map1,1), dimsize(Map2,1)
		
	Make/O/N=(nx, ny, 3) Fuzzy3DMatrix
	Fuzzy3DMatrix = Nan
	Fuzzy3DMatrix[][][0] = Map1Int[p][q]
	Fuzzy3DMatrix[][][1] = Map2Int[p][q]
	Fuzzy3DMatrix[][][2] = Map3Int[p][q]
	
	ImageTransform/CLAM=2/CLAS=3/SEG fuzzyClassify Fuzzy3DMatrix
	Wave Segments = $("M_FuzzySegments")
	
	Redimension/B/U Segments
	
	ImageMorphology /E=6 Closing Segments
	Wave Morph = $("M_ImageMorph")
	
	ImageMorphology/O /E=1 Erosion Morph
	ImageMorphology/O /E=1 Erosion Morph
//	ImageMorphology/O /E=1 Erosion Morph
	
	NewImage Segments
	NewImage Morph
End

Function SV_Range(SV_Struct) : SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct
	
	If (SV_Struct.eventCode != 2 && SV_Struct.eventCode != 3)            //Only handle enter (2) or live update (3?)
		Return 0
	EndIf	
	
	String MapName = GetUserData("", SV_Struct.ctrlName, "MapName")
	print MapName, SV_Struct.ctrlname, SV_Struct.dval
	
	Wave/T MapSettingsWave = $ioliteDFpath("images", "MapSettingsWave")
	SVAR SelectedMap = $ioliteDFpath("images", "SelectedMap")
	
	StrSwitch(SV_Struct.ctrlName)
		Case "MinSV":
			MapSettingsWave[%$SelectedMap] = ReplaceStringByKey("MIN", MapSettingsWave[%$SelectedMap], SV_Struct.sval)
			Break
		Case "MaxSV":
			MapSettingsWave[%$SelectedMap] = ReplaceStringByKey("MAX", MapSettingsWave[%$SelectedMap], SV_Struct.sval)
			Break
	EndSwitch
	
	DisplayMap(MapName)	
End

Function SV_Mult(SV_Struct) : SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct
	
	If (SV_Struct.eventCode != 2 && SV_Struct.eventCode != 3)            //Only handle enter (2) or live update (3?)
		Return 0
	EndIf	
	
	String MapName = GetUserData("", SV_Struct.ctrlName, "MapName")
	Wave/T MapSettingsWave = $ioliteDFpath("images", "MapSettingsWave")
	SVAR SelectedMap = $ioliteDFpath("images", "SelectedMap")
	String AllMaps = WaveList("*Map", ";", "")
	NVAR ApplyToAll = $ioliteDFpath("images", "ApplyToAll")
	
	String MapsToApplyTo = SelectedMap
	If (ApplyToAll)
		MapsToApplyTo = AllMaps
	EndIf
	
	Variable NumMaps = ItemsInList(MapsToApplyTo)

	Variable Counter
	For (Counter = 0; Counter < NumMaps; Counter += 1)
		String CurrentMap = StringFromList(Counter, MapsToApplyTo)
		MapSettingsWave[%$CurrentMap] = ReplaceStringByKey("MULTIPLIER", MapSettingsWave[%$CurrentMap], SV_Struct.sval)
	EndFor	
	
	DisplayMap(MapName)	
End

Function SV_Internal(SV_Struct) : SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct
	
	If (SV_Struct.eventCode != 2 && SV_Struct.eventCode != 3)            //Only handle enter (2) or live update (3?)
		Return 0
	EndIf	
	
	String MapName = GetUserData("", SV_Struct.ctrlName, "MapName")
	Wave/T MapSettingsWave = $ioliteDFpath("images", "MapSettingsWave")
	SVAR SelectedMap = $ioliteDFpath("images", "SelectedMap")
	String AllMaps = WaveList("*Map", ";", "")
	NVAR ApplyToAll = $ioliteDFpath("images", "ApplyToAll")
	
	String MapsToApplyTo = SelectedMap
	If (ApplyToAll)
		MapsToApplyTo = AllMaps
	EndIf
	
	Variable NumMaps = ItemsInList(MapsToApplyTo)

	Variable Counter
	For (Counter = 0; Counter < NumMaps; Counter += 1)
		String CurrentMap = StringFromList(Counter, MapsToApplyTo)
		MapSettingsWave[%$CurrentMap] = ReplaceStringByKey("INTERNALVAL", MapSettingsWave[%$CurrentMap], SV_Struct.sval)
	EndFor	
	
	DisplayMap(MapName)	
End

Function SV_Dimensions(SV_Struct) : SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct
	
	If (SV_Struct.eventCode != 2)            //Only handle enter (2) or live update (3?)
		Return 0
	EndIf	
	
	String MapName = GetUserData("", SV_Struct.ctrlName, "MapName")
	print MapName, SV_Struct.ctrlname, SV_Struct.dval
		
	Wave/T MapSettingsWave = $ioliteDFpath("images", "MapSettingsWave")
	SVAR SelectedMap = $ioliteDFpath("images", "SelectedMap")
	
	String AllMaps = WaveList("*Map", ";", "")
	NVAR ApplyToAll = $ioliteDFpath("images", "ApplyToAll")
	
	String MapsToApplyTo = SelectedMap
	If (ApplyToAll || 1) // || 1 to override. Probably only makes sense to apply this to all!
		MapsToApplyTo = AllMaps
	EndIf
	
	Variable NumMaps = ItemsInList(MapsToApplyTo)	
	String wh = ""
	
	StrSwitch(SV_Struct.ctrlName)
		Case "WidthSV":
			wh = "WIDTH"
			Break
		Case "HeightSV":
			wh = "HEIGHT"
			Break
	EndSwitch
	
	Variable Counter
	For (Counter = 0; Counter < NumMaps; Counter += 1)
		String CurrentMap = StringFromList(Counter, MapsToApplyTo)
		MapSettingsWave[%$CurrentMap] = ReplaceStringByKey(wh, MapSettingsWave[%$CurrentMap], SV_Struct.sval)
	EndFor	
	
	DisplayMap(MapName)	
End

//Function PU_MaskSelector(PU_Struct) : PopupMenuControl
//	STRUCT WMPopupAction &PU_Struct
//	
//	If (PU_Struct.eventCode != 2)            //Only handle mouse up events
//		Return 0
//	EndIf
//
//	StrSwitch(PU_Struct.popStr)
//		Case "None":
//		
//			Break
//		Case "Fuzzy":
//		
//			Break
//		Case "Logic":
//		
//			Break
//		Case "ROI":
//		
//			Break
//	EndSwitch
//
//End
//
//Function PU_ScaleSelector(PU_Struct) : PopupMenuControl
//	STRUCT WMPopupAction &PU_Struct
//	
//	If (PU_Struct.eventCode != 2)            //Only handle mouse up events
//		Return 0
//	EndIf
//	
//	// Get map project name that we're operating on
//	String MapName = GetUserData("", PU_Struct.ctrlname, "MapName")
//
//	// Get reference to the map settings wave
//	Wave/T MapSettingsWave = $ioliteDFpath("images", "MapSettingsWave")
//
//	// Get name of currently selected map	
//	SVAR SelectedMap = $ioliteDFpath("images", "SelectedMap")
//
//	// Get list of all available maps
//	String AllMaps = WaveList("*Map", ";", "")
//
//	// Determine whether or not we're applying settings to all maps
//	NVAR ApplyToAll = $ioliteDFpath("images", "ApplyToAll")
//
//	// Determine which maps to operate on
//	String MapsToApplyTo = SelectedMap
//	If (ApplyToAll)
//		MapsToApplyTo = AllMaps
//	EndIf
//	
//	// Determine number of maps we're operating on
//	Variable NumMaps = ItemsInList(MapsToApplyTo)
//	
//	// Update the map settings wave
//	Variable Counter
//	For (Counter = 0; Counter < NumMaps; Counter += 1)
//		String CurrentMap = StringFromList(Counter, MapsToApplyTo)
//		MapSettingsWave[%$CurrentMap] = ReplaceStringByKey("SCALE", 	MapSettingsWave[%$CurrentMap], PU_Struct.popStr)
//	EndFor
//	
//	// Update the display
//	DisplayMap(MapName)
//End

Function PU_MapProc(PU_Struct) : PopupMenuControl
	STRUCT WMPopupAction &PU_Struct
	
	If (PU_Struct.eventCode != 2)            //Only handle mouse up events
		Return 0
	EndIf
	
	// Get map project name that we're operating on
	String MapName = GetUserData("", PU_Struct.ctrlname, "MapName")

	// Get reference to the map settings wave
	Wave/T MapSettingsWave = $ioliteDFpath("images", "MapSettingsWave")

	// Get name of currently selected map	
	SVAR SelectedMap = $ioliteDFpath("images", "SelectedMap")

	// Get list of all available maps
	String AllMaps = WaveList("*Map", ";", "")

	// Determine whether or not we're applying settings to all maps
	NVAR ApplyToAll = $ioliteDFpath("images", "ApplyToAll")

	// Determine which maps to operate on
	String MapsToApplyTo = SelectedMap
	If (ApplyToAll)
		MapsToApplyTo = AllMaps
	EndIf
	
	// Determine number of maps we're operating on
	Variable NumMaps = ItemsInList(MapsToApplyTo)
	
	// Determine which settings we're updating
	String SettingName = ""
	
	StrSwitch (PU_Struct.ctrlName)
		Case "InterpSelectorPU":
			SettingName = "INTERP"
			Break
		Case "ScaleSelectorPU":
			SettingName = "SCALE"
			Break
		Case "RangeModePU":
			SettingName = "RANGEMODE"
			Break
		Case "MaskSelectorPU":
			SettingName = "MASK"
			Break
		Case "ColorScalePU":
			SettingName = "COLORMAP"
			Break
		Case "AxesPU":
			SettingName = "AXESMODE"
			Break
		Case "InOverviewPU":
			SettingName = "INCLUDEINOVERVIEW"
			Break
		Case "InternalPU":
			SettingName = "INTERNAL"
			Break
		Case "FilterPU":
			SettingName = "FILTER"
			Break
		Default:
			Print "Unrecognized control: ", PU_Struct.ctrlName, ": Abort!"
			Return 0
			Break
	EndSwitch
	
	// Update the map settings wave
	Variable Counter
	For (Counter = 0; Counter < NumMaps; Counter += 1)
		String CurrentMap = StringFromList(Counter, MapsToApplyTo)
		MapSettingsWave[%$CurrentMap] = ReplaceStringByKey(SettingName, MapSettingsWave[%$CurrentMap], PU_Struct.popStr)
	EndFor
	
	ToggleControls(MapName, On=0)
	ToggleControls(MapName, On=1)	
	
	// Update the display
	DisplayMap(MapName)
End


// Function called with map selector is used.
Function PU_MapSelector(PU_Struct) : PopupMenuControl
	STRUCT WMPopupAction &PU_Struct
	
	If (PU_Struct.eventCode != 2)            //Only handle mouse up events
		Return 0
	EndIf
	
	String MapName = GetUserData("", PU_Struct.ctrlName, "MapName")
	String MapWaveName = PU_Struct.popStr
	
	Print "Attempting to set", MapName," to ", MapWaveName, " for data..."
	
	SVAR SelectedMap = $ioliteDFpath("images", "SelectedMap")
	SelectedMap = MapWaveName
	
	ToggleControls(MapName, On=0)
	ToggleControls(MapName, On=1)
	
	DisplayMap(MapName)
End


// Hook function for main map window
// Used to check for keyboard shortcuts
Function MapHook(Win_Struct)
	STRUCT WMWinHookStruct &Win_Struct
	
	Switch (Win_Struct.eventCode)
		Case 11:
			If (Win_Struct.keycode == 115) // s without ctrl
				Print "s + ", Win_Struct.eventMod
				Return 1
			ElseIf (Win_Struct.keycode == 99) // "c"
				Print "Toggling overlay..."
				ToggleControls(Win_Struct.winName)
				Return 1			
			ElseIf (Win_Struct.keycode == 115 && Win_Struct.eventMod == 2) // ctrl+s
				Print "Alt+s"
				Return 1			
			EndIf
			Break
		Case 5: // Mouse up
			If (Win_Struct.eventMod != 2) // Shift modifier
				Break
			EndIf
			Variable XCoord = AxisValFromPixel(Win_Struct.winName, "bottom", Win_Struct.mouseLoc.h)
			Variable YCoord = AxisValFromPixel(Win_Struct.winName, "left", Win_Struct.mouseLoc.v)
			
			SVAR SelectedMap = $ioliteDFpath("images", "SelectedMap")
			Wave InterpMap = $ioliteDFpath("images", SelectedMap+"_Interp")
			Wave/T MapSettingsWave = $ioliteDFpath("images", "MapSettingsWave")
			
			Variable width = str2num(StringByKey("WIDTH", MapSettingsWave[%$SelectedMap]))
			Variable height = str2num(StringByKey("HEIGHT", MapSettingsWave[%$SelectedMap]))
			Variable nx = dimsize(InterpMap,0)
			Variable ny = dimsize(InterpMap, 1)
			
			Duplicate/O InterpMap InspectorMask
			InspectorMask = nan
		
			//print XCoord*nx/width, YCoord*ny/height
			Variable xmin = (XCoord-5)*nx/width
			Variable xmax = (XCoord+5)*nx/width
			Variable ymin = (YCoord-5)*ny/height
			Variable ymax = (YCoord+5)*ny/height
			
			DrawAction /W=$Win_Struct.winname getgroup=SpotForAverage
			If (V_Flag==1)
				DrawAction /W=$Win_Struct.winname delete, getgroup=SpotForAverage
			EndIf
			
			SetDrawEnv /W=$Win_Struct.winname gname=SpotForAverage,gstart
			SetDrawEnv fillbgc=(60000, 60000, 60000), fillpat=0, linethick=2.0
			SetDrawEnv xcoord= bottom,ycoord= left;DelayUpdate
			DrawRect/W=$Win_Struct.winname XCoord-5, YCoord-5, XCoord+5, YCoord+5
			SetDrawEnv gstop

			ImageStats/GS={XCoord-5, XCoord+5, YCoord-5, YCoord+5} InterpMap
			print SelectedMap, " average = ", V_avg, ", sd = ", V_sdev, ", n = ", V_npnts
						
			Break
	EndSwitch
	
	Return 0
End


// Main map display function. This does most of the heavy lifting!
Function DisplayMap(MapName, [DataSource])
	String MapName, DataSource
	
	SVAR SelectedMap = $ioliteDFpath("images", "SelectedMap")	
	
	If (ParamIsDefault(DataSource))
		DataSource = SelectedMap
	EndIf
	
	
	Wave OriginalMap = $ioliteDFpath("images", DataSource)
	String InterpMapName = DataSource + "_Interp"
	
	Wave/T MapSettingsWave = $ioliteDFpath("images", "MapSettingsWave")

	String Internal = StringByKey("INTERNAL", MapSettingsWave[%$DataSource])
	Variable InternalVal = NumberByKey("INTERNALVAL", MapSettingsWave[%$DataSource])

	Variable UseInternal = 0
	
	If (cmpstr(Internal, "No") != 0)
		UseInternal = 1
		Wave InternalMapOrig = $ioliteDFpath("images", Internal)
	EndIf

	Duplicate/O OriginalMap $InterpMapName


	// STEP1: Interpolate image:
	// ------------------
	
	String InterpMode = StringByKey("INTERP", MapSettingsWave[%$DataSource])
	
	StrSwitch(InterpMode)
		Case "None":
			Duplicate/O OriginalMap $InterpMapName
			If (UseInternal)
				Duplicate/O InternalMapOrig InterpInternal
			EndIf
			Break
		Case "Bilinear":
			ImageInterpolate/F={1, dimsize(OriginalMap,0)/dimsize(OriginalMap,1)}/DEST=$(InterpMapName) Bilinear OriginalMap
			If (UseInternal)
				ImageInterpolate/F={1, dimsize(OriginalMap,0)/dimsize(OriginalMap,1)}/DEST=InterpInternal Bilinear InternalMapOrig
			EndIf
			Break
		Case "Spline":
			ImageInterpolate/D=2/F={1, dimsize(OriginalMap,0)/dimsize(OriginalMap,1)}/DEST=$(InterpMapName) Spline OriginalMap
			If (UseInternal)
				ImageInterpolate/D=2/F={1, dimsize(OriginalMap,0)/dimsize(OriginalMap,1)}/DEST=InterpInternal Spline InternalMapOrig
			EndIf			
			Break
		Case "Spline FDS":
			ImageInterpolate/FDS/D=2/F={1, dimsize(OriginalMap,0)/dimsize(OriginalMap,1)}/DEST=$(InterpMapName) Spline OriginalMap
			Break
		Case "Resample/Up":
			Duplicate/O OriginalMap $InterpMapName
			Variable UpScale = floor(dimsize(OriginalMap,0)/dimsize(OriginalMap,1))
			Resample/UP=(UpScale)/DIM=1 $InterpMapName			
		Default:
			Print "Unrecognized interpolation mode:", InterpMode
			Break
	EndSwitch

	Wave InterpMap = $ioliteDFpath("images", InterpMapName)
	
	// Hack to fix part of a map that had to be reanalyzed:
	Variable mm, ci
//	For (mm = 102; mm < 146; mm+=1)
//		For (ci = 0; ci < dimsize(InterpMap,0); ci += 1)
//		
//			InterpMap[ci][mm] = InterpMap[ci][mm]*1.2
//		EndFor
//	EndFor
//	
//	For (mm = 0; mm < 102; mm+=1)
//		For (ci = 0; ci < dimsize(InterpMap,0); ci += 1)
//			InterpMap[ci][mm] = InterpMap[ci][mm]*0.85
//		EndFor
//	
//	EndFor

//	For (mm = 0; mm < 242; mm+=1)
//		For (ci = 0; ci < dimsize(InterpMap,0); ci += 1)
//			InterpMap[ci][mm] = InterpMap[ci][mm]*1.2
//		EndFor
//	
//	EndFor
		
	// STEP X: Apply post-interp filter:
	// --------------
	String FilterName = StringByKey("FILTER", MapSettingsWave[%$DataSource])
	Variable FilterN = NumberByKey("FILTERN", MapSettingsWave[%$DataSource])
	Variable FilterP = NumberByKey("FILTERP", MapSettingsWave[%$DataSource])
	
	If (cmpstr(FilterName, "None") != 0)
		ImageFilter/N=(FilterN)/P=(FilterP) $FilterName InterpMap
	EndIf		
		
	// STEP X: Mask image:
	// --------------
	
	String Mask = StringByKey("MASK", MapSettingsWave[%$DataSource])
	
	StrSwitch (Mask)
		Case "None":
			Break
		Case "Fuzzy":
			Wave FuzzyMask = $ioliteDFpath("images", "FuzzyMask")
			If (WaveExists(FuzzyMask))
				InterpMap = InterpMap*FuzzyMask
				If (UseInternal)
					InterpInternal = InterpInternal*FuzzyMask
				EndIf
			EndIf
			Break
		Case "ROI":
			Wave ROIMask = $ioliteDFpath("images", "ROIMask")
			If (WaveExists(ROIMask))
				InterpMap = InterpMap*ROIMask
				If (UseInternal)
					InterpInternal = InterpInternal*ROIMask				
				EndIf
			EndIf
			Break
		Case "Logic":
			Wave LogicMask = $ioliteDFpath("images", "LogicMask")
			If (WaveExists(LogicMask))
				InterpMap = InterpMap*LogicMask
				If (UseInternal)
					InterpInternal = InterpInternal*LogicMask
				EndIf
			EndIf
			Break
		Default:
			Print "Unrecognized mask mode:", Mask
			Break
	EndSwitch
	
	// STEP X: Apply multiplier
	Variable Multiplier = NumberByKey("MULTIPLIER", MapSettingsWave[%$DataSource])
//	Print "Multiplier = ", Multiplier
	InterpMap = Multiplier*InterpMap
	
	// STEP Y: Apply internal
	If (UseInternal)
		InterpInternal = InternalVal / InterpInternal
		InterpMap = InterpInternal * InterpMap
	EndIf
	

	
	// STEP2: Setup dimensions
	// ------------------
	
	Wave xwave = $makeiolitewave("images", "xwave", n=dimsize(InterpMap,0))
	Wave ywave = $makeiolitewave("images", "ywave", n=dimsize(InterpMap,1))
	xwave = 0
	ywave = 0
	
	Variable xlength = str2num(StringBykey("WIDTH", MapSettingsWave[%$DataSource]))
	Variable ylength = str2num(StringBykey("HEIGHT", MapSettingsWave[%$DataSource]))
			
	Variable k,j
	For (j = 1; j < numpnts(xwave); j = j + 1)
		xwave[j] = xwave[j-1] + xlength/numpnts(xwave)
	EndFor

	For (j = 1; j < numpnts(ywave); j = j + 1)
		ywave[j] = ywave[j-1] + ylength/numpnts(ywave)
	EndFor
		
	SetScale/P x, 0, xlength/numpnts(xwave), "microns", InterpMap
	SetScale/P y, 0, ylength/numpnts(ywave), "microns", InterpMap
	
	
	// STEP3: Append map to window
	// ---------------------
	
	// Remove previous map if one exists:
	String ImageList = ImageNameList(MapName, ";")
	Variable i
	For (i = 0; i < ItemsInList(ImageList); i += 1)
		RemoveImage/W=$MapName/Z $(StringFromList(i, ImageList))
	EndFor
	
	// Append new map:
	AppendImage/W=$MapName InterpMap		

	SetAxis/W=$MapName left 0, ylength
	SetAxis/W=$MapName bottom 0, xlength

	
	// STEP4: Set range:
	// ------------
	
	String RangeMode = StringByKey("RANGEMODE", MapSettingsWave[%$DataSource])
	
	Variable Min_dval = str2num(StringByKey("MIN", MapSettingsWave[%$DataSource]))
	Variable Max_dval = str2num(StringByKey("MAX", MapSettingsWave[%$DataSource]))
	
	//"MinMax;Values;Avg±1se;Avg±2se;Avg±3se;Avg±4se;Med±1se;Med±2se;Med±3se;Med±4se;"
	
	WaveStats/Q InterpMap
	Variable ImageAvg = V_avg
	Variable ImageAdev = V_adev
	Variable ImageSdev = V_sdev
	Variable ImageSem = V_sem
	
	Duplicate/O InterpMap InterpMapNoNans
	Redimension/N=(dimsize(InterpMap,0)*dimsize(InterpMap,1)) InterpMapNoNans
	Sort InterpMapNoNans, InterpMapNoNans
	WaveStats/Q InterpMapNoNans
	Redimension/N=(dimsize(InterpMapNoNans,0)-V_numNans) InterpMapNoNans
	Variable ImageMedian = StatsMedian(InterpMapNoNans)
	
	StrSwitch (RangeMode)
		Case "MinMax":
			Min_dval = WaveMin(InterpMap)
			Max_dval = WaveMax(InterpMap)
			Break
		Case "Avg±1se":
			Min_dval = ImageAvg-ImageSdev
			Max_dval = ImageAvg+ImageSdev
			Break
		Case "Avg±2se":
			Min_dval = ImageAvg-2*ImageSdev
			Max_dval = ImageAvg+2*ImageSdev
			Break
		Case "Avg±3se":
			Min_dval = ImageAvg-3*ImageSdev
			Max_dval = ImageAvg+3*ImageSdev
			Break
		Case "Avg±4se":
			Min_dval = ImageAvg-4*ImageSdev
			Max_dval = ImageAvg+4*ImageSdev
			Break
		Case "Med±1se":
			Min_dval = ImageMedian-1*ImageSdev
			Max_dval = ImageMedian+1*ImageSdev
			Break			
		Case "Med±2se":
			Min_dval = ImageMedian-2*ImageSdev
			Max_dval = ImageMedian+2*ImageSdev
			Break	
		Case "Med±3se":
			Min_dval = ImageMedian-3*ImageSdev
			Max_dval = ImageMedian+3*ImageSdev
			Break	
		Case "Med±4se":
			Min_dval = ImageMedian-4*ImageSdev
			Max_dval = ImageMedian+4*ImageSdev
			Break										
	EndSwitch
	
	String ScaleType = StringByKey("SCALE", MapSettingsWave[%$DataSource])	
	
	If (Min_dval < 0 && !GrepString(ScaleType, "(?i)ECDF") )
		Min_dval = 0
	EndIf
	
	MapSettingsWave[%$DataSource] = ReplaceNumberByKey("MIN", MapSettingsWave[%$DataSource], Min_dval)
	MapSettingsWave[%$DataSource] = ReplaceNumberByKey("MAX", MapSettingsWave[%$DataSource], Max_dval)	
	
	If (ItemsInList(ControlNameList(MapName, ";", "SV")) > 0 ) 
		SetVariable MinSV, value=_NUM:Min_dval
		SetVariable MaxSV, value=_NUM:Max_dval
	EndIf
	
	// STEP5: Setup color scale:
	// ------------------
	ColorScale/W=$MapName/C/N=MapCS/A=RC/E tickLen=7.0, heightPct=100, nticks=10	
	
	Variable ElementCharNo = strsearch(DataSource, "_",0)
	String ElementString = DataSource[0,ElementCharNo-1]	
	

	String ColorMap = StringByKey("COLORMAP", MapSettingsWave[%$DataSource])
	
	If (cmpstr(ScaleType, "Logarithmic") == 0 && Min_dval <=0)
		Min_dval = 0.01
	EndIf
	
	print Min_dval, Max_dval
	ModifyImage/W=$MapName $InterpMapName ctab={Min_dval,Max_dval,$ColorMap,0} // change last number to 1 for reverse colors
	
	StrSwitch(ScaleType)
		Case "Linear":
				ModifyImage/W=$MapName $InterpMapName log=0
				ColorScale/W=$MapName/C/N=MapCS log=0
				ColorScale/W=$MapName/C/N=MapCS minor=1					
			Break
		Case "Logarithmic":
				ModifyImage/W=$MapName $InterpMapName log=1
				ColorScale/W=$MapName/C/N=MapCS log=1
				ColorScale/W=$MapName/C/N=MapCS minor=1		
			Break
		Case "ECDF":
			Make/O/N=10000 $(DataSource + "_Hist")
			Histogram/B=1 InterpMap, $(DataSource + "_Hist")
			Integrate $(DataSource + "_Hist")/D=$(DataSource + "_Int")
			SetScale x 0,1, "", $(DataSource + "_Int")
			SetScale y 0,1, "", $(DataSource + "_Int")
			Wave IntWave = $(DataSource + "_Int")
			IntWave = IntWave/wavemax(IntWave)

			ModifyImage/W=$MapName $InterpMapName lookup=IntWave

			ColorTab2Wave $ColorMap
			Wave M_colors
			Variable ncolours = DimSize(M_colors,0)	
			
			// Try something:
			StatsQuantiles InterpMap
			
			Variable ECDF_Min = V_Q25-3*V_IQR
			Variable ECDF_Max = V_Q75+3*V_IQR
			WaveStats/Q InterpMap
			
			If (V_max < ECDF_Max)
				ECDF_Max = V_max
			EndIf
			
			IF (V_min > ECDF_Min)
				ECDF_Min = V_min
			ENdIf
			
			SetScale x Min_dval,Max_dval, "", $(DataSource + "_Int")
			//SetScale x ECDF_Min,ECDF_Max, "", $(DataSource + "_Int")
			
			// Need to Change SampleImage to InterpMap	
			// Make an even more detailed version including the histogram:
			Make/O/N=200 InterpMap_Hist
			Histogram/B=1 InterpMap, InterpMap_Hist // Make a normal histogram
			Wave SampleHist = $"InterpMap_Hist"
			Variable HistNorm = wavemax(SampleHist)
			Variable ECDFNorm = wavemax(IntWave)
			SampleHist= SampleHist/HistNorm
			IntWave = IntWave/ECDFNorm
			
			DoWindow ECDFColours
			If (V_flag)
				KillWIndow ECDFColours
			EndIf
			Display/K=1/N=ECDFColours IntWave
			AppendToGraph/W=ECDFColours InterpMap_Hist
			ModifyGraph/W=ECDFColours mode(InterpMap_Hist)=6
			ModifyGraph/W=ECDFColours tick(left)=3,mirror=2,noLabel(left)=1,axOffset(left)=-5
			ModifyGraph/W=ECDFColours axisOntop(bottom)=1,standoff=0
			SetAxis/W=ECDFColours left 0,1
			ModifyGraph/W=ECDFColours rgb=(0,0,0)
			ModifyGraph/W=ECDFColours width=650, height=450,gFont="Helvetica",gfSize=16
			Label/W=ECDFColours bottom ElementString+" [ppm]"
			If (GrepString(DataSource, "(?i)CPS"))
				Label/W=ECDFColours bottom ElementString+" [CPS]"
			EndIf
			ColorScale/W=ECDFColours/C/N=ECDFCS/F=0/A=MC  ctab={0,100,$ColorMap,0},nticks=0
			ColorScale/W=ECDFColours/C/N=ECDFCS/Z=1/A=RC/X=0.00/Y=0.00 heightPct=99.5
			ColorScale/W=ECDFColours/C/N=ECDFCS/B=1 heightPct=100,frame=0.00
			ColorScale/W=ECDFColours/C/N=ECDFCS width=20

			SetDrawEnv/W=ECDFColours xcoord=bottom, ycoord=left, dash=3, linethick=1.5
			SetDrawEnv/W=ECDFColours save
						
			For (j=1; j <10; j += 1)
				Variable ThisR = M_colors[j*ncolours/10][0]
				Variable ThisG = M_colors[j*ncolours/10][1]
				Variable ThisB = M_colors[j*ncolours/10][2]
				
				SetDrawEnv/W=ECDFColours linefgc=(ThisR,ThisG,ThisB)
				SetDrawEnv/W=ECDFColours save
				
				Variable jpos = BinarySearch(IntWave, j/10)+1
				Variable TickValue = (jpos/10000)*(Max_dval-Min_dval)+Min_dval
//				Variable TickValue = (jpos/10000)*(ECDF_Max-ECDF_Min)+ECDF_Min
				
				DrawLine/W=ECDFColours Max_dval, j/10, TickValue, j/10
//				DrawLine/W=ECDFColours ECDF_Max, j/10, TickValue, j/10
				DrawLine/W=ECDFColours TickValue, j/10, TickValue, 0
			EndFor	
			
	//		SetAxis/W=ECDFColours bottom ECDF_Min, ECDF_Max
			print "ECDF Min/Max: ", ECDF_Min, ECDF_Max
//			WaveStats/Q InterpMap

//			StatsQuantiles InterpMap
//			GetAxis/W=ECDFColours bottom //note: this replaces V_min and V_max
						
//			If (V_Q75+3*V_IQR < V_max)
//				SetAxis/W=ECDFColours bottom V_min, V_Q75+3*V_IQR
//			EndIf
			
//			GetAxis/W=ECDFColours bottom			
//			If (V_Q25 - 3*V_IQR > V_min)
//				SetAxis/W=ECDFColours bottom V_Q25-3*V_IQR, V_max
//			EndIf
			
				
			Break
		Default:
			Print "Unrecognized scaling type."
			Break
	EndSwitch
	
	ColorScale/W=$MapName/C/N=MapCS/F=0/X=5.00/Y=4.00 width=25
	
	// LAST STEP: Cleaning things up a bit:
	// -------------------------
	
//	Variable MapMax = WaveMax(InterpMap)
//	Variable MapMin = WaveMin(InterpMap)
	
	ModifyGraph/W=$MapName width={Aspect, xlength/ylength}
	ModifyGraph/W=$MapName height=600
	ModifyGraph/W=$MapName standoff=0
	ModifyGraph/W=$MapName gFont="Helvetica"//,gfSize=16
	Label/W=$MapName left "Y [\\U]"
	Label/W=$MapName bottom "X [\\U]"
	ModifyGraph/W=$MapName tick(bottom)=1;DelayUpdate

	Label/W=$MapName left "\\u#2µm";DelayUpdate
	Label/W=$MapName bottom "\\u#2 µm"
	ModifyGraph/W=$MapName gFont="Helvetica",gfSize=20
	ModifyGraph/W=$MapName tick=1
	ModifyGraph/W=$MapName lblMargin(left)=20,lblMargin(bottom)=10	
	


//	String MapCSLabel = ""
	
	// Discordance
	If (GrepString(DataSource, "(?i)disc"))
		ColorScale/W=$MapName/C/N=MapCS "Discordance [%]"
	// Approx concentration from UPb DRS
	ElseIf (GrepString(DataSource, "(?i)Approx"))
		String ElStr = StringFromList(1, DataSource, "_")
		ColorScale/W=$MapName/C/N=MapCS ElStr + " [ppm]"
	ElseIf (GrepString(DataSource, "(?i)U_Th_Ratio"))
		ColorScale/W=$MapName/C/N=MapCS "U/Th"
	ElseIf (GrepString(DataSource, "(?i)Dose"))
		ColorScale/W=$MapName/C/N=MapCS prescaleExp=-15
		ColorScale/W=$MapName/C/N=MapCS "Dose [10\S15\M \F'Symbol'a\F'Helvetica'/mg]"
	// Age
	ElseIf (GrepString(DataSource, "(?i)FinalAge"))
		String NumerMass = DataSource[8, 10]
		String DenomMass = DataSource[12,14]
		String NumerEl = "Pb"
		String DenomEl = ""
		If (GrepString(DenomMass, "232"))
			DenomEl = "Th"
		ElseIf (GrepString(DenomMass, "206"))
			DenomEl = "Pb"
		Else
			DenomEl = "U"
		EndIf
		
		ColorScale/W=$MapName/C/N=MapCS "\S"+NumerMass+"\M"+NumerEl+"\Z24/\M\S" + DenomMass+ "\M" + DenomEl + " Age [Ma]"
	// Ratio
	ElseIf (GrepString(DataSource, "(?i)Final2"))
		NumerMass = DataSource[5,7]
		DenomMass = DataSource[9,11]
		NumerEl = "Pb"
		DenomEl = ""
		
		If (GrepString(DenomMass, "232"))
			DenomEl = "Th"
		ElseIf (GrepString(DenomMass, "206"))
			DenomEl = "Pb"
		Else
			DenomEl = "U"
		EndIf
		
		If (GrepString(NumerMass, "238"))
			NumerEl = "U"
		EndIf
		
		ColorScale/W=$MapName/C/N=MapCS "\S"+NumerMass+"\M"+NumerEl+"\Z24/\M\S" + DenomMass+ "\M" + DenomEl
	
	// Normal concentration		
	Else 
		If (Max_dval < 1e4)
			ColorScale/W=$MapName/C/N=MapCS ElementString + " [ppm]"
		Else
			ColorScale/W=$MapName/C/N=MapCS prescaleExp=-4		
			ColorScale/W=$MapName/C/N=MapCS ElementString + " [Wt. %]"
		EndIf
		
		If (GrepString(DataSource, "(?i)CPS"))
			ColorScale/W=$MapName/C/N=MapCS prescaleExp=0				
			ColorScale/W=$MapName/C/N=MapCS ElementString + " [CPS]"
		EndIf
	EndIf
	
	
	// LAST +1 STEP: Set the axes mode
	
	String AxesMode = StringByKey("AXESMODE", MapSettingsWave[%$DataSource])
	
	StrSwitch(AxesMode)
		Case "Both":
			Break
		Case "Bottom":
			ModifyGraph/W=$MapName tick(bottom)=0,mirror=0,noLabel(left)=2,axThick(left)=0
			Break
		Case "None":
			ModifyGraph/W=$MapName tick(bottom)=0,mirror=0,noLabel(left)=2,axThick(left)=0
			ModifyGraph/W=$MapName tick(bottom)=3,noLabel=2,axThick=0
			Break
	EndSwitch
	

End

Function BT_Overview(CtrlName) : ButtonControl
	String CtrlName
	 
	Display/N=MapOverview/K=1
	String OverviewName = S_name	
	
	Wave/T MapSettingsWave = $ioliteDFpath("images", "MapSettingsWave")
	String DimString = ""
		
	SVar AutomateOverviewDimensions = $ioliteDFpath("images", "AutomateOverviewDimensions")
	If (SVar_Exists(AutomateOverviewDimensions))
		DimString = AutomateOverviewDimensions
	EndIf
	
	
	Variable NumberOfMaps = 0
	
	Variable Counter
	For (Counter = 0; Counter < dimsize(MapSettingsWave,0); Counter += 1)
		String ThisMapName = GetDimLabel(MapSettingsWave, 0, Counter)
		String ThisMapSettings = MapSettingsWave[%$ThisMapName]

		If (GrepString(StringByKey("INCLUDEINOVERVIEW", ThisMapSettings), "(?i)yes"))
			NumberOfMaps += 1
		EndIf
		
	EndFor		
	
	String DimStringOptions  = ""
	
	For (Counter = 2; Counter < 9; Counter += 1)
		DimStringOptions += num2str(Counter)+"x"+num2str(ceil(NumberOfMaps/Counter))+";"
	EndFor
	
	If (ItemsInList(DimString, "x") < 2)
		Prompt DimString, "Layout", popup, DimStringOptions
		DoPrompt "Overview layout...", DimString
	
		If (V_flag)
			Return 0
		EndIf
	EndIf
	
	Variable OverviewRows, OverviewCols
	OverviewRows = str2num(StringFromList(0, DimString, "x"))
	OverviewCols = str2num(StringFromList(1, DimString, "x"))
	
	Variable CurrentMapNum = -1
	For (Counter = 0; Counter < dimsize(MapSettingsWave,0); Counter += 1)
		ThisMapName = GetDimLabel(MapSettingsWave, 0, Counter)
		ThisMapSettings = MapSettingsWave[%$ThisMapName]

		If (GrepString(StringByKey("INCLUDEINOVERVIEW", ThisMapSettings), "(?i)yes"))
			CurrentMapNum += 1
		Else
			Continue
		EndIf
		
		Wave OriginalMap = $ioliteDFpath("images", ThisMapName)
		String InterpMapName = ThisMapName + "_Interp"
		
		String Internal = StringByKey("INTERNAL", ThisMapSettings)
		Variable InternalVal = NumberByKey("INTERNALVAL", ThisMapSettings)

		Variable UseInternal = 0
	
		If (cmpstr(Internal, "No") != 0)
			UseInternal = 1
			Wave InternalMapOrig = $ioliteDFpath("images", Internal)
		EndIf		
		
		
		// STEP1: Interpolate image:
		// ------------------
		
		String InterpMode = StringByKey("INTERP", ThisMapSettings)
		
		StrSwitch(InterpMode)
			Case "None":
				Duplicate/O OriginalMap $InterpMapName
				Break
			Case "Bilinear":
				ImageInterpolate/F={1, dimsize(OriginalMap,0)/dimsize(OriginalMap,1)}/DEST=$(InterpMapName) Bilinear OriginalMap
				If (UseInternal)
					ImageInterpolate/F={1, dimsize(OriginalMap,0)/dimsize(OriginalMap,1)}/DEST=InterpInternal Bilinear InternalMapOrig
				EndIf				
				Break
			Case "Spline":
				ImageInterpolate/D=2/F={1, dimsize(OriginalMap,0)/dimsize(OriginalMap,1)}/DEST=$(InterpMapName) Spline OriginalMap
				Break
			Case "Spline FDS":
				ImageInterpolate/FDS/D=2/F={1, dimsize(OriginalMap,0)/dimsize(OriginalMap,1)}/DEST=$(InterpMapName) Spline OriginalMap
				Break
			Case "Resample/Up":
				Duplicate/O OriginalMap $InterpMapName
				Variable UpScale = floor(dimsize(OriginalMap,0)/dimsize(OriginalMap,1))
				Resample/UP=(UpScale)/DIM=1 $InterpMapName			
			Default:
				Print "Unrecognized interpolation mode:", InterpMode
				Break
		EndSwitch
	
		Wave InterpMap = $ioliteDFpath("images", InterpMapName)

	
	// Hack to fix part of a map that had to be reanalyzed:
	Variable mm, ci
//	For (mm = 102; mm < 146; mm+=1)
//		For (ci = 0; ci < dimsize(InterpMap,0); ci += 1)
//		
//			InterpMap[ci][mm] = InterpMap[ci][mm]*1.2
//		EndFor
//	EndFor
//	
//	For (mm = 0; mm < 242; mm+=1)
//		For (ci = 0; ci < dimsize(InterpMap,0); ci += 1)
//			InterpMap[ci][mm] = InterpMap[ci][mm]*1.2
//		EndFor
//	
//	EndFor



		// STEP X: Apply filter:
		// --------------
		String FilterName = StringByKey("FILTER", ThisMapSettings)
		Variable FilterN = NumberByKey("FILTERN", ThisMapSettings)
		Variable FilterP = NumberByKey("FILTERP", ThisMapSettings)
	
		If (cmpstr(FilterName, "None") != 0)
			ImageFilter/N=(FilterN)/P=(FilterP) $FilterName InterpMap
		EndIf	
		
		// STEP X: Mask image:
		// --------------
		
		String Mask = StringByKey("MASK", ThisMapSettings)
		
		StrSwitch (Mask)
			Case "None":
				Break
			Case "Fuzzy":
				Wave FuzzyMask = $ioliteDFpath("images", "FuzzyMask")
				If (WaveExists(FuzzyMask))
					InterpMap = InterpMap*FuzzyMask
				EndIf
				Break
			Case "ROI":
				Wave ROIMask = $ioliteDFpath("images", "ROIMask")
				If (WaveExists(ROIMask))
					InterpMap = InterpMap*ROIMask
				EndIf
				Break
			Case "Logic":
				Wave LogicMask = $ioliteDFpath("images", "LogicMask")
				If (WaveExists(LogicMask))
					InterpMap = InterpMap*LogicMask
				EndIf
				Break
			Default:
				Print "Unrecognized mask mode:", Mask
				Break
		EndSwitch
		
		// STEP X: Apply multiplier
		Variable Multiplier = NumberByKey("MULTIPLIER", ThisMapSettings)

		InterpMap = Multiplier*InterpMap
		
		// STEP Y: Apply internal
		If (UseInternal)
			InterpInternal = InternalVal / InterpInternal
			InterpMap = InterpInternal * InterpMap
		EndIf		
		
		// STEP2: Setup dimensions
		// ------------------
		
		Wave xwave = $makeiolitewave("images", "xwave", n=dimsize(InterpMap,0))
		Wave ywave = $makeiolitewave("images", "ywave", n=dimsize(InterpMap,1))
		xwave = 0
		ywave = 0
		
		Variable xlength = str2num(StringBykey("WIDTH", ThisMapSettings))
		Variable ylength = str2num(StringBykey("HEIGHT", ThisMapSettings))
				
		Variable k,j
		For (j = 1; j < numpnts(xwave); j = j + 1)
			xwave[j] = xwave[j-1] + xlength/numpnts(xwave)
		EndFor
	
		For (j = 1; j < numpnts(ywave); j = j + 1)
			ywave[j] = ywave[j-1] + ylength/numpnts(ywave)
		EndFor
			
		SetScale/P x, 0, xlength/numpnts(xwave), "microns", InterpMap
		SetScale/P y, 0, ylength/numpnts(ywave), "microns", InterpMap
		
		
		// STEP3: Append map to window
		// ---------------------

		String ls = "L" + num2str(CurrentMapNum)
		String bs = "B" + num2str(CurrentMapNum)
		Variable c, r
		r = OverviewRows- floor(CurrentMapNum/OverviewCols)-1
		c = CurrentMapNum - OverviewCols*floor(CurrentMapNum/OverviewCols)

		Variable left = c/OverviewCols
		Variable right = (c+1)/OverviewCols
		Variable top = r/OverviewRows
		Variable bottom = (r+1)/OverviewRows

		AppendImage/W=$OverviewName/L=$("L"+num2str(CurrentMapNum))/B=$("B"+num2str(CurrentMapNum)) InterpMap
			
		SetAxis $ls 0, ylength
		SetAxis $bs 0, xlength
			
		// STEP4: Set range:
		// ------------
		
		String RangeMode = StringByKey("RANGEMODE", ThisMapSettings)
		String ScaleType = StringByKey("SCALE", ThisMapSettings)
				
		Variable Min_dval = str2num(StringByKey("MIN", ThisMapSettings))
		Variable Max_dval = str2num(StringByKey("MAX", ThisMapSettings))
		
		WaveStats/Q InterpMap
		Variable ImageAvg = V_avg
		Variable ImageAdev = V_adev
		Variable ImageSdev = V_sdev
		Variable ImageSem = V_sem
		
		Duplicate/O InterpMap InterpMapNoNans
		Redimension/N=(dimsize(InterpMap,0)*dimsize(InterpMap,1)) InterpMapNoNans
		Sort InterpMapNoNans, InterpMapNoNans
		WaveStats/Q InterpMapNoNans
		Redimension/N=(dimsize(InterpMapNoNans,0)-V_numNans) InterpMapNoNans
		Variable ImageMedian = StatsMedian(InterpMapNoNans)
		
		StrSwitch (RangeMode)
			Case "MinMax":
				Min_dval = WaveMin(InterpMap)
				Max_dval = WaveMax(InterpMap)
				Break
			Case "Avg±1se":
				Min_dval = ImageAvg-ImageSdev
				Max_dval = ImageAvg+ImageSdev
				Break
			Case "Avg±2se":
				Min_dval = ImageAvg-2*ImageSdev
				Max_dval = ImageAvg+2*ImageSdev
				Break
			Case "Avg±3se":
				Min_dval = ImageAvg-3*ImageSdev
				Max_dval = ImageAvg+3*ImageSdev
				Break
			Case "Avg±4se":
				Min_dval = ImageAvg-4*ImageSdev
				Max_dval = ImageAvg+4*ImageSdev
				Break
			Case "Med±1se":
				Min_dval = ImageMedian-1*ImageSdev
				Max_dval = ImageMedian+1*ImageSdev
				Break			
			Case "Med±2se":
				Min_dval = ImageMedian-2*ImageSdev
				Max_dval = ImageMedian+2*ImageSdev
				Break	
			Case "Med±3se":
				Min_dval = ImageMedian-3*ImageSdev
				Max_dval = ImageMedian+3*ImageSdev
				Break	
			Case "Med±4se":
				Min_dval = ImageMedian-4*ImageSdev
				Max_dval = ImageMedian+4*ImageSdev
				Break										
		EndSwitch
		
		If (Min_dval < 0 && !GrepString(ScaleType, "(?i)ECDF") )
			Min_dval = 0
		EndIf
		
		MapSettingsWave[%$ThisMapName] = ReplaceNumberByKey("MIN", MapSettingsWave[%$ThisMapName], Min_dval)
		MapSettingsWave[%$ThisMapName] = ReplaceNumberByKey("MAX", MapSettingsWave[%$ThisMapName], Max_dval)
		
		// STEP5: Setup color scale:
		// ------------------
		

		String ColorMap = StringByKey("COLORMAP", ThisMapSettings)
		
		If (cmpstr(ScaleType, "Logarithmic") == 0 && Min_dval <=0)
			Min_dval = 0.01
		EndIf
		
		ModifyImage $InterpMapName ctab={Min_dval,Max_dval,$ColorMap,0}
		
		StrSwitch(ScaleType)
			Case "Linear":
				ModifyImage $InterpMapName log=0
				//ColorScale/C/N=MapCS log=0
				//ColorScale/C/N=MapCS minor=1					
				Break
			Case "Logarithmic":
				ModifyImage $InterpMapName log=1
				//ColorScale/C/N=MapCS log=1
				//ColorScale/C/N=MapCS minor=1		
				Break
			Case "ECDF":
				Make/O/N=10000 $(ThisMapName + "_Hist")
				Histogram/B=1 InterpMap, $(ThisMapName + "_Hist")
				Integrate $(ThisMapName + "_Hist")/D=$(ThisMapName + "_Int")
				SetScale x 0,1, "", $(ThisMapName + "_Int")
				SetScale y 0,1, "", $(ThisMapName + "_Int")
				Wave IntWave = $(ThisMapName + "_Int")
				IntWave = IntWave/wavemax(IntWave)
	
				ModifyImage $InterpMapName lookup=IntWave
				Break
			Default:
				Print "Unrecognized scaling type."
				Break
		EndSwitch
		
//		ColorScale/C/N=MapCS/F=0/X=5.00/Y=4.00 width=25		
	
		ModifyGraph nticks($ls)=0,noLabel($ls)=2,standoff($ls)=0, axisEnab($ls)={r/OverviewRows, (r+1)/OverviewRows}
		ModifyGraph nticks($bs)=0,noLabel($bs)=2,standoff($bs)=0,axisEnab($bs)={c/OverviewCols, (c+1)/OverviewCols}
		ModifyGraph freePos($bs)={r/OverviewRows, kwFraction}
		ModifyGraph freePos($ls)={c/OverviewCols, kwFraction}	

		if (r==OverviewRows-1)
			ModifyGraph mirror($bs)=1
		Endif		
		
		if (c==OverviewCols-1)
			ModifyGraph mirror($ls)=1
		EndIf	

		Print NumberOfMaps, Counter, CurrentMapNum, OverviewCols, c		
		if ((CurrentMapNum == NumberOfMaps-1) && (c < OverviewCols-1))
			ModifyGraph mirror($ls)=1		
			ModifyGraph MirrorPos($ls)=1/(OverviewCols-c)//0.5//1-(OverviewCols-c-1)/(OverviewCols)//(c+1)/nc
		Endif
		
		Variable ElementCharNo = strsearch(ThisMapName, "_",0)
		String ElementString = ThisMapName[0,ElementCharNo-1]		

		// Discordance
		If (GrepString(ThisMapName, "(?i)disc"))
			TextBox/C/N=$("text"+num2str(Counter))/A=LB/X=(100*c/OverviewCols+0.5)/Y=(100*r/OverviewRows+0.5) "Discordance"
		// Approx concentration from UPb DRS
		ElseIf (GrepString(ThisMapName, "(?i)Approx"))
			String ElStr = StringFromList(1, ThisMapName, "_")
			TextBox/C/N=$("text"+num2str(Counter))/A=LB/X=(100*c/OverviewCols+0.5)/Y=(100*r/OverviewRows+0.5) ElStr
		ElseIf (GrepString(ThisMapName, "(?i)U_Th_Ratio"))
			TextBox/C/N=$("text"+num2str(Counter))/A=LB/X=(100*c/OverviewCols+0.5)/Y=(100*r/OverviewRows+0.5) "U/Th"
		ElseIf (GrepString(ThisMapName, "(?i)Dose"))
			TextBox/C/N=$("text"+num2str(Counter))/A=LB/X=(100*c/OverviewCols+0.5)/Y=(100*r/OverviewRows+0.5) "Dose"
		// Age
		ElseIf (GrepString(ThisMapName, "(?i)FinalAge"))
			String NumerMass = ThisMapName[8, 10]
			String DenomMass = ThisMapName[12,14]
			String NumerEl = "Pb"
			String DenomEl = ""
			If (GrepString(DenomMass, "232"))
				DenomEl = "Th"
			ElseIf (GrepString(DenomMass, "206"))
				DenomEl = "Pb"
			Else
				DenomEl = "U"
			EndIf
			
			TextBox/C/N=$("text"+num2str(Counter))/A=LB/X=(100*c/OverviewCols+0.5)/Y=(100*r/OverviewRows+0.5) "\S"+NumerMass+"\M"+NumerEl+"\Z20/\M\S" + DenomMass+ "\M" + DenomEl + " Age"
		// Ratio
		ElseIf (GrepString(ThisMapName, "(?i)Final2"))
			NumerMass = ThisMapName[5,7]
			DenomMass = ThisMapName[9,11]
			NumerEl = "Pb"
			DenomEl = ""
		
			If (GrepString(DenomMass, "232"))
				DenomEl = "Th"
			ElseIf (GrepString(DenomMass, "206"))
				DenomEl = "Pb"
			Else
				DenomEl = "U"
			EndIf
		
			If (GrepString(NumerMass, "238"))
				NumerEl = "U"
			EndIf
		
			TextBox/C/N=$("text"+num2str(Counter))/A=LB/X=(100*c/OverviewCols+0.5)/Y=(100*r/OverviewRows+0.5) "\S"+NumerMass+"\M"+NumerEl+"\Z20/\M\S" + DenomMass+ "\M" + DenomEl
		
		
		// Normal concentration		
		Else 
			TextBox/C/N=$("text"+num2str(Counter))/A=LB/X=(100*c/OverviewCols+0.5)/Y=(100*r/OverviewRows+0.5) ElementString
		EndIf

		ModifyGraph gFont="Helvetica", gfSize=12
		
		ModifyGraph width={Aspect, (OverviewCols/OverviewRows)*WaveMax(xwave)/WaveMax(ywave)}
	
	EndFor
End

Function MapAssociations()
	SetDataFolder ioliteDFpath("images", "")

	String AvailableMaps = WaveList("*Map", ";", "")
	print AvailableMaps
	
	Wave TestMap = $ioliteDFpath("images", StringFromList(0, AvailableMaps))
	
	Make/O/N=(ItemsInList(AvailableMaps), dimsize(TestMap,0)*dimsize(TestMap,1)) PCADataTable
	
	Variable i
	For (i = 0; i < ItemsInList(AvailableMaps); i += 1)
		Wave CurrentMap = $ioliteDFpath("images", StringFromList(i, AvailableMaps))
		
		Variable x, y, coln
		For (x = 0; x < dimsize(TestMap,0); x += 1)
			For (y = 0; y < dimsize(TestMap, 1); y += 1)
				coln = x *y + y
				PCADataTable[i][coln] = CurrentMap[x][y]
			EndFor
		EndFor
	EndFor
	
	PCA/ALL/SRMT/SCMT PCADataTable
	Wave M_C
	Make/O/N=(dimsize(TestMap,0)*dimsize(TestMap,1)) PC1, PC2, PC3, PC4
	
	Display/K=1 PC2 vs PC1
End