FUNCTION JSON_deserialize
	pActStr := pIn;
	freeBuffer := sizeIn;
	//================================================
	//Ignore first name member
	IF pUserVarName <> 0 THEN
		xStatus := findCharOrEnd(cIn := jsonAsciiColon, pStart := pActStr, maxLen := freeBuffer);
		IF xStatus > findError_OK THEN
			JSON_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
	END_IF;
	//================================================
	//Do Magic
	WHILE TRUE DO
		eStatus := JSON_var_deserialize(pFullVarName := pVarName, isArray := FALSE, pStart := pActStr, size := freeBuffer);
		IF eStatus = JSONer_End THEN
			JSON_deserialize := JSONer_Ok;
			RETURN;
		ELSIF eStatus <> JSONer_Ok THEN
			JSON_deserialize := eStatus;
			RETURN;
		END_IF;
	END_WHILE;
	//================================================
	JSON_deserialize := JSONer_Ok;
END_FUNCTION




FUNCTION JSON_var_deserialize
	//================================================
	// Copy basic var name
	brsmemset(ADR(varFullName),0, SIZEOF(varFullName));
	pFullNameNxtAddr := ADR(varFullName);
	pFullNameNxtAddr := brsstrcpy(pFullNameNxtAddr, pFullVarName);
	//================================================
	// Find var name - not used, if it's array -> for redirecting var types
	IF NOT isArray THEN
		xTempLen := findQuoation(pStart := pStart, maxLen := size);//Find start of name - by "
		IF xTempLen > findError_OK THEN
			JSON_var_deserialize := JSONer_End;
			RETURN;
		END_IF;	
		pNameStart := pStart;
		xNameLen := findQuoation(pStart := pStart, maxLen := size);//Find end of name by "
		IF xNameLen > 32 THEN //findError_OK - Name can't be longer than 32 characters
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		brsmemset(ADR(varName),0, SIZEOF(varName));
		brsmemcpy(ADR(varName), pNameStart, xNameLen);
		pFullNameNxtAddr := brsstrcpy(pFullNameNxtAddr, ADR('.'));
		pFullNameNxtAddr := brsstrcpy(pFullNameNxtAddr, ADR(varName));
	END_IF;
	//================================================
	//Find variable info in PVs
	xStatus := PV_ninfo(pv_name := ADR(varFullName), data_typ_p := ADR(varType), data_len_p := ADR(varLength), dimension_p := ADR(varDimension));
	IF xStatus <> 0 THEN
		JSON_var_deserialize := JSONer_VarNotFound;
		RETURN;
	END_IF;
	xStatus := PV_xgetadr(ADR(varFullName), ADR(varAddr), ADR(varSize));
	IF xStatus <> 0 THEN
		JSON_var_deserialize := JSONer_Error;
		RETURN;
	END_IF;
	//================================================
	//Extract value and decode
	
	IF varType = SYSLIB_IEC_TYPE_USER_DEFINED THEN //Structure
		// Remove {
		xTempLen := findChar(cIn := jsonAsciiLB, pStart := pStart, maxLen := size);
		IF xTempLen > findError_OK THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		// Find all variables inside
		FOR i := 0 TO (varDimension - 1) BY 1 DO
			eStatus := JSON_var_deserialize(pFullVarName := ADR(varFullName), isArray := FALSE, pStart := pStart, size := size);
			IF eStatus = JSONer_End OR eStatus = JSONer_VarNotFound THEN
				EXIT;
			ELSIF eStatus <> JSONer_Ok THEN
				JSON_var_deserialize := eStatus;
				RETURN;
			END_IF;			
		END_FOR;
		
	ELSIF varType = SYSLIB_IEC_TYPE_USER_DEFINED_2 OR varDimension > 1 THEN //Array
		FOR i := 0 TO (varDimension - 1) BY 1 DO
			pVarFullNameExt := ADR(varFullNameExt);
			pVarFullNameExt := brsstrcpy(pVarFullNameExt, ADR(varFullName));
			pVarFullNameExt := brsstrcpy(pVarFullNameExt, ADR('['));
			varJsonStr := UDINT_TO_STRING(i);
			pVarFullNameExt := brsstrcpy(pVarFullNameExt, ADR(varJsonStr));
			pVarFullNameExt := brsstrcpy(pVarFullNameExt, ADR(']'));
			eStatus := JSON_var_deserialize(pFullVarName := ADR(varFullNameExt), isArray := TRUE, pStart := pStart, size := size);
			IF eStatus = JSONer_End OR eStatus = JSONer_VarNotFound THEN
				EXIT;
			ELSIF eStatus <> JSONer_Ok THEN
				JSON_var_deserialize := eStatus;
				RETURN;
			END_IF;			
		END_FOR;
		
	ELSIF varType = SYSLIB_IEC_TYPE_BOOL THEN
		xTempLen := extractBool(pStart := pStart, maxLen := size, out := allTypes.tBool);
		IF xTempLen > findError_OK THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		brsmemcpy(varAddr, ADR(allTypes.tBool), varSize);
				
	ELSIF varType = SYSLIB_IEC_TYPE_SINT THEN
		xTempLen := findNumeric(pStart := pStart, maxLen := size);
		IF xTempLen > findError_OK THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		pValueStart := pStart;
		xTempLen := findNumericEnd(pStart := pStart, maxLen := size);
		IF (xTempLen + 1) > SIZEOF(varJsonStr) THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		brsmemset(ADR(varJsonStr),0, SIZEOF(varJsonStr));
		brsmemcpy(ADR(varJsonStr), pValueStart, xTempLen);
		allTypes.tSint := STRING_TO_SINT(varJsonStr);
		brsmemcpy(varAddr, ADR(allTypes.tSint), varSize);
		
	ELSIF varType = SYSLIB_IEC_TYPE_INT THEN
		xTempLen := findNumeric(pStart := pStart, maxLen := size);
		IF xTempLen > findError_OK THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		pValueStart := pStart;
		xTempLen := findNumericEnd(pStart := pStart, maxLen := size);
		IF (xTempLen + 1) > SIZEOF(varJsonStr) THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		brsmemset(ADR(varJsonStr),0, SIZEOF(varJsonStr));
		brsmemcpy(ADR(varJsonStr), pValueStart, xTempLen);
		allTypes.tInt := STRING_TO_INT(varJsonStr);
		brsmemcpy(varAddr, ADR(allTypes.tInt), varSize);
		
	ELSIF varType = SYSLIB_IEC_TYPE_DINT THEN
		xTempLen := findNumeric(pStart := pStart, maxLen := size);
		IF xTempLen > findError_OK THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		pValueStart := pStart;
		xTempLen := findNumericEnd(pStart := pStart, maxLen := size);
		IF (xTempLen + 1) > SIZEOF(varJsonStr) THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		brsmemset(ADR(varJsonStr),0, SIZEOF(varJsonStr));
		brsmemcpy(ADR(varJsonStr), pValueStart, xTempLen);
		allTypes.tDint := STRING_TO_DINT(varJsonStr);
		brsmemcpy(varAddr, ADR(allTypes.tDint), varSize);
		
	ELSIF varType = SYSLIB_IEC_TYPE_USINT THEN
		xTempLen := findNumeric(pStart := pStart, maxLen := size);
		IF xTempLen > findError_OK THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		pValueStart := pStart;
		xTempLen := findNumericEnd(pStart := pStart, maxLen := size);
		IF (xTempLen + 1) > SIZEOF(varJsonStr) THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		brsmemset(ADR(varJsonStr),0, SIZEOF(varJsonStr));
		brsmemcpy(ADR(varJsonStr), pValueStart, xTempLen);
		allTypes.tUsint := STRING_TO_USINT(varJsonStr);
		brsmemcpy(varAddr, ADR(allTypes.tUsint), varSize);
		
	ELSIF varType = SYSLIB_IEC_TYPE_UINT THEN
		xTempLen := findNumeric(pStart := pStart, maxLen := size);
		IF xTempLen > findError_OK THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		pValueStart := pStart;
		xTempLen := findNumericEnd(pStart := pStart, maxLen := size);
		IF (xTempLen + 1) > SIZEOF(varJsonStr) THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		brsmemset(ADR(varJsonStr),0, SIZEOF(varJsonStr));
		brsmemcpy(ADR(varJsonStr), pValueStart, xTempLen);
		allTypes.tUint := STRING_TO_UINT(varJsonStr);
		brsmemcpy(varAddr, ADR(allTypes.tUint), varSize);
		
	ELSIF varType = SYSLIB_IEC_TYPE_UDINT THEN
		xTempLen := findNumeric(pStart := pStart, maxLen := size);
		IF xTempLen > findError_OK THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		pValueStart := pStart;
		xTempLen := findNumericEnd(pStart := pStart, maxLen := size);
		IF (xTempLen + 1) > SIZEOF(varJsonStr) THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		brsmemset(ADR(varJsonStr),0, SIZEOF(varJsonStr));
		brsmemcpy(ADR(varJsonStr), pValueStart, xTempLen);
		allTypes.tUdint := STRING_TO_UDINT(varJsonStr);
		brsmemcpy(varAddr, ADR(allTypes.tUdint), varSize);
		
	ELSIF varType = SYSLIB_IEC_TYPE_REAL THEN
		xTempLen := findNumeric(pStart := pStart, maxLen := size);
		IF xTempLen > findError_OK THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		pValueStart := pStart;
		xTempLen := findNumericEnd(pStart := pStart, maxLen := size);
		IF (xTempLen + 1) > SIZEOF(varJsonStr) THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		brsmemset(ADR(varJsonStr),0, SIZEOF(varJsonStr));
		brsmemcpy(ADR(varJsonStr), pValueStart, xTempLen);
		allTypes.tReal := STRING_TO_REAL(varJsonStr);
		brsmemcpy(varAddr, ADR(allTypes.tReal), varSize);
		
	ELSIF varType = SYSLIB_IEC_TYPE_STRING THEN
		xTempLen := findQuoation(pStart := pStart, maxLen := size);
		IF xTempLen > findError_OK THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		pValueStart := pStart;
		xTempLen := findQuoation(pStart := pStart, maxLen := size);
		IF (xTempLen + 1) > varSize THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		brsmemset(varAddr,0, varSize);
		brsmemcpy(varAddr, pValueStart, xTempLen);
				
	ELSIF varType = SYSLIB_IEC_TYPE_DATE_AND_TIME THEN
		xTempLen := findQuoation(pStart := pStart, maxLen := size);
		IF xTempLen > findError_OK THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		pValueStart := pStart;
		xTempLen := findQuoation(pStart := pStart, maxLen := size);
		IF (xTempLen + 1) > SIZEOF(varJsonStr) THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		brsmemset(ADR(varJsonStr),0, SIZEOF(varJsonStr));
		brsmemcpy(ADR(varJsonStr), pValueStart, xTempLen);
		allTypes.tDt := STRING_TO_DT(varJsonStr);
		brsmemcpy(varAddr, ADR(allTypes.tDt), varSize);
		
	ELSIF varType = SYSLIB_IEC_TYPE_TIME THEN
		xTempLen := findQuoation(pStart := pStart, maxLen := size);
		IF xTempLen > findError_OK THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		pValueStart := pStart;
		xTempLen := findQuoation(pStart := pStart, maxLen := size);
		IF (xTempLen + 1) > SIZEOF(varJsonStr) THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		brsmemset(ADR(varJsonStr),0, SIZEOF(varJsonStr));
		brsmemcpy(ADR(varJsonStr), pValueStart, xTempLen);
		allTypes.tTime := STRING_TO_TIME(varJsonStr);
		brsmemcpy(varAddr, ADR(allTypes.tTime), varSize);
		
	ELSIF varType = SYSLIB_IEC_TYPE_DATE THEN
		xTempLen := findQuoation(pStart := pStart, maxLen := size);
		IF xTempLen > findError_OK THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		pValueStart := pStart;
		xTempLen := findQuoation(pStart := pStart, maxLen := size);
		IF (xTempLen + 1) > SIZEOF(varJsonStr) THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		brsmemset(ADR(varJsonStr),0, SIZEOF(varJsonStr));
		brsmemcpy(ADR(varJsonStr), pValueStart, xTempLen);
		allTypes.tDate := STRING_TO_DATE(varJsonStr);
		brsmemcpy(varAddr, ADR(allTypes.tDate), varSize);
		
	ELSIF varType = SYSLIB_IEC_TYPE_LREAL THEN
		xTempLen := findNumeric(pStart := pStart, maxLen := size);
		IF xTempLen > findError_OK THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		pValueStart := pStart;
		xTempLen := findNumericEnd(pStart := pStart, maxLen := size);
		IF (xTempLen + 1) > SIZEOF(varJsonStr) THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		brsmemset(ADR(varJsonStr),0, SIZEOF(varJsonStr));
		brsmemcpy(ADR(varJsonStr), pValueStart, xTempLen);
		allTypes.tLreal := STRING_TO_LREAL(varJsonStr);
		brsmemcpy(varAddr, ADR(allTypes.tLreal), varSize);
		
	ELSIF varType = SYSLIB_IEC_TYPE_TIME_OF_DAY THEN
		xTempLen := findQuoation(pStart := pStart, maxLen := size);
		IF xTempLen > findError_OK THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		pValueStart := pStart;
		xTempLen := findQuoation(pStart := pStart, maxLen := size);
		IF (xTempLen + 1) > SIZEOF(varJsonStr) THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		brsmemset(ADR(varJsonStr),0, SIZEOF(varJsonStr));
		brsmemcpy(ADR(varJsonStr), pValueStart, xTempLen);
		allTypes.tTod := STRING_TO_TOD(varJsonStr);
		brsmemcpy(varAddr, ADR(allTypes.tTod), varSize);
		
	ELSIF varType = SYSLIB_IEC_TYPE_BYTE THEN
		xTempLen := findNumeric(pStart := pStart, maxLen := size);
		IF xTempLen > findError_OK THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		pValueStart := pStart;
		xTempLen := findNumericEnd(pStart := pStart, maxLen := size);
		IF (xTempLen + 1) > SIZEOF(varJsonStr) THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		brsmemset(ADR(varJsonStr),0, SIZEOF(varJsonStr));
		brsmemcpy(ADR(varJsonStr), pValueStart, xTempLen);
		allTypes.tByte := STRING_TO_BYTE(varJsonStr);
		brsmemcpy(varAddr, ADR(allTypes.tByte), varSize);
		
	ELSIF varType = SYSLIB_IEC_TYPE_WORD THEN
		xTempLen := findNumeric(pStart := pStart, maxLen := size);
		IF xTempLen > findError_OK THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		pValueStart := pStart;
		xTempLen := findNumericEnd(pStart := pStart, maxLen := size);
		IF (xTempLen + 1) > SIZEOF(varJsonStr) THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		brsmemset(ADR(varJsonStr),0, SIZEOF(varJsonStr));
		brsmemcpy(ADR(varJsonStr), pValueStart, xTempLen);
		allTypes.tWord := STRING_TO_WORD(varJsonStr);
		brsmemcpy(varAddr, ADR(allTypes.tWord), varSize);
		
	ELSIF varType = SYSLIB_IEC_TYPE_DWORD THEN
		xTempLen := findNumeric(pStart := pStart, maxLen := size);
		IF xTempLen > findError_OK THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		pValueStart := pStart;
		xTempLen := findNumericEnd(pStart := pStart, maxLen := size);
		IF (xTempLen + 1) > SIZEOF(varJsonStr) THEN
			JSON_var_deserialize := JSONer_InputError;
			RETURN;
		END_IF;
		brsmemset(ADR(varJsonStr),0, SIZEOF(varJsonStr));
		brsmemcpy(ADR(varJsonStr), pValueStart, xTempLen);
		allTypes.tDword := STRING_TO_DWORD(varJsonStr);
		brsmemcpy(varAddr, ADR(allTypes.tDword), varSize);
		
	ELSIF varType = SYSLIB_IEC_TYPE_WSTRING THEN
		
	ELSE
		JSON_var_deserialize := JSONer_BadVarType;
		RETURN;
	END_IF;
	
	//================================================
	// Check the end
	xTempLen := findCharOrEnd(cIn := jsonAsciiComma, pStart := pStart, maxLen := size);
	IF xTempLen = findError_EndExceed THEN
		JSON_var_deserialize := JSONer_End;
	ELSIF xTempLen > findError_OK THEN
		JSON_var_deserialize := JSONer_InputError;
		RETURN;
	END_IF;
	
	JSON_var_deserialize := JSONer_Ok;
END_FUNCTION


















