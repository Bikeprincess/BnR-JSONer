
TYPE
	jsonTest_t : 	STRUCT 
		a : BOOL := FALSE;
		d : UDINT := 1;
		b : UDINT := 0;
		c : ARRAY[0..2]OF UDINT := [3,4,5];
		e : REAL := 123.456;
		t : ARRAY[0..1]OF jsonTestInner_t := [(i1:=1,i2:=2),(i1:=3,i2:=4)];
	END_STRUCT;
	jsonTestInner_t : 	STRUCT 
		i1 : UDINT := 1;
		i2 : UDINT := 2;
	END_STRUCT;
END_TYPE
