//================================================
//
FUNCTION findChar
	FOR i := 0 TO maxLen BY 1 DO
		c ACCESS (pStart + i);
		IF c = cIn THEN
			maxLen := maxLen - (i + 1);
			pStart := pStart + i + 1;
			findChar := i;
			RETURN;
		ELSIF c = jsonAsciiNULL THEN
			findChar := findError_GenericError;
			RETURN;
		END_IF;
	END_FOR;
	findChar := findError_NotFound;
END_FUNCTION

//================================================
//

FUNCTION findCharOrEnd
	FOR i := 0 TO maxLen BY 1 DO
		c ACCESS (pStart + i);
		IF c = cIn THEN
			maxLen := maxLen - (i + 1);
			pStart := pStart + i + 1;
			findCharOrEnd := i;
			RETURN;
		ELSIF c = jsonAsciiRB OR c = jsonAsciiRSB THEN
			maxLen := maxLen - (i + 1);
			pStart := pStart + i + 1;
			findCharOrEnd := findError_EndExceed;
			RETURN;
		ELSIF c = jsonAsciiNULL THEN
			findCharOrEnd := findError_GenericError;
			RETURN;
		END_IF;
	END_FOR;
	findCharOrEnd := findError_NotFound;
END_FUNCTION


//================================================
//
FUNCTION findQuoation
	FOR i := 0 TO maxLen BY 1 DO
		c ACCESS (pStart + i);
		IF c = jsonAsciiDQuot THEN
			c ACCESS (pStart + i - 1);//Check the char before for backslash - it's will be char in string
			IF (c <> jsonAsciiBackslash AND i > 0) OR i = 0 THEN
				maxLen := maxLen - (i + 1);
				pStart := pStart + i + 1;
				findQuoation := i;
				RETURN;
			END_IF;
		ELSIF c = jsonAsciiRB OR c = jsonAsciiRSB THEN
			maxLen := maxLen - (i + 1);
			pStart := pStart + i + 1;
			findQuoation := findError_EndExceed;
			RETURN;
		ELSIF c = jsonAsciiNULL THEN
			findQuoation := findError_GenericError;
			RETURN;
		END_IF;
	END_FOR;
	findQuoation := findError_NotFound;
END_FUNCTION


//================================================
//
FUNCTION findNumeric
	FOR i := 0 TO maxLen BY 1 DO
		c ACCESS (pStart + i);
		IF (c >= jsonAscii0 AND c <= jsonAscii9) OR c = jsonAsciiPlus OR c = jsonAsciiMinus  THEN
			maxLen := maxLen - i;
			pStart := pStart + i;
			findNumeric := i;
			RETURN;
		ELSIF c = jsonAsciiRB OR c = jsonAsciiRSB THEN
			maxLen := maxLen - (i + 1);
			pStart := pStart + i + 1;
			findNumeric := findError_EndExceed;
			RETURN;
		ELSIF c = jsonAsciiNULL THEN
			findNumeric := findError_GenericError;
			RETURN;
		END_IF;
	END_FOR;
	findNumeric := findError_NotFound;
END_FUNCTION


//================================================
//
FUNCTION findNumericEnd
	FOR i := 0 TO maxLen BY 1 DO
		c ACCESS (pStart + i);
		IF c = jsonAsciiLF OR c = jsonAsciiSP OR c = jsonAsciiTab OR c = jsonAsciiCR OR c = jsonAsciiComma THEN
			maxLen := maxLen - i;
			pStart := pStart + i;
			findNumericEnd := i;
			RETURN;
		ELSIF c = jsonAsciiRB OR c = jsonAsciiRSB THEN
			maxLen := maxLen - (i + 1);
			pStart := pStart + i + 1;
			findNumericEnd := findError_EndExceed;
			RETURN;
		ELSIF c = jsonAsciiNULL THEN
			findNumericEnd := findError_GenericError;
			RETURN;
		END_IF;
	END_FOR;
	findNumericEnd := findError_NotFound;
END_FUNCTION

//================================================
//
FUNCTION findWhitespace
	FOR i := 0 TO maxLen BY 1 DO
		c ACCESS (pStart + i);
		IF c = jsonAsciiLF OR c = jsonAsciiSP OR c = jsonAsciiTab OR c = jsonAsciiCR THEN
			maxLen := maxLen - i;
			pStart := pStart + i;
			findWhitespace := i;
			RETURN;
		ELSIF c = jsonAsciiRB OR c = jsonAsciiRSB THEN
			maxLen := maxLen - (i + 1);
			pStart := pStart + i + 1;
			findWhitespace := findError_EndExceed;
			RETURN;
		ELSIF c = jsonAsciiNULL THEN
			findWhitespace := findError_GenericError;
			RETURN;
		END_IF;
	END_FOR;
	findWhitespace := findError_NotFound;
END_FUNCTION


//================================================
//
FUNCTION extractBool
	il:= 0;
	FOR i := 0 TO maxLen BY 1 DO
		c ACCESS (pStart + i);
		IF c = jsonAscii0 THEN
			out := FALSE;
			EXIT;
		ELSIF c = jsonAscii1 THEN
			out := TRUE;
			EXIT;
		ELSIF c >= jsonAsciiSa AND c <= jsonAsciiSz THEN
			FOR il := 0 TO MIN(maxLen - i, SIZEOF(text)) BY 1 DO
				c ACCESS (pStart + i + il);
				IF c < jsonAsciiSa OR c > jsonAsciiSz THEN
					EXIT;
				END_IF;
			END_FOR;
			IF il > SIZEOF(text) THEN
				extractBool := findError_OutOfMem;
				RETURN;
			END_IF;
			brsmemset(ADR(text), 0, SIZEOF(text));
			brsmemcpy(ADR(text), pStart + i, il);
			IF brsstrcmp(ADR(text), ADR('true')) = 0 THEN
				out := TRUE;
			ELSIF brsstrcmp(ADR(text), ADR('false')) = 0 THEN
				out := FALSE;
			ELSE
				extractBool := findError_GenericError;
				RETURN;				
			END_IF;
			EXIT;			
		ELSIF c = jsonAsciiRB OR c = jsonAsciiRSB THEN
			extractBool := findError_EndExceed;
			RETURN;
		END_IF;
	END_FOR;
	IF i + il >= maxLen THEN
		extractBool := findError_OutOfMem;
	ELSE
		maxLen := maxLen - (i + il);
		pStart := pStart + i + il;
		extractBool := i + il;
	END_IF;
END_FUNCTION