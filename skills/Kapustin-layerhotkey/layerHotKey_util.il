;
;	$Source$ $Revision$ $Branch$ $Rev$
;	$Author$ $Date$
;
;	Files required:
;

LAYER_HOT_KEY_UTIL_FILE = t
;
;
;
defun( lhkIsItemInList (item items)
	let( (x)
when( (axlIsDebug) println("lhkIsItemInList"))
		if( exists(x items (x == item))
			then t
			else nil
		)
	);end-let
);end-defun

;
;
;
defun( lhkAddLayerToGroup (layer layerGroup)
	let( (parent als layers)
when( (axlIsDebug) println("lhkAddLayerToGroup"))
		parent = car(layerGroup)
		als = cadr(layerGroup)
		layers = caddr(layerGroup)
		layerGroup = cons(layer layers)
		layerGroup = list(parent als layerGroup)
	);end-let
);end-defun

;
;
;
defun( lhkRemoveLayerFromGroup (layer layerGroup)
	let( (parent als layers)
when( (axlIsDebug) println("lhkRemoveLayerFromGroup"))
		parent = car(layerGroup)
		als = cadr(layerGroup)
		layers = caddr(layerGroup)
		layerGroup = remove(layer layers)
		layerGroup = list(parent als layerGroup)
	);end-let
);end-defun

;
;
;
defun( lhkReplaceLayerGroup (pLayerGroup pLayerGroups)
	let( (layerGroup newLayerGroup newLayerGroups)
when( (axlIsDebug) println("lhkReplaceLayerGroup"))
		foreach(layerGroup pLayerGroups
			if( ( car(layerGroup)==car(pLayerGroup) )
				then newLayerGroup = pLayerGroup
				else newLayerGroup = layerGroup
			)
			newLayerGroups = cons(newLayerGroup newLayerGroups)
		)
		reverse(newLayerGroups)
	);end-let
);end-defun

;
;
;
defun( lhkIsNameChanged (new old)
	let( (result)
when( (axlIsDebug) println("lhkIsNameChanged"))
		when(old
			when( (cadr(old)==cadr(new) && car(old)!=car(new))
				result = t
when( (axlIsDebug) println("Name was changed")) ;
			)
		)
		result
	);end-let
);end-defun

;
;
;
defun( lhkUpdateGroupName (newName oldName layerGroups)
	let( (newLayerGroup layerGroup newLayerGroups)
when( (axlIsDebug) println("lhkUpdateGroupName"))
		foreach(layerGroup layerGroups
			if( car(layerGroup)==oldName
				then newLayerGroup = rplaca( layerGroup newName )
				else newLayerGroup = layerGroup
			)
			newLayerGroups = cons(newLayerGroup newLayerGroups)
		)
		reverse(newLayerGroups)
	);end-let
);end-defun

;
;-------------------Classes form ------------------
;
defun( lhkInitClassForm (layerGroup)
	let( (treeList itemId)
when( (axlIsDebug) println("lhkInitClassForm"))
		classesList = axlGetParam("paramLayerGroup")->groupMembers
		when(!_sclFormPtr
			_sclFormPtr = axlFormCreate( '_sclFormPtr LAYER_HOT_KEY_SCL_FORM '(c canvas msglines 0) 'lhkClassCallBack t)
			;		_sclFormPtr = axlFormCreate( (gensym) "scl_browser.form" '(c canvas msglines 0) 'lhkClassCallBack t)
		)
		; Name of View to form header
		axlFormTitle(_sclFormPtr strcat("View: " car(layerGroup)))
		; tree view
		foreach( parentLabel classesList
			parentId = axlFormTreeViewAddItem(_sclFormPtr "treeList" parentLabel nil nil)
			subclassesList = axlSubclasses(parentLabel)
			foreach( itemLabel subclassesList
				if(lhkIsItemInList(strcat(parentLabel "/" itemLabel) caddr(layerGroup))
				then
					itemId = axlFormTreeViewAddItem(_sclFormPtr "treeList" itemLabel parentId nil 'TVSELECT_2STATE)
					axlFormTreeViewSetSelectState(_sclFormPtr "treeList" itemId t)
					axlFormTreeViewSet(_sclFormPtr "treeList" 'TV_EXPAND parentId)
				else
					itemId = axlFormTreeViewAddItem(_sclFormPtr "treeList" itemLabel parentId nil 'TVSELECT_2STATE)
				)
			)
		)
		axlFormTreeViewSet(_sclFormPtr "treeList" 'TV_NOEDITLABEL nil) ; disable edit tree names
		axlFormDisplay(_sclFormPtr) ;display form
		axlUIWBlock(_sclFormPtr) ;block focus
	);end-let
);end-defun

;
; Classes Form Call Back
;
defun( lhkClassCallBack (form)
	let( (label state parent parentLabel)
when( (axlIsDebug) println("lhkClassCallBack"))
		case( form->curField
			("DONE"
				axlFormClose(form)
				_lhkLayerGroups = lhkReplaceLayerGroup(_selectedGroup  _lhkLayerGroups)
				lhkFillTree(_lhkFormPtr _lhkLayerGroups list(car(_selectedGroup)))
				lhkFillGrid(_lhkFormPtr _lhkLayerGroups)
				axlFormSetFieldEditable(_lhkFormPtr "bnApply" t)
			)
			("CANCEL"
				axlFormClose(form)
				_selectedGroup = nil
			)
			("treeList"
				when(form->curValue == ""
					label = axlFormTreeViewGetLabel(form "treeList" form->curValueInt)
					state = axlFormTreeViewGetSelectState(form "treeList" form->curValueInt)
					parent = car(axlFormTreeViewGetParents(form "treeList" form->curValueInt))
					parentLabel = axlFormTreeViewGetLabel(form "treeList" parent)
					if(state==1
						then _selectedGroup = lhkAddLayerToGroup(strcat(parentLabel "/" label) _selectedGroup)
						else _selectedGroup = lhkRemoveLayerFromGroup(strcat(parentLabel "/" label) _selectedGroup)
					)
				)
			)
			(t axlFormClose(form))
		);case
	);let
);end-defun

;
;
; 
defun( lhkIsValidHotKey (pHotKey)
	let( (result)
		when(pHotKey
			result = pcreExecute( _lhkRegExp upperCase(pHotKey) )
		)
		result
	);let
);end-defun

;
;
;
defun( lhkIsFuncKeyExist (pHotKey)
	prog( (funckey funckeys lAlias aliases group)
when( (axlIsDebug) println("lhkIsFuncKeyExist"))
		when( (!pHotKey || pHotKey=="")
			return(nil)
		)
		aliases = axlGetAlias(nil)
		when( exists(lAlias aliases (lAlias == pHotKey))
			return(t)
		)			
		funckeys = axlGetFunckey(nil)
		foreach(funckey funckeys
			when(funckey==pHotKey
				; check for hotkey is assigned to some Layer Group
				foreach( group _lhkOldLayerGroups
					when( pHotKey == cadr(group)
						return(nil)
					)					
				)
				return(t)
			)
		)
		return(nil)
	);prog
);end-defun

;
;
; TODO: Use this function
defun( lhkIsAliasExist (pAlias)
	prog( (funckeys funckey)
when( (axlIsDebug) println("lhkIsAliasExist"))
		when( (!pAlias || pAlias=="")
			; name of Layer Group cannot be a nil or empty
			error("lhkIsAliasExist" "argument is nil or empty")
		)
		funckeys = axlGetFunckey(nil)
		when( exists(funckey funckeys (funckey == pAlias))
			return(t)
		)

		aliases = axlGetAlias(nil)
		foreach(lAlias aliases
			when(lAlias==pAlias
				; check for alias is assigned to some Layer Group
				foreach( group _lhkOldLayerGroups
					when( pAlias == car(group)
						return(nil)
					)					
				)
				return(t)
			)
		)
		return(nil)
	);prog
);end-defun


