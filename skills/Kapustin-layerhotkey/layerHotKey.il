;
;	$Source$ $Revision$ $Branch$ $Rev$
;	$Author$ $Date$
;
;	Files required:
;			layerHotKey.form
;			layerHotKey_scl.form
;			layerHotKey_do.il
;			layerHotKey_util.il
;

axlDebug(nil)
/*axlDebug(t)
;  reload script, only for development purpose
axlCmdRegister( "lo" 'lo)
procedure( lo()
	load("o:/Sripts/layerHotKey/layerHotKey_do.il")
	load("o:/Sripts/layerHotKey/layerHotKey_util.il")
	load("o:/Sripts/layerHotKey/layerHotKey.il")
	layerHotKey()
)
*/

defun( lhkThrowError (passed message)
	when(!passed
		error("lhkLoadSource" message)
	)
);end-defun

defun( lhkLoadSource ()
	let( (workingDir envPath path i passed)
		passed = t
		; check il
		workingDir = getWorkingDir()
		envPath = axlGetVariableList("SITE_SKILLPATH")
when( (axlIsDebug) printf("envPath: %L\n" envPath))
		when(stringp(envPath) envPath = list(envPath) )

		; load layerHotKey_do.il
		when(!boundp('LAYER_HOT_KEY_DO_FILE)
when( (axlIsDebug) printf("load layerHotKey_do.il\n"))
			passed = nil
			for( i 1 length(envPath)
				path = nthelem(i envPath)
when( (axlIsDebug) printf("path: %L\n" path))
				changeWorkingDir(path)
				when( isFile("./layerHotKey/layerHotKey_do.il")
					load("./layerHotKey/layerHotKey_do.il")
					passed = t
					i = length(envPath) ; exit from loop
				)
				changeWorkingDir(workingDir)
			);for
			lhkThrowError(passed "File not found 'layerHotKey_do.il'")
		)

		; load layerHotKey_util.il
		when(!boundp('LAYER_HOT_KEY_UTIL_FILE)
when( (axlIsDebug) printf("load layerHotKey_util.il\n"))
			passed = nil
			for( i 1 length(envPath)
				path = nthelem(i envPath)
when( (axlIsDebug) printf("path: %L\n" path))
				changeWorkingDir(path)
				when( isFile("./layerHotKey/layerHotKey_util.il")
					load("./layerHotKey/layerHotKey_util.il")
					passed = t
					i = length(envPath) ; exit from loop
				)
				changeWorkingDir(workingDir)
			);for
			lhkThrowError(passed "File not found 'layerHotKey_util.il'")
		)

		formEnv = axlGetVariableList("formpath")
		when(stringp(formEnv) formEnv = list(formEnv) )
		envPath = nconc(envPath formEnv)
when( (axlIsDebug) printf("Form envPath: %L\n" envPath))

		; check layerHotKey.form
		when(!boundp('LAYER_HOT_KEY_FORM)
when( (axlIsDebug) printf("Find layerHotKey.form\n"))
			for( i 1 length(envPath)
				path = nthelem(i envPath)
when( (axlIsDebug) printf("path: %L\n" path))
				changeWorkingDir(path)
				when( isFile("layerHotKey.form")
					passed = t
					LAYER_HOT_KEY_FORM = strcat(path "/layerHotKey.form" )
					i = length(envPath) ; exit from loop
				)
				when( isFile("./layerHotKey/layerHotKey.form")
					passed = t
					LAYER_HOT_KEY_FORM = strcat(path "/layerHotKey/layerHotKey.form" )
					i = length(envPath) ; exit from loop
				)
				changeWorkingDir(workingDir)
			);for
			lhkThrowError(passed "File not found 'layerHotKey.form'")
		)

		; check layerHotKey_scl.form
		when(!boundp('LAYER_HOT_KEY_SCL_FORM)
when( (axlIsDebug) printf("Find layerHotKey_scl.form\n"))
			for( i 1 length(envPath)
				path = nthelem(i envPath)
when( (axlIsDebug) printf("path: %L\n" path))
				changeWorkingDir(path)
				when( isFile("layerHotKey_scl.form")
					passed = t
					LAYER_HOT_KEY_SCL_FORM = strcat(path "/layerHotKey_scl.form" )
					i = length(envPath) + 1 ; exit from loop
				)
				when( isFile("./layerHotKey/layerHotKey_scl.form")
					passed = t
					LAYER_HOT_KEY_SCL_FORM = strcat(path "/layerHotKey/layerHotKey_scl.form" )
					i = length(envPath) + 1 ; exit from loop
				)				
				changeWorkingDir(workingDir)
			);for
			lhkThrowError(passed "File not found 'layerHotKey_scl.form'")
		)
		changeWorkingDir(workingDir)
	)
);end-defun

lhkLoadSource()

;---------------------------------------------------------------------
LAYER_HOT_KEY_FILE = t
axlCmdRegister( "lhk" 'layerHotKey  ?cmdType "interactive"); ?doneCmd 'lhkDone ?cancelCmd 'lhkCancel)
axlUIMenuRegister( "colorview create" '( ("Layers Hot&Keys" "lhk") ) )
;---------------------------------------------------------------------
procedure( lhkPreloadHotKey( arg )
	let( (layerGroups)
when( (axlIsDebug) println("lhkPreloadHotKey"))
		; RegExp for funckey validation
		_lhkRegExp = pcreCompile("^(?!(~F)[2-9])(?!^~[XCVS]$)(?!S[0-9])((C?A?S?F([2-9]|1[012]))|((~?A?S?)?[A-Z0-9]))$")
		layerGroups = lhkRestoreHotkeys()
		if( layerGroups
			then ; set hot keys
				_lhkOldLayerGroups = layerGroups
			else ; default Layer Groups
				_lhkOldLayerGroups = lhkLoadDefault()
		)
		lhkSetHotkeys(_lhkOldLayerGroups)
	)
);end-defun

axlTriggerSet('open 'lhkPreloadHotKey)

;
; ----------------- Main -----------------------------
;
procedure( layerHotKey( )
	let( (event)
		when( axlOKToProceed()
			lhkInitGlobalVariable()
;			lhkSetHotkeys(_lhkOldLayerGroups)
			axlUIPopupSet( popupA )
			lhkInitForm()
			; dummy loop
			while( _finish == nil
				event = axlEnterEvent('(PICK) nil nil)
				caseq(event->type
					(DONE
when( (axlIsDebug) println("DONE"))
						lhkDone()
					)
					(CANCEL
when( (axlIsDebug) println("CANCEL"))
						lhkCancel()
					)
				)
			)
			_finish = nil
		)
	)
);endprocedure

;
;Menu Call
;
defun( lhkDone ()
when( (axlIsDebug) println("lhkDone"))
	lhkStoreHotkeys(_lhkLayerGroups)
	lhkSetHotkeys(_lhkLayerGroups)
	_lhkOldLayerGroups = _lhkLayerGroups
	lhkExitFromScript()
);end-fun
defun( lhkCancel ()
when( (axlIsDebug) println("lhkCancel"))
	lhkExitFromScript()
);end-fun

;
;Main form
;
defun( lhkInitForm ()
when( (axlIsDebug) println("initForm"))
	when(!_lhkFormPtr
		_lhkFormPtr = axlFormCreate( '_lhkFormPtr LAYER_HOT_KEY_FORM '(c canvas msglines 0) 'lhkFormCallBack t)
	)
	lhkFillTree(_lhkFormPtr _lhkOldLayerGroups)
	lhkFillGrid(_lhkFormPtr _lhkOldLayerGroups)
	axlFormSetFieldEditable(_lhkFormPtr "bnApply" nil)
	axlFormDisplay(_lhkFormPtr)

; temporary disabled
	axlFormSetFieldEditable(_lhkFormPtr "bnHelp" nil)
; temporary disabled
);end-defun

;
;
;
defun( lhkFillTree (form layerGroups @optional expandNames)
	let( (item x)
when( (axlIsDebug) println("lhkFillTree"))
		; clear tree
		axlFormTreeViewSet(form "treeField" 'TV_REMOVEALL nil)
		; fill tree
		foreach( item layerGroups
			parentLabel = car(item)
			parentId = axlFormTreeViewAddItem(form "treeField" parentLabel nil nil)
			when(cddr(item) ; has subelements
				foreach( subLabel caddr(item)
					axlFormTreeViewAddItem(form "treeField" subLabel parentId nil)
				)
			)
			when( lhkIsItemInList(parentLabel expandNames)
				axlFormTreeViewSet(form "treeField" 'TV_EXPAND parentId)
			)
			axlFormTreeViewSet(form "treeField" 'TV_SORTCHILDREN parentId)

		)
		axlFormTreeViewSet(form "treeField" 'TV_NOEDITLABEL nil)

when( (axlIsDebug) println("lhkFillTree: END"))
	);end-let
);end-defun

defun( lhkFillGrid (form layerGroups)
	let( (col cell layerGroup i )
when( (axlIsDebug) println("lhkFillGrid"))
		; clear grid
		axlFormGridReset(form "gridField")
		col = make_formGridCol()

		col->fieldType = 'CHECKITEM
		col->colWidth = 4
		col->align = 'center
		col->headText = "Check"
		col->scriptLabel = "check"
		axlFormGridInsertCol(form "gridField" col)
	
		col->fieldType = 'TEXT
		col->colWidth = 18
		col->align = 'left
		col->headText = "View"
		col->scriptLabel = nil
		axlFormGridInsertCol(form "gridField" col)

		col->fieldType = 'STRING
		col->colWidth = 7
		col->align = 'left
		col->fieldLength = 8
		col->headText = "HotKey"
		col->scriptLabel = "hot_key"
		axlFormGridInsertCol(form "gridField" col)

		; fill grid
		i = 1
		axlFormGridInsertRows(form "gridField" 1 length(layerGroups))
		foreach( layerGroup layerGroups
			parentLabel = car(layerGroup)
			cell = axlFormGridNewCell()
			cell->row = i
			cell->col = 2
			cell->value = parentLabel
			axlFormSetField(form "gridField" cell)
			cell->col = 3
			cell->value = cadr(layerGroup)
			when( lhkIsFuncKeyExist(cell->value)
				cell->backColor = 'yellow
			)
			when( !lhkIsValidHotKey(cell->value)
				cell->backColor = 'red
			)
			when( (cell->value == nil || cell->value == "")
				cell->backColor = 'blue
			)
			axlFormSetField(form "gridField" cell)
			i++
		)
		axlFormGridEvents(form "gridField" '(cellselect change) )
		axlFormGridUpdate(form "gridField")

when( (axlIsDebug) println("lhkFillGrid: END"))
	);end-let
);end-defun

;
; Form Call Back
;
defun( lhkFormCallBack (form)
	let( (label parent parentLabel cell sFile)
when( (axlIsDebug) println("lhkFormCallBack"))
;printf("Id: %L; Image: %L\n" form->curValueInt axlFormTreeViewGetImages(form "treeField" form->curValueInt) )
;dad = form->curValueInt
		; exit by window's "x" button
		when(form->doneState == 3 lhkExitFromScript() )
		case( form->curField
			("treeField"
				label = axlFormTreeViewGetLabel(form "treeField" form->curValueInt)
				parent = car(axlFormTreeViewGetParents(form "treeField" form->curValueInt))
				parentLabel = axlFormTreeViewGetLabel(form "treeField" parent)
				; update if group name was changed
				when( lhkIsNameChanged(list(label form->curValueInt) _parentSelected)
					nil
					if( label == ""
						then 
							axlFormTreeViewChangeLabel(form "treeField" form->curValueInt car(_parentSelected) )
						else
							_lhkLayerGroups = lhkUpdateGroupName(label car(_parentSelected) _lhkLayerGroups)
							lhkFillGrid(form _lhkLayerGroups)
					)
				)
				; item selected, set editable or not
				if(!parent
					then ; top level
						axlFormTreeViewSet(form "treeField" 'TV_ENABLEEDITLABEL nil)
						axlFormBuildPopup(form "treeField" '( ("Add" "1") ("Remove" "2") ("Add/remove layer" "5")) )
						_parentSelected = list(label form->curValueInt)

					else ; sub level
						axlFormTreeViewSet(form "treeField" 'TV_NOEDITLABEL nil)
						axlFormBuildPopup(form "treeField" '( ("Add" "3") ("Remove" "4")) )
				)
				;popup menu
				when(label != form->curValue
					case( form->curValue
						("1" lhkAddLayerGroup(form "treeField") )
						("2" lhkRemoveLayerGroup(form "treeField" label) )
						("3" lhkAddLayer(form "treeField" parentLabel) )
						("4" lhkRemoveLayer(form "treeField" form->curValueInt parent) )
						("5" lhkAddLayer(form "treeField" label) )
					)
				)

			)
			("gridField"
;				printf( "value = %L (int %L)\t\t" form->curValue, form->curValueInt )
;				printf("%L:\t(%d,%d) %L\n", form->event, form->row, form->col, form->curValue)
				case(form->event
					('change
						; get group name
						cell = axlFormGridNewCell()
						cell->row = form->row
						cell->col = 2
						cell = axlFormGridGetCell(form "gridField" cell)
						parentLabel = cell->value
						when( form->col == 1
							if( form->curValue
								then lhkShowGroup(parentLabel t)
								else lhkShowGroup(parentLabel nil)
							)
						)
						when( form->col == 2
							; update alias for LayerGroup
							lhkUpdateHotKey(upperCase(form->curValue) parentLabel)
							; check and set color for alias cell
							cell->col = form->col
							cell = axlFormGridGetCell(form "gridField" cell)
							cell->backColor = nil
							when( lhkIsFuncKeyExist(cell->value)
								cell->backColor = 'yellow
							)
							when( !lhkIsValidHotKey(cell->value)
								cell->backColor = 'red
							)
							when( (cell->value == nil || cell->value == "")
								cell->backColor = 'blue
							)
							cell->value = upperCase(form->curValue)
							axlFormSetField(form "gridField" cell)
						)
					)
				)
			)
			("bnAddGroup"
				lhkAddLayerGroup(form "treeField")
			)
			("bnDefault" 
				_lhkLayerGroups = lhkLoadDefault()
				lhkFillTree(form _lhkLayerGroups)
				lhkFillGrid(form _lhkLayerGroups)
			)
			("bnImport" 
				sFile = axlDMFileBrowse(nil nil ?defaultName "default.lhk" ?title "Import Settings" 
						?optFilters "LayerHotKey settings(*.lhk)|*.lhk|" )
when( (axlIsDebug) println(sFile))
				when( sFile
					_lhkLayerGroups = lhkLoadListFromFile(car(axlDMFileParts(sFile)) caddr(axlDMFileParts(sFile)))
					when( _lhkLayerGroups
						printf("Hotkeys loaded.\n")
						lhkFillTree(form _lhkLayerGroups)
						lhkFillGrid(form _lhkLayerGroups)
					)
				)
			)
			("bnExport" 
				sFile = axlDMFileBrowse(nil t ?defaultName "default.lhk" ?title "Export Settings" 
						?optFilters "LayerHotKey settings(*.lhk)|*.lhk|" )
when( (axlIsDebug) println(sFile))
				when( sFile
					when( lhkSaveListToFile(car(axlDMFileParts(sFile)) caddr(axlDMFileParts(sFile)) _lhkLayerGroups)
						printf("Hotkeys exported.\n")
					)
				)
			)
			("bnOk"
when( (axlIsDebug) println("bnOk"))
				lhkStoreHotkeys(_lhkLayerGroups)
				lhkSetHotkeys(_lhkLayerGroups)
				_lhkOldLayerGroups = _lhkLayerGroups
;				axlFormClose(form)
				lhkExitFromScript()
			)
			("bnApply"
				lhkStoreHotkeys(_lhkLayerGroups)
				lhkSetHotkeys(_lhkLayerGroups)
				_lhkOldLayerGroups = _lhkLayerGroups
				lhkFillGrid(_lhkFormPtr _lhkLayerGroups) ; for refresh colors
				axlFormSetFieldEditable(_lhkFormPtr "bnApply" nil)
			)
			("bnCancel"
when( (axlIsDebug) println("bnCancel"))
;				axlFormClose(form)
				lhkExitFromScript()
			)
			("bnHelp" )
		);case
	);end-let
);end-defun

defun( lhkInitGlobalVariable ()
let( (layerGroups)
when( (axlIsDebug) println("lhkInitGlobalVariable"))
	_parentSelected = nil ; indicates that the group is selected in the tree
	_lhkFormPtr = nil	; pointer to main form
	_sclFormPtr = nil	; pointer to subclasses form
	_selectedGroup = nil	; 
	popupA = axlUIPopupDefine( nil
				(list
					(list "Done" 'lhkDone)
					(list "Cancel" 'lhkCancel)
				))
	_finish = nil ; for exit from main loop
	; storage for all old (saved) hotkeys and layers
	when(!boundp('_lhkOldLayerGroups) ; if script loaded manually
		layerGroups = lhkRestoreHotkeys()
		if( layerGroups
			then ; set hot keys
				_lhkOldLayerGroups = layerGroups
			else ; default Layer Group
				_lhkOldLayerGroups = lhkLoadDefault()
		)
	)
	_lhkLayerGroups = _lhkOldLayerGroups ; storage for current (not saved) hotkeys and layers
)
);end-defun

;
;
;
defun( lhkLoadDefault ()
	prog( (envPath result path)
when( (axlIsDebug) println("lhkLoadDefault"))
		envPath = axlGetVariableList("SITE_SKILLPATH")
		when(stringp(envPath) envPath = list(envPath) )
		
		; find for local path
		result = lhkLoadListFromFile("." "default.lhk")
		when( result return(result) )
		
		for( i 1 length(envPath)
			path = nthelem(i envPath)
			result = lhkLoadListFromFile( path "./layerHotKey/default.lhk" )
			when( result return(result) )
		);for

		return( 
			list(
				list( "TOP" "1" list("DRC ERROR CLASS/TOP" "ETCH/TOP" "PIN/TOP" "VIA CLASS/TOP") )
				list( "BOT" "2" list("DRC ERROR CLASS/BOTTOM" "ETCH/BOTTOM" "PIN/BOTTOM" "VIA CLASS/BOTTOM") )
				list( "PBT" "~S1" list("PACKAGE GEOMETRY/PLACE_BOUND_TOP" "PACKAGE GEOMETRY/DFA_BOUND_TOP") )
				list( "PBB" "~S2" list("PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM" "PACKAGE GEOMETRY/DFA_BOUND_BOTTOM") )
				list( "AST" "~1" list("REF DES/ASSEMBLY_TOP" "PACKAGE GEOMETRY/ASSEMBLY_TOP" "COMPONENT VALUE/ASSEMBLY_TOP") )
				list( "ASB" "~2" list("REF DES/ASSEMBLY_BOTTOM" "PACKAGE GEOMETRY/ASSEMBLY_BOTTOM" "COMPONENT VALUE/ASSEMBLY_BOTTOM") )
				list( "SST" nil list("COMPONENT VALUE/SILKSCREEN_TOP" "REF DES/SILKSCREEN_TOP" "PACKAGE GEOMETRY/SILKSCREEN_TOP" "BOARD GEOMETRY/SILKSCREEN_TOP") )
				list( "SSB" nil list("COMPONENT VALUE/SILKSCREEN_BOTTOM" "REF DES/SILKSCREEN_BOTTOM" "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" "BOARD GEOMETRY/SILKSCREEN_BOTTOM") )
				list( "SMT" "~A1" list("BOARD GEOMETRY/SOLDERMASK_TOP" "PACKAGE GEOMETRY/SOLDERMASK_TOP" "PIN/SOLDERMASK_TOP") )
				list( "SMB" "~A2" list("BOARD GEOMETRY/SOLDERMASK_BOTTOM" "PACKAGE GEOMETRY/SOLDERMASK_BOTTOM" "PIN/SOLDERMASK_BOTTOM") )
				list( "PIN" "7" list("PACKAGE GEOMETRY/PIN_NUMBER") )
				list( "DIM" nil list("BOARD GEOMETRY/DIMENSION" "PACKAGE GEOMETRY/DIMENSION") )
				list( "ASS" "8" list("BOARD GEOMETRY/ASSEMBLY_DETAIL" "BOARD GEOMETRY/ASSEMBLY_NOTES" ) )
				list( "BRD" "9" list("BOARD GEOMETRY/OUTLINE" "BOARD GEOMETRY/REVISION") )
			)
		)
	) ; prog
);end-defun

defun( lhkExitFromScript ()
	when( !_finish ; otherwise will be loop (axlCancelEnterFun - CANCEL event - lhkCancel - lhkExitFromScript - axlCancelEnterFun)
when( (axlIsDebug) println("lhkExitFromScript"))
		axlFormClose(_lhkFormPtr)
		_parentSelected = nil
		_lhkFormPtr = nil
		_sclFormPtr = nil
		_selectedGroup = nil
		popupA = nil
		_finish = t ; for exit from main loop, then var will be cleared
		axlCancelEnterFun()
	)
);end-defun



