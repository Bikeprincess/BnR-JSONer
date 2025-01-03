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
			maxLen := maxLen - (i + 1);
			pStart := pStart + i + 1;
			findQuoation := i;
			RETURN;
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
	FOR i := 0 TO maxLen BY 1 DO
		c ACCESS (pStart + i);
		IF c = jsonAscii0 THEN
			out := FALSE;
			EXIT;
		ELSIF c = jsonAscii1 THEN
			out := TRUE;
			EXIT;
		ELSIF c = jsonAsciiDQuot THEN
			FOR il := 1 TO maxLen - i BY 1 DO
				c ACCESS (pStart + i + il);
				IF c = jsonAsciiDQuot THEN
					EXIT;
				END_IF;
			END_FOR;
			brsmemset(ADR(text), 0, SIZEOF(text));
			brsmemcpy(ADR(text), pStart + i + 1, il - 1);
			out := STRING_TO_BOOL(text);
			EXIT;			
		ELSIF c = jsonAsciiRB OR c = jsonAsciiRSB THEN
			extractBool := findError_EndExceed;
			RETURN;
		END_IF;
	END_FOR;
	IF i + il >= maxLen THEN
		extractBool := findError_OutOfMem;
	ELSE
		maxLen := maxLen - (i + 1);
		pStart := pStart + i + 1;
		extractBool := i + il;
	END_IF;
END_FUNCTION