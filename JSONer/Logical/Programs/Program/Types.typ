
TYPE
	jsonTest_t : 	STRUCT 
		a : ARRAY[0..2]OF UDINT;
		b : BOOL;
		c : USINT;
		d : UINT;
		e : UDINT;
		f : SINT;
		g : INT;
		h : DINT;
		i : REAL;
		j : LREAL;
		k : BYTE;
		l : WORD;
		m : DWORD;
		n : STRING[80];
		o : DATE_AND_TIME;
		p : DATE;
		q : TIME;
		r : TIME_OF_DAY;
		t : ARRAY[0..1]OF jsonTestInner_t;
	END_STRUCT;
	jsonTestInner_t : 	STRUCT 
		i1 : USINT;
		i2 : UINT;
		i3 : UDINT;
	END_STRUCT;
END_TYPE
