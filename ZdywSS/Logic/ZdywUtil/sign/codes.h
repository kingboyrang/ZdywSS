
#ifndef _CODES_
#define _CODES_

#ifdef __cplusplus   
extern "C"  
#endif  

//注意:rc4,md5接口必须放到codes.c中来，因为我的工程也有rc4,md5接口，可能会被调用导致程序出错.
//参数：
//src:要加密的字符串
//srclen:加加密的字符串长度
//outstr:输出加密后的字符串
//deType:加密算法类型
//keyType:加密key类型
//keystr;加密码key字符串
//keylen;加密码key字符串长度
//注：如果keystr为空，就使用内置key字符串
char* KcDecode(char *src, char *keystr,int srclen,int deType,int keyType,int keylen);

#endif
