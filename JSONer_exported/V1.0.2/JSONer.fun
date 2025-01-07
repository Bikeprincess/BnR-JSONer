(*Serialize*)

FUNCTION JSON_serialize : JSONer_Status_e (*JSON serializer*)
	VAR_INPUT
		pVarName : UDINT; (*Name of variable. In local variable use full path - [Program":"][Variable]...*)
		pUserVarName : UDINT := 0; (*User name if input variable are array and not struct*)
		pOut : UDINT; (*Outout buffer - String or USINT[]*)
		sizeOut : UDINT; (*Maximum size of buffer - SIZEOF(pOut)*)
	END_VAR
	VAR_IN_OUT
		size : UDINT; (*Outout used size in bytes*)
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
		useQuoation : BOOL;
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
	VAR_INPUT
		pVarName : UDINT; (*Name of variable. In local variable use full path - [Program":"][Variable]...*)
		pUserVarName : UDINT := 0; (*User variable name in JSON for array input - set to 0, if input variable is struct*)
		pIn : UDINT; (*JSON string input - pointer*)
		sizeIn : UDINT; (*Size of input string - for not overloop*)
	END_VAR
	VAR
		xStatus : UDINT;
		eStatus : JSONer_Status_e;
		pActStr : UDINT;
		freeBuffer : UDINT;
		firstMemberArray : BOOL := FALSE;
	END_VAR
END_FUNCTION

FUNCTION JSON_var_deserialize : JSONer_Status_e
	VAR_INPUT
		pFullVarName : UDINT;
		isArray : BOOL;
	END_VAR
	VAR_IN_OUT
		pStart : UDINT;
		size : UDINT;
	END_VAR
	VAR
		xStatus : UINT;
		eStatus : JSONer_Status_e;
		allTypes : JSONer_types_t;
		varName : STRING[34];
		varFullName : STRING[254];
		varFullNameExt : STRING[254];
		pVarFullNameExt : UDINT;
		xTempLen : UDINT;
		xNameLen : UDINT;
		pNameStart : UDINT;
		pFullNameNxtAddr : UDINT;
		varType : UDINT;
		varLength : UDINT;
		varDimension : UINT;
		varAddr : UDINT;
		varSize : UDINT;
		varJsonStr : STRING[30];
		pValueStart : UDINT;
		i : UDINT;
	END_VAR
END_FUNCTION
(*Supporting functions*)

FUNCTION extractBool : UDINT
	VAR_IN_OUT
		pStart : UDINT;
		maxLen : UDINT; (*Limit the finding lenght*)
		out : BOOL;
	END_VAR
	VAR
		i : UDINT := 0;
		il : UDINT := 0;
		c : REFERENCE TO USINT;
		text : STRING[10];
	END_VAR
END_FUNCTION

FUNCTION findChar : UDINT
	VAR_INPUT
		cIn : USINT;
	END_VAR
	VAR_IN_OUT
		pStart : UDINT;
		maxLen : UDINT; (*Limit the finding lenght*)
	END_VAR
	VAR
		i : UDINT;
		c : REFERENCE TO USINT;
	END_VAR
END_FUNCTION

FUNCTION findCharOrEnd : UDINT
	VAR_INPUT
		cIn : USINT;
	END_VAR
	VAR_IN_OUT
		pStart : UDINT;
		maxLen : UDINT; (*Limit the finding lenght*)
	END_VAR
	VAR
		i : UDINT;
		c : REFERENCE TO USINT;
	END_VAR
END_FUNCTION

FUNCTION findQuoation : UDINT
	VAR_IN_OUT
		pStart : UDINT;
		maxLen : UDINT; (*Limit the finding lenght*)
	END_VAR
	VAR
		i : UDINT;
		c : REFERENCE TO USINT;
	END_VAR
END_FUNCTION

FUNCTION findNumeric : UDINT
	VAR_IN_OUT
		pStart : UDINT;
		maxLen : UDINT; (*Limit the finding lenght*)
	END_VAR
	VAR
		i : UDINT;
		c : REFERENCE TO USINT;
	END_VAR
END_FUNCTION

FUNCTION findNumericEnd : UDINT
	VAR_IN_OUT
		pStart : UDINT;
		maxLen : UDINT; (*Limit the finding lenght*)
	END_VAR
	VAR
		i : UDINT;
		c : REFERENCE TO USINT;
	END_VAR
END_FUNCTION

FUNCTION findWhitespace : UDINT
	VAR_IN_OUT
		pStart : UDINT;
		maxLen : UDINT; (*Limit the finding lenght*)
	END_VAR
	VAR
		i : UDINT;
		c : REFERENCE TO USINT;
	END_VAR
END_FUNCTION
