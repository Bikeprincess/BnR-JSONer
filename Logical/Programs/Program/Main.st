
PROGRAM _INIT
	
	 xlist_index := ADR(vt_json_to_serialize);
END_PROGRAM

PROGRAM _CYCLIC
	IF scan THEN
		scan := FALSE;
		xlist_status := PV_xlist(prev_index := xlist_prev_index, index := xlist_index, PV_xList_struct := ADR(xlist_var_info));
	END_IF;
	
	PVitem_status := PV_item(ADR(PVitem_name), PVitem_index, ADR(PVitem_itemName));
	
	PVnininfo_status := PV_ninfo(ADR(PVnininfo_name), ADR(PVnininfo_typ), ADR(PVnininfo_len), ADR(PVnininfo_dim));
	//SYSLIB_IEC_TYPE_USER_DEFINED
	
	
	vt_status_serialize := JSON_serialize(pVarName := ADR('Program:vt_json_to_serialize'), pUserVarName := ADR('Test'), pOut := ADR(vt_json_serialized),sizeOut := SIZEOF(vt_json_serialized), size := vt_json_serialized_size); 
	vt_status_deserialize := JSON_deserialize();
	
	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

