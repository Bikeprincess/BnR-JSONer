/* Automation Studio generated header file */
/* Do not edit ! */
/* JSONer 1.0.1 */

#ifndef _JSONER_
#define _JSONER_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _JSONer_VERSION
#define _JSONer_VERSION 1.0.1
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG3
		#include "AsBrStr.h"
		#include "sys_lib.h"
#endif
#ifdef _SG4
		#include "AsBrStr.h"
		#include "sys_lib.h"
#endif
#ifdef _SGC
		#include "AsBrStr.h"
		#include "sys_lib.h"
#endif


/* Datatypes and datatypes of function blocks */
typedef enum JSONer_Status_e
{	JSONer_Ok = 0,
	JSONer_End,
	JSONer_SmallBuffer,
	JSONer_Error,
	JSONer_VarNotFound,
	JSONer_BadVarType,
	JSONer_InputError
} JSONer_Status_e;

typedef struct JSONer_types_t
{	plcbit tBool;
	signed char tSint;
	signed short tInt;
	signed long tDint;
	unsigned char tUsint;
	unsigned short tUint;
	unsigned long tUdint;
	float tReal;
	double tLreal;
	plcbyte tByte;
	plcword tWord;
	plcdword tDword;
	plcdate tDate;
	plcdt tDt;
	plctime tTime;
	plctod tTod;
} JSONer_types_t;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC JSONer_Status_e JSON_serialize(unsigned long pVarName, unsigned long pUserVarName, unsigned long pOut, unsigned long sizeOut, unsigned long* size);
_BUR_PUBLIC JSONer_Status_e JSON_var_serialize(unsigned long pFullVarName, unsigned long pVarName, unsigned long varDimension, unsigned char varType, plcbit firstMember, unsigned long* pBuffer, unsigned long* freeBuffer);
_BUR_PUBLIC JSONer_Status_e JSON_deserialize(unsigned long pVarName, unsigned long pUserVarName, unsigned long pIn, unsigned long sizeIn);
_BUR_PUBLIC JSONer_Status_e JSON_var_deserialize(unsigned long pFullVarName, plcbit isArray, unsigned long* pStart, unsigned long* size);
_BUR_PUBLIC unsigned long extractBool(unsigned long* pStart, unsigned long* maxLen, plcbit* out);
_BUR_PUBLIC unsigned long findChar(unsigned char cIn, unsigned long* pStart, unsigned long* maxLen);
_BUR_PUBLIC unsigned long findCharOrEnd(unsigned char cIn, unsigned long* pStart, unsigned long* maxLen);
_BUR_PUBLIC unsigned long findQuoation(unsigned long* pStart, unsigned long* maxLen);
_BUR_PUBLIC unsigned long findNumeric(unsigned long* pStart, unsigned long* maxLen);
_BUR_PUBLIC unsigned long findNumericEnd(unsigned long* pStart, unsigned long* maxLen);
_BUR_PUBLIC unsigned long findWhitespace(unsigned long* pStart, unsigned long* maxLen);


/* Constants */
#ifdef _REPLACE_CONST
 #define findError_OK 4294967040U
 #define findError_EndExceed 4294967041U
 #define findError_NotFound 4294967042U
 #define findError_OutOfMem 4294967043U
 #define findError_GenericError 4294967295U
 #define maxUDINT 4294967295U
 #define jsonAsciiDQuot 34U
 #define jsonAsciiBackslash 92U
 #define jsonAsciiLF 10U
 #define jsonAsciiSP 32U
 #define jsonAsciiTab 9U
 #define jsonAsciiCR 13U
 #define jsonAsciiLB 123U
 #define jsonAsciiRB 125U
 #define jsonAsciiLSB 91U
 #define jsonAsciiRSB 93U
 #define jsonAsciiComma 44U
 #define jsonAsciiSQuot 39U
 #define jsonAsciiSlash 47U
 #define jsonAsciiColon 58U
 #define jsonAsciiSa 97U
 #define jsonAsciiSt 0U
 #define jsonAsciiSf 0U
 #define jsonAsciiSn 0U
 #define jsonAsciiSz 122U
 #define jsonAsciiBA 65U
 #define jsonAsciiBZ 90U
 #define jsonAsciiMinus 45U
 #define jsonAsciiPlus 43U
 #define jsonAscii0 48U
 #define jsonAscii1 49U
 #define jsonAscii9 57U
 #define jsonAsciiNULL 0U
#else
 _GLOBAL_CONST unsigned long findError_OK;
 _GLOBAL_CONST unsigned long findError_EndExceed;
 _GLOBAL_CONST unsigned long findError_NotFound;
 _GLOBAL_CONST unsigned long findError_OutOfMem;
 _GLOBAL_CONST unsigned long findError_GenericError;
 _GLOBAL_CONST unsigned long maxUDINT;
 _GLOBAL_CONST unsigned char jsonAsciiDQuot;
 _GLOBAL_CONST unsigned char jsonAsciiBackslash;
 _GLOBAL_CONST unsigned char jsonAsciiLF;
 _GLOBAL_CONST unsigned char jsonAsciiSP;
 _GLOBAL_CONST unsigned char jsonAsciiTab;
 _GLOBAL_CONST unsigned char jsonAsciiCR;
 _GLOBAL_CONST unsigned char jsonAsciiLB;
 _GLOBAL_CONST unsigned char jsonAsciiRB;
 _GLOBAL_CONST unsigned char jsonAsciiLSB;
 _GLOBAL_CONST unsigned char jsonAsciiRSB;
 _GLOBAL_CONST unsigned char jsonAsciiComma;
 _GLOBAL_CONST unsigned char jsonAsciiSQuot;
 _GLOBAL_CONST unsigned char jsonAsciiSlash;
 _GLOBAL_CONST unsigned char jsonAsciiColon;
 _GLOBAL_CONST unsigned char jsonAsciiSa;
 _GLOBAL_CONST unsigned char jsonAsciiSt;
 _GLOBAL_CONST unsigned char jsonAsciiSf;
 _GLOBAL_CONST unsigned char jsonAsciiSn;
 _GLOBAL_CONST unsigned char jsonAsciiSz;
 _GLOBAL_CONST unsigned char jsonAsciiBA;
 _GLOBAL_CONST unsigned char jsonAsciiBZ;
 _GLOBAL_CONST unsigned char jsonAsciiMinus;
 _GLOBAL_CONST unsigned char jsonAsciiPlus;
 _GLOBAL_CONST unsigned char jsonAscii0;
 _GLOBAL_CONST unsigned char jsonAscii1;
 _GLOBAL_CONST unsigned char jsonAscii9;
 _GLOBAL_CONST unsigned char jsonAsciiNULL;
#endif




#ifdef __cplusplus
};
#endif
#endif /* _JSONER_ */

