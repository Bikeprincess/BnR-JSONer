(*Structures*)

TYPE
	JSONer_types_t : 	STRUCT 
		tBool : BOOL;
		tSint : SINT;
		tInt : INT;
		tDint : DINT;
		tUsint : USINT;
		tUint : UINT;
		tUdint : UDINT;
		tReal : REAL;
		tLreal : LREAL;
		tByte : BYTE;
		tWord : WORD;
		tDword : DWORD;
		tDate : DATE;
		tDt : DATE_AND_TIME;
		tTime : TIME;
		tTod : TIME_OF_DAY;
	END_STRUCT;
END_TYPE

(*Enums*)

TYPE
	JSONer_Status_e : 
		(
		JSONer_Ok := 0,
		JSONer_SmallBuffer,
		JSONer_Error,
		JSONer_VarNotFound,
		JSONer_BadVarType,
		JSONer_InputError
		);
END_TYPE
