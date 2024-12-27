
TYPE
	jsonTest_t : 	STRUCT 
		t : ARRAY[0..1]OF jsonTestInner_t := [(i1:=1,i2:=2),(i1:=3,i2:=4)];
		a : BOOL := TRUE;
		b : UDINT := 2;
		c : ARRAY[0..2]OF UDINT := [3,4,5];
		d : INT := 6;
		e : REAL := 123.456;
	END_STRUCT;
	jsonTestInner_t : 	STRUCT 
		i1 : USINT := 1;
		i2 : UINT := 2;
	END_STRUCT;
END_TYPE
