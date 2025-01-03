
PROGRAM _INIT
	
END_PROGRAM

PROGRAM _CYCLIC
	
	vt_status_serialize := JSON_serialize(pVarName := ADR('Program:vt_json_to_serialize'), pUserVarName := ADR('Test'), pOut := ADR(vt_json_serialized),sizeOut := SIZEOF(vt_json_serialized), size := vt_json_serialized_size);
	
	vt_status_deserialize := JSON_deserialize(pVarName := ADR('Program:vt_json_deserialized'), pUserVarName := ADR('Test'), pIn := ADR(vt_json_serialized), sizeIn := SIZEOF(vt_json_serialized));
	
END_PROGRAM