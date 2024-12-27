(*Serialize*)

FUNCTION JSON_serialize : JSONer_Status_e (*JSON serializer*)
	VAR_INPUT
		pVarName : UDINT; (*Name of variable. In local variable use full path - [Program":"][Variable]...*)
		pUserVarName : UDINT := 0;
		pOut : UDINT;
		sizeOut : UDINT;
	END_VAR
	VAR_IN_OUT
		size : UDINT;
	END_VAR
	VAR
		freeBuffer : UDINT;
		bufferAdrNext : UDINT;
		xStatus : UINT;
		eStatus : JSONer_Status_e;
		dataTyp : UDINT;
		dataLen : UDINT;
		dataDim : UINT;
		varName : STRING[80];
	END_VAR
END_FUNCTION

FUNCTION JSON_var_serialize : JSONer_Status_e
	VAR_INPUT
		pFullVarName : UDINT;
		pVarName : UDINT := 0;
		varDimension : UDINT := 1;
		varType : USINT;
		firstMember : BOOL := FALSE;
	END_VAR
	VAR_IN_OUT
		pBuffer : UDINT;
		freeBuffer : UDINT;
	END_VAR
	VAR
		xStatus : UINT;
		eStatus : JSONer_Status_e;
		actDim : UDINT := 0;
		xStrLen : UDINT;
		allTypes : JSONer_types_t;
		strValConv : STRING[80];
		copyConvStr : BOOL;
		structFullNameMember : STRING[254];
		structActIndex : UINT;
		structItemName : STRING[32];
		structStrAdr : UDINT;
		structItemType : UDINT;
		structItemLen : UDINT;
		structItemDimension : UINT;
		structItemAdr : UDINT;
		structItemAdrLen : UDINT;
	END_VAR
END_FUNCTION
(*Deserialize*)

FUNCTION JSON_deserialize : JSONer_Status_e (*JSON deserializer*)
END_FUNCTION
