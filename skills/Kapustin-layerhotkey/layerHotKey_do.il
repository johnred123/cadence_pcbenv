;
;	$Source$ $Revision$ $Branch$ $Rev$
;	$Author$ $Date$
;
;	Files required:
;			layerHotKey.il
;			layerHotKey_utils.il
;

LAYER_HOT_KEY_DO_FILE = t
;
;
;
defun( lhkAddLayerGroup (form field)
	let( (newName newLayerGroup)
when( (axlIsDebug) println("lhkAddLayerGroup"))
		newName = axlUIPrompt("Enter name for new Color View")
		when(newName
			newLayerGroup = list(newName)
			_lhkLayerGroups = append(_lhkLayerGroups list(newLayerGroup))
	;		_lhkLayerGroups = sortcar(_lhkLayerGroups 'alphalessp)
			lhkFillTree(form _lhkLayerGroups)
			lhkFillGrid(form _lhkLayerGroups)
			axlFormSetFieldEditable(form "bnApply" t)
		)
	);end-let
);end-defun

;
;
;
defun( lhkRemoveLayerGroup (form field label)
	let( (layerGroup newLayerGroups)
when( (axlIsDebug) println("lhkRemoveLayerGroup"))
		foreach(layerGroup _lhkLayerGroups
			when( car(layerGroup)!=label
				newLayerGroups = cons(layerGroup newLayerGroups)
			)
		)
		_lhkLayerGroups = reverse(newLayerGroups)

		lhkFillTree(form _lhkLayerGroups)
		lhkFillGrid(form _lhkLayerGroups)
		axlFormSetFieldEditable(form "bnApply" t)
	);end-let
);end-defun

;
;
; 
defun( lhkAddLayer (form field parentLabel)
	let( (parent layerGroup)
when( (axlIsDebug) println("lhkAddLayer"))
		foreach(layerGroup _lhkLayerGroups
			when(car(layerGroup)==parentLabel
				_selectedGroup = layerGroup
			)
		)
		lhkInitClassForm(_selectedGroup)
	);end-let
);end-defun

;
;
;
defun( lhkRemoveLayer (form field id parentId)
	let( (parentLabel label newList newLayers layerGroup)
when( (axlIsDebug) println("lhkRemoveLayer"))
		parentLabel = axlFormTreeViewGetLabel(form field parentId)
		label = axlFormTreeViewGetLabel(form field id)
		foreach(layerGroup _lhkLayerGroups
			if( ( car(layerGroup)==parentLabel) ; && length(cadr(layerGroup))>1 )
				then newLayers = remove( label caddr(layerGroup))
				else newLayers = caddr(layerGroup)
			)
			newLayers = list(car(layerGroup) cadr(layerGroup) newLayers)
			newList = cons(newLayers newList)
		)
		_lhkLayerGroups = reverse(newList)
		axlFormSetFieldEditable(form "bnApply" t)
		; update list
		lhkFillTree(form _lhkLayerGroups list(parentLabel))
		lhkFillGrid(form _lhkLayerGroups)
	);end-let
);end-defun

;
;
;
defun( lhkUpdateHotKey (pHotKey layerGroupName)
	let( (newList layerGroup newLayerGroup)
when( (axlIsDebug) println("lhkUpdateHotKey"))
		foreach(layerGroup _lhkLayerGroups
			if( ( car(layerGroup)==layerGroupName) ; && length(cadr(layerGroup))>1 )
				then newLayerGroup = list(car(layerGroup) pHotKey caddr(layerGroup))
				else newLayerGroup = layerGroup
			)
			newList = cons(newLayerGroup newList)
		)
		axlFormSetFieldEditable(_lhkFormPtr "bnApply" t)
		_lhkLayerGroups = reverse(newList)
	);end-let
);end-defun

;
;
;
defun( lhkSetHotkeys (layerGroups)
	let( (layerGroup groupName hotKey keyValue layers layer)
when( (axlIsDebug) println("lhkSetHotkeys"))
		foreach(layerGroup layerGroups
			groupName = car(layerGroup)
			hotKey = cadr(layerGroup)
			layers = caddr(layerGroup)
			when(layers
				keyValue = ""
				foreach(layer layers
					keyValue = strcat(keyValue "color -toggle '" layer "'; ")
				)
				axlSetAlias(groupName keyValue)
				when( lhkIsValidHotKey(hotKey)
					axlSetFunckey(hotKey groupName)
				)
				when( (axlIsDebug) printf( "%s - %L = %L\n" groupName, hotKey, keyValue))
			)
		)
		printf("Layers hotkeys were set\n")
	);end-let
);end-defun


; 
; Show or hide layers from group.
;
defun( lhkShowGroup (groupName isShow)
	let( (layerGroup hotKey keyValue layers layer)
when( (axlIsDebug) println("lhkShowGroup"))
		foreach(layerGroup _lhkLayerGroups
			when(car(layerGroup)==groupName
				layers = caddr(layerGroup)
printf("layers: %L\n" layers)
				when(layers
					foreach(layer layers
printf("layer: %L\n" layer)
						axlVisibleLayer(layer isShow)
					)
					axlVisibleUpdate(t)
				)
			)
		)
	);end-let
);end-defun

;
; Store list of groups to attachment.
;
defun( lhkStoreHotkeys (layerGroups)
	let( (sLayerGroups attachment)
when( (axlIsDebug) println("lhkStoreHotkeys"))
		sLayerGroups = sprintf(nil "%L" layerGroups)
		attachment = axlGetAttachment("LAYER_HOTKEYS" 'string)
		if( attachment
		then
			attachment->data = sLayerGroups
			axlSetAttachment(attachment "123QWEqwe")
		else
			attachment = axlCreateAttachment("LAYER_HOTKEYS" "123QWEqwe" 0 'string sLayerGroups)
		);if
		printf("Hotkeys stored\n")
	);end-let
);end-defun

;
; Restore list of groups from attachment.
;
defun( lhkRestoreHotkeys ()
	let( (sLayerGroups attachment layerGroups)
when( (axlIsDebug) println("lhkRestoreHotkeys"))
		attachment = axlGetAttachment("LAYER_HOTKEYS" 'string)
		sLayerGroups = attachment->data
		when( sLayerGroups
			layerGroups = car(errsetstring(strcat("'" sLayerGroups)))
		)
		layerGroups
	);end-let
);end-defun

; 
;
; Return list 
defun( lhkLoadListFromFile ( filePath fileName )
	let( (workingDir file nextLine result)
		result = ""
		workingDir = getWorkingDir()
		changeWorkingDir(filePath)
		when( isFile(fileName)
			file = infile(fileName)
			while( gets( nextLine file )
				result = strcat(result nextLine)
			)
			close( file )
		)
		changeWorkingDir(workingDir)
		if( (result && result != "")
			then result = car(errsetstring(strcat("'" result)))
			else result = nil
		)
		result
	);let
);end-defun

; 
;
;  
defun( lhkSaveListToFile ( filePath fileName pList)
	let( (workingDir fTemp result)
		workingDir = getWorkingDir()
		changeWorkingDir(filePath)
		if( isFile(fileName)
			then
				when(axlUIYesNo(strcat("File '" fileName "' exist, replace?") "Warning" 'no)
					fTemp = outfile(fileName)
					pprint(pList fTemp)
					close( fTemp )
					result = t
				)
			else
				fTemp = outfile(fileName)
				pprint(pList fTemp)
				close( fTemp )
				result = t
		)		
		changeWorkingDir(workingDir)
		result
	);let
);end-defun



