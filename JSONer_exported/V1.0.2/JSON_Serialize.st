FUNCTION JSON_serialize
	freeBuffer := sizeOut;
	brsmemset(pOut, 0, sizeOut);
	//================================================
	//Get variable name and info
	IF pVarName = 0 THEN
		JSON_serialize := JSONer_InputError;
		RETURN;
	END_IF;
	brsstrcpy(ADR(varName), pVarName);
	xStatus := PV_ninfo(pv_name := ADR(varName), data_typ_p := ADR(dataTyp), data_len_p := ADR(dataLen), dimension_p := ADR(dataDim));
	IF xStatus <> 0 THEN
		JSON_serialize := JSONer_VarNotFound;
		RETURN;
	END_IF;
	//================================================
	//Start frame
	bufferAdrNext := pOut;
	bufferAdrNext := brsstrcpy(bufferAdrNext, ADR('{'));
	freeBuffer := freeBuffer - 2;
	//================================================
	//Start serializing
	//listTyp.data_typ listTyp.dimension
	eStatus := JSON_var_serialize(pFullVarName := ADR(varName), pVarName := pUserVarName, varDimension := UINT_TO_UDINT(dataDim), varType := UDINT_TO_USINT(dataTyp), firstMember := TRUE, pBuffer := bufferAdrNext, freeBuffer := freeBuffer);
	IF eStatus <> JSONer_Ok THEN
		JSON_serialize := eStatus;
		RETURN;
	END_IF;
	//================================================
	//End frame
	IF freeBuffer > 2 THEN
		bufferAdrNext := brsstrcpy(bufferAdrNext, ADR('}'));
		freeBuffer := freeBuffer - 2;
	ELSE
		JSON_serialize := JSONer_SmallBuffer;
		RETURN;
	END_IF;
	size := sizeOut - freeBuffer;
	JSON_serialize := JSONer_Ok;
END_FUNCTION

//0 for structures and 15 for array of structures

FUNCTION JSON_var_serialize
	JSON_var_serialize := JSONer_Ok;
	//================================================
	//Value name
	IF varType >= 0 AND varType <= 21 AND varType <> 10 AND varType <> 20 THEN
		IF NOT ((varType = 0 AND firstMember = TRUE)) THEN //Pokud není struktura samostatná pro výpis -  AND varDimension < 2
			xStrLen := 6 + brsstrlen(pVarName);
			IF freeBuffer > xStrLen THEN
				pBuffer := brsstrcpy(pBuffer, ADR('"'));
				pBuffer := brsstrcpy(pBuffer, pVarName);
				pBuffer := brsstrcpy(pBuffer, ADR('":'));
				freeBuffer := freeBuffer - xStrLen;
			ELSE
				JSON_var_serialize := JSONer_SmallBuffer;
				RETURN;
			END_IF;
		END_IF;
	ELSE
		JSON_var_serialize := JSONer_BadVarType;
		RETURN;
	END_IF;
	//================================================
	//Start array
	IF varDimension > 1 AND NOT (varType = 0) THEN
		actDim := varDimension;
		IF freeBuffer > 2 THEN
			pBuffer := brsstrcpy(pBuffer, ADR('['));
			freeBuffer := freeBuffer - 2;
		ELSE
			JSON_var_serialize := JSONer_SmallBuffer;
			RETURN;
		END_IF;
	ELSE
		actDim := 1;
	END_IF;
	//================================================
	//Value serialize
	WHILE actDim > 0 DO
		copyConvStr := FALSE;
		//================================================
		structStrAdr := ADR(structFullNameMember);
		structStrAdr := brsstrcpy(structStrAdr, pFullVarName);
		IF varDimension > 1 AND NOT (varType = 0) THEN
			structStrAdr := brsstrcpy(structStrAdr, ADR('['));
			structItemName := UDINT_TO_STRING(varDimension - actDim);
			structStrAdr := brsstrcpy(structStrAdr, ADR(structItemName));
			structStrAdr := brsstrcpy(structStrAdr, ADR(']'));
			firstMember := FALSE;//
		END_IF;
		//================================================
		xStatus := PV_xgetadr(ADR(structFullNameMember), ADR(structItemAdr), ADR(structItemAdrLen));
		IF xStatus <> 0 THEN
			JSON_var_serialize := JSONer_Error;
			RETURN;
		END_IF;
		//================================================
		useQuoation := FALSE;
		copyConvStr := FALSE;
		IF varType = SYSLIB_IEC_TYPE_USER_DEFINED OR varType = SYSLIB_IEC_TYPE_USER_DEFINED_2 THEN
			//================================================
			//Init Object
			IF NOT firstMember THEN
				IF freeBuffer > 2 THEN
					pBuffer := brsstrcpy(pBuffer, ADR('{'));
					freeBuffer := freeBuffer - 2;
				ELSE
					JSON_var_serialize := JSONer_SmallBuffer;
					RETURN;
				END_IF;
			END_IF;
			//================================================
			//Call structure members
			//structStrAdr := ADR(structFullNameMember);
			//structStrAdr := brsstrcpy(structStrAdr, pFullVarName);
			structStrAdr := brsstrcpy(structStrAdr, ADR('.'));
			structActIndex := 0;
			WHILE TRUE DO
				xStatus := PV_item(pv_name := pFullVarName, index := structActIndex, ADR(structItemName));
				IF xStatus = 0 AND structActIndex < 100 THEN
					brsstrcpy(structStrAdr, ADR(structItemName));
					xStatus := PV_ninfo(pv_name := ADR(structFullNameMember), data_typ_p := ADR(structItemType), data_len_p := ADR(structItemLen), dimension_p := ADR(structItemDimension));
					IF xStatus <> 0 THEN
						JSON_var_serialize := JSONer_Error;
						RETURN;
					END_IF;
					IF structActIndex > 0 THEN
						IF freeBuffer > 2 THEN
							pBuffer := brsstrcpy(pBuffer, ADR(','));
							freeBuffer := freeBuffer - 2;
						ELSE
							JSON_var_serialize := JSONer_SmallBuffer;
							RETURN;
						END_IF;
					END_IF;
					eStatus := JSON_var_serialize(pFullVarName := ADR(structFullNameMember), pVarName := ADR(structItemName), varDimension := structItemDimension, varType := UDINT_TO_USINT(structItemType), firstMember := FALSE, pBuffer := pBuffer, freeBuffer := freeBuffer);
					IF eStatus <> JSONer_Ok THEN
						JSON_var_serialize := eStatus;
						RETURN;
					END_IF;
				ELSE
					EXIT;
				END_IF;
				structActIndex := structActIndex + 1;
			END_WHILE;

			//================================================
			//End Object
			IF NOT firstMember THEN
				IF freeBuffer > 2 THEN
					pBuffer := brsstrcpy(pBuffer, ADR('}'));
					freeBuffer := freeBuffer - 2;
				ELSE
					JSON_var_serialize := JSONer_SmallBuffer;
					RETURN;
				END_IF;
			END_IF;
			//================================================
		ELSIF varType = SYSLIB_IEC_TYPE_BOOL THEN
			brsmemcpy(ADR(allTypes.tBool), structItemAdr, structItemAdrLen);
			IF allTypes.tBool THEN
				brsstrcpy(ADR(strValConv), ADR('true'));
			ELSE
				brsstrcpy(ADR(strValConv), ADR('false'));
			END_IF;
			copyConvStr := TRUE;
			
		ELSIF varType = SYSLIB_IEC_TYPE_SINT THEN
			brsmemcpy(ADR(allTypes.tSint), structItemAdr, structItemAdrLen);
			strValConv := SINT_TO_STRING(allTypes.tSint);
			copyConvStr := TRUE;
		
		ELSIF varType = SYSLIB_IEC_TYPE_INT THEN
			brsmemcpy(ADR(allTypes.tInt), structItemAdr, structItemAdrLen);
			strValConv := INT_TO_STRING(allTypes.tInt);
			copyConvStr := TRUE;
		
		ELSIF varType = SYSLIB_IEC_TYPE_DINT THEN
			brsmemcpy(ADR(allTypes.tDint), structItemAdr, structItemAdrLen);
			strValConv := DINT_TO_STRING(allTypes.tDint);
			copyConvStr := TRUE;
		
		ELSIF varType = SYSLIB_IEC_TYPE_USINT THEN
			brsmemcpy(ADR(allTypes.tUsint), structItemAdr, structItemAdrLen);
			strValConv := USINT_TO_STRING(allTypes.tUsint);
			copyConvStr := TRUE;
		
		ELSIF varType = SYSLIB_IEC_TYPE_UINT THEN
			brsmemcpy(ADR(allTypes.tUint), structItemAdr, structItemAdrLen);
			strValConv := UINT_TO_STRING(allTypes.tUint);
			copyConvStr := TRUE;
		
		ELSIF varType = SYSLIB_IEC_TYPE_UDINT THEN
			brsmemcpy(ADR(allTypes.tUdint), structItemAdr, structItemAdrLen);
			strValConv := UDINT_TO_STRING(allTypes.tUdint);
			copyConvStr := TRUE;
			useQuoation := FALSE;
		
		ELSIF varType = SYSLIB_IEC_TYPE_REAL THEN
			brsmemcpy(ADR(allTypes.tReal), structItemAdr, structItemAdrLen);
			strValConv := REAL_TO_STRING(allTypes.tReal);
			copyConvStr := TRUE;
		
		ELSIF varType = SYSLIB_IEC_TYPE_STRING THEN//This is can be much bigger than internal variable
			xStrLen := 2 + brsstrlen(ADR(structItemAdr));
			IF freeBuffer > xStrLen THEN
				pBuffer := brsstrcpy(pBuffer, ADR('"'));
				pBuffer := brsstrcpy(pBuffer, structItemAdr);
				pBuffer := brsstrcpy(pBuffer, ADR('"'));
				freeBuffer := freeBuffer - xStrLen;
			ELSE
				JSON_var_serialize := JSONer_SmallBuffer;
				RETURN;
			END_IF;
		
		ELSIF varType = SYSLIB_IEC_TYPE_DATE_AND_TIME THEN
			brsmemcpy(ADR(allTypes.tDt), structItemAdr, structItemAdrLen);
			strValConv := DT_TO_STRING(allTypes.tDt);
			copyConvStr := TRUE;
			useQuoation := TRUE;
		
		ELSIF varType = SYSLIB_IEC_TYPE_TIME THEN
			brsmemcpy(ADR(allTypes.tTime), structItemAdr, structItemAdrLen);
			strValConv := TIME_TO_STRING(allTypes.tTime);
			copyConvStr := TRUE;
			useQuoation := TRUE;
		
		ELSIF varType = SYSLIB_IEC_TYPE_DATE THEN
			brsmemcpy(ADR(allTypes.tDate), structItemAdr, structItemAdrLen);
			strValConv := DATE_TO_STRING(allTypes.tDate);
			copyConvStr := TRUE;
			useQuoation := TRUE;
		
		ELSIF varType = SYSLIB_IEC_TYPE_LREAL THEN
			brsmemcpy(ADR(allTypes.tLreal), structItemAdr, structItemAdrLen);
			strValConv := LREAL_TO_STRING(allTypes.tLreal);
			copyConvStr := TRUE;
		
		ELSIF varType = SYSLIB_IEC_TYPE_TIME_OF_DAY THEN
			brsmemcpy(ADR(allTypes.tTod), structItemAdr, structItemAdrLen);
			strValConv := TOD_TO_STRING(allTypes.tTod);
			copyConvStr := TRUE;
			useQuoation := TRUE;
		
		ELSIF varType = SYSLIB_IEC_TYPE_BYTE THEN
			brsmemcpy(ADR(allTypes.tByte), structItemAdr, structItemAdrLen);
			strValConv := BYTE_TO_STRING(allTypes.tByte);
			copyConvStr := TRUE;
		
		ELSIF varType = SYSLIB_IEC_TYPE_WORD THEN
			brsmemcpy(ADR(allTypes.tWord), structItemAdr, structItemAdrLen);
			strValConv := WORD_TO_STRING(allTypes.tWord);
			copyConvStr := TRUE;
		
		ELSIF varType = SYSLIB_IEC_TYPE_DWORD THEN
			brsmemcpy(ADR(allTypes.tDword), structItemAdr, structItemAdrLen);
			strValConv := DWORD_TO_STRING(allTypes.tDword);
			copyConvStr := TRUE;
		
		ELSIF varType = SYSLIB_IEC_TYPE_WSTRING THEN
		
		ELSE
			JSON_var_serialize := JSONer_BadVarType;
			RETURN;
		END_IF;
		//================================================
		//Converted values copy
		IF copyConvStr THEN
			xStrLen := brsstrlen(ADR(strValConv)) + 2 * BOOL_TO_DINT(useQuoation);
			IF freeBuffer > xStrLen THEN
				IF useQuoation THEN
					pBuffer := brsstrcpy(pBuffer, ADR('"'));
				END_IF;
				pBuffer := brsstrcpy(pBuffer, ADR(strValConv));
				IF useQuoation THEN
					pBuffer := brsstrcpy(pBuffer, ADR('"'));
				END_IF;
				freeBuffer := freeBuffer - xStrLen;
			ELSE
				JSON_var_serialize := JSONer_SmallBuffer;
				RETURN;
			END_IF;
		END_IF;
		//================================================
		//Array handling
		actDim := actDim - 1;
		IF actDim > 0 THEN
			IF freeBuffer > 2 THEN
				pBuffer := brsstrcpy(pBuffer, ADR(','));
				freeBuffer := freeBuffer - 2;
			ELSE
				JSON_var_serialize := JSONer_SmallBuffer;
				RETURN;
			END_IF;
		END_IF;
	END_WHILE;
	
	IF JSON_var_serialize <> JSONer_Ok THEN
		RETURN;
	END_IF;
	//================================================
	//End Array
	IF varDimension > 1 AND NOT (varType = 0) THEN
		IF freeBuffer > 2 THEN
			pBuffer := brsstrcpy(pBuffer, ADR(']'));
			freeBuffer := freeBuffer - 2;
		ELSE
			JSON_var_serialize := JSONer_SmallBuffer;
			RETURN;
		END_IF;
	END_IF;
	//================================================
	JSON_var_serialize := JSONer_Ok;
END_FUNCTION