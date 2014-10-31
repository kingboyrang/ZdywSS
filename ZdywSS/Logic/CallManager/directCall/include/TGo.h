#ifndef _SOFTPHONE_H_
#define _SOFTPHONE_H_

#include "MediaEngineInterface.h"
using namespace gl_media_engine;

typedef unsigned char bool_t;
    
#undef TRUE
#undef FALSE
#define TRUE 1
#define FALSE 0


/*******event state*****/
enum eTGo_event_state
{
    eTGo_STATE_UNREGISTER, 		//unregister
    eTGo_STATE_IDLE,            //idle
    eTGo_STATE_INCOMING,        //incoming
    eTGo_STATE_CONNENCTING,		//connencting
    eTGo_STATE_CALLACTIVE     	//call active
};

/*****event type*****/
enum eTGo_event_type
{
    eTGo_LOAD_MODULE_EV,		// load module event
    eTGo_REGISTER_EV,			// registered event
    eTGo_UNREGISTER_EV,			// unregistered event
    eTGo_DIALCALL_EV,			// call dialed event
    eTGo_INCOMING_EV,			// call incoming event
    eTGo_HANDUP_EV,				// call hanguped event
    eTGo_ANSWERED_EV,  			// call answered event
    eTGo_NETWORK_STATE_EV,		// network state event
    eTGo_UPSINGLEPASS_EV,       // up single pass event
    eTGo_DNSINGLEPASS_EV,       // dn single pass event
    eTGo_TRACELOG_EV,			// trace log event
    eTGo_CALLUPDATE_EV
};

/**the reason for eTGo_NETWORK_STATE_EV**/
enum eTGo_network_state_reason
{
	eTGo_NETWORK_GENERAL,        //general
	eTGo_NETWORK_NICE,           //good
	eTGo_NETWORK_BAD             //bad
};

/*****the reason for eTGo_LOAD_MODULE_EV**/
enum eTGo_module_load_reason
{
    eTGo_ALL_READY_200 = 200, 	//all ready
    eTGo_MOD_LOAD_ERR = -1,		//load error
    eTGo_INVALID_KEY_FILE = -2		//load error
};

/*****the reason for eTGo_REGISTER_EV and eTGo_UNREGISTER_EV**/
enum eTGo_register_reason
{
    eTGo_REG_OK_200			= 200,	//register successed
    eTGo_REG_ERR_403		= 403,	//user id or password errer
    eTGo_REG_ERR_408		= 408,	//register timeout(Network anomaly)
    eTGo_REG_ERR_503		= 503,	//Server unreachable(Server anomaly)
};

/*****the reason for eTGo_UNREGISTER_EV**/
enum eTGo_unregister_reason
{
    eTGo_UNREG_OK_200	= 200,		//unregister successed
    eTGo_UNREG_ERR_408 	= 408		//unregister failed(Network anomaly)
};

/*****the reason for eTGo_DIALCALL_EV***/
enum eTGo_calling_reason
{
    eTGo_CALL_CONTECTING_183	= 183, 	// processing
    eTGo_CALL_RINGING_180	 	= 180,	// ringing
    eTGo_CALL_CONNECTED_200	 	= 200,	// successed
    
    eTGo_CALLER_NOBALANCE_402 	= 402,	// nobalance
    eTGo_CALLEE_FORBIDDEN_403 	= 403,	// Forbidden(caller binding number)
    eTGo_CALLEE_FORBIDDEN_405 	= 405,  // Forbidden(callee too short)
    eTGo_CALLER_PROXYAUTH_407 	= 407,	// proxyauth false
    eTGo_CALLEE_NOTFIND_404	 	= 404,	// callee not find (not online)
    eTGo_CALLEE_NORESPONSE_408	= 408,	// call request timeout(Network anomaly)
    eTGo_CALLEE_REJECT_480    	= 480,	// callee reject 
    eTGo_CALLEE_ISBUSY_486	 	= 486,	// isbusy(busy line)
    eTGo_CALLER_CANCEL_487	 	= 487,	// caller cancel the call
    eTGo_CALLER_NOTACCEP_488  	= 488,	// Services do not accept(Media negotiation fails)
	eTGo_CALLEE_FREEZE_501    	= 501,  // Callee Account has been frozen
	eTGo_CALLER_FREEZE_502    	= 502,	// Caller Account has been frozen
    eTGo_CALLER_EXPIRED_503   	= 503,	// Account has expired
    eTGo_CALLEE_DISABLED_530	= 530	// Service unreachable
};


/****the reason for eTGo_INCOMING_EV***/
enum eTGo_incoming_reason
{
    eTGo_INCOMING_CODE = 101		//new call incoming
};


/****the reason for eTGo_CALL_HANDUP***/
enum eTGo_callhandup_reason
{
    eTGo_CALL_HANDUP_BY_CALLER = 0,      //caller hangup
    eTGo_CALL_HANDUP_BY_CALLEE = 1,      //callee hangup
    eTGo_CALL_HANDUP_BY_RTPTIMEOUT = 2,  //rtp timeout hangup
    eTGo_CALL_HANDUP_BY_NOBALANCE = 3    //nobalance hangup
};

/****the reason for eTGo_ANSWERED_EV***/
enum eTGo_callanswered_reason
{
    eTGo_CALL_ANSWERED_OK 	 = 0  	 //answer the call successed
};

/****the reason for singlepass event***/
enum eTGo_singlepass_reason
{
	eTGo_NETWORK_ERROR,				//network problem
	eTGo_AUDIO_DEVICE_INIT,			//local device init failed
	eTGo_START_SEND,				//send failed
	eTGo_START_RECEIVE_FAIL,		//create channel failed
	eTGo_SET_LOCAL_RECEIVER_FAIL,	//receive failed
};

/*****debug level ***/
enum eTGo_TGo_TraceLevel
{
    eTraceNone               = 0x0000,  // no trace
    eTraceStateInfo          = 0x0001,
    eTraceWarning            = 0x0002,
    eTraceError              = 0x0004,
    
    // used for debug purposes
    eTraceDebug              = 0x0800,	// debug
    eTraceInfo               = 0x1000,  // debug info

    eTraceAll                = 0xffff
};

/******register state*******/
enum eTGo_register_state
{
    eTGo_USTATE_REG_NONE         = 10,  //init state
    eTGo_USTATE_REG_OK           = 11,  //register ok
    eTGo_USTATE_REG_FAILED       = 12,  //register failed
    eTGo_USTATE_REG_PROCESSING   = 13   //register processing
};

/************************************************************
Function	: TGo_load_media_engine
Description : load media engine
Input		: pMediaStream => media engine pointer
Output		: None 
Return	    : None
Remark      : None
Modified    : 2013/1/16    V1.0.0  Rambo Fu
************************************************************/
int TGo_load_media_engine(gl_media_engine::MediaEngineInterface* pMediaStream);


/************************************************************
Function	: TGo_unload_media_engine
Description : destroy media engine
Input		: None
Output		: None 
Return	    : None
Remark      : None
Modified    : 2013/1/16    V1.0.0  Rambo Fu
************************************************************/
int TGo_unload_media_engine(void);


/************************************************************
Function	: TGo_init
Description : init sp module
Input		: u_platform => (App platform)
			  u_name	 => (brand name,eg:kc,uu,sky,efl,3g,uxin,feiin)
			  u_version	 => (App version)
Output		: None 
Return	    : Successful return 0 , Failure returns -1
Remark      : None
Modified    : 2012/5/18    V1.0.0  Rookie John
************************************************************/
int TGo_init(const char* u_keyfile, const char* u_platform, const char* u_name, const char* u_version);


/************************************************************
Function	: TGo_destroy
Description : destroy sp module
Input		: None
Output		: None 
Return	    : Successful return 0 , Failure returns -1
Remark      : None
Modified    : 2012/5/18    V1.0.0  Rookie John
************************************************************/
int TGo_destroy(void);


/************************************************************
Function	: TGo_callback_register
Description : register App callback function 
Input		: cb_fun => (App callback function pointer)
Output		: None 
Return	    : Successful return 0 , Failure returns -1
Remark      : cb_fun params description:
			  ev_type	: event type (see enum eTGo_event_type defined)
			  ev_state	: event state(see enum eTGo_event_type defined)
			  something : event description
			  code		: event reason code (see enum eTGo_xxxx_reason defined)
Modified    : 2012/5/18    V1.0.0  Rookie John
************************************************************/
int TGo_callback_register(void (*cb_fun)(int ev_type, int ev_state, const char* something, int code));


/************************************************************
Function	: TGo_logcallback_register
Description : register log callback function 
Input		: cb_fun => (log callback function pointer)
Output		: None 
Return	    : Successful return 0 , Failure returns -1
Remark      : cb_fun params description:
			  summary	: summary description
			  detail	: detail description
			  level		: only eTraceStateInfo,eTraceError 
Modified    : 2012/5/18    V1.0.0  Rookie John
************************************************************/
int TGo_logcallback_register(void (*cb_fun)(char* summary, char* detail, enum eTGo_TGo_TraceLevel level));


/************************************************************
Function	: TGo_register
Description : Registered to the server 
Input		: server_addr => (server address)
			  u_id		  => (user id)
			  u_pwd		  => (user password)
			  u_display	  => (display name)
			  flag        => (Whether to send registered request message. 0:NO, 1:YES)
Output		: None 
Return	    : Successful return 0 , Failure returns -1
Remark      : None
Modified    : 2012/5/18    V1.0.0  Rookie John
************************************************************/
int TGo_register(const char *server_addr, 
				const char *u_id, 
				const char *u_pwd, 
				const char* u_display, 
				const char flag);


/************************************************************
Function	: TGo_unregister
Description : Unregister to server
Input		: None
Output		: None 
Return	    : Successful return 0 , Failure returns -1
Remark      : None
Modified    : 2012/5/18    V1.0.0  Rookie John
************************************************************/
int TGo_unregister(void);


/************************************************************
Function	: TGo_request_call
Description : Call requested
Input		: phone_number => (call number)
Output		: None 
Return	    : Successful return 0 , Failure returns -1
Remark      : None
Modified    : 2012/5/18    V1.0.0  Rookie John
************************************************************/
int TGo_request_call(const char* phone_number);


/************************************************************
Function	: TGo_answer_call
Description : Answer call requested
Input		: None
Output		: None 
Return	    : Successful return 0 , Failure returns -1
Remark      : None
Modified    : 2012/5/18    V1.0.0  Rookie John
************************************************************/
int TGo_answer_call(void);


/************************************************************
Function	: TGo_hangup_call
Description : Hangup the call
Input		: None
Output		: None 
Return	    : Successful return 0 , Failure returns -1
Remark      : None
Modified    : 2012/5/18    V1.0.0  Rookie John
************************************************************/
int TGo_hangup_call(void);


/************************************************************
Function	: TGo_record_start
Description : Start record for the call
Input		: filepath => (path save the record file)
			: iMode => record mode, 0 record all, 1 record callee, 2 record called
Output		: None 
Return	    : Successful return 0 , Failure returns -1
Remark      : None
Modified    : 2012/5/18    V1.0.0  Rookie John
************************************************************/
int TGo_record_start(const char* filepath, int iMode = 0);


/************************************************************
Function	: TGo_record_stop
Description : Stop record for the call
Input		: None
Output		: None 
Return	    : Successful return 0 , Failure returns -1
Remark      : None
Modified    : 2012/5/18    V1.0.0  Rookie John
************************************************************/
int TGo_record_stop(void);


/************************************************************
Function	: TGo_send_DTMF
Description : Send DTMF message
Input		: c_dtmf => (the char for DTMF)
Output		: None 
Return	    : Successful return 0 , Failure returns -1
Remark      : None
Modified    : 2012/5/18    V1.0.0  Rookie John
************************************************************/
int TGo_send_DTMF(char c_dtmf);


/************************************************************
Function	: TGo_set_mic_mute
Description : Mute set
Input		: enabled => (Whether to enabled mute , TRUE or FALSE)
Output		: None 
Return	    : Successful return 0 , Failure returns -1
Remark      : None
Modified    : 2012/5/18    V1.0.0  Rookie John
************************************************************/
int TGo_set_mic_mute(char enabled);


/************************************************************
Function	: TGo_set_speaker_mute
Description : Speaker set
Input		: enabled => (Whether to enabled speaker, TRUE or FALSE)
Output		: None 
Return	    : Successful return 0 , Failure returns -1
Remark      : None
Modified    : 2012/5/18    V1.0.0  Rookie John
************************************************************/
int TGo_set_speaker_mute(char enabled);

/************************************************************
Function	: TGo_get_version
Description : Get current sp version
Input		: None
Output		: sp_version => (sp verson info)
Return	    : Successful return 0 , Failure returns -1
Remark      : None
Modified    : 2012/5/18    V1.0.0  Rookie John
************************************************************/
int TGo_get_version(char * sp_version);


/************************************************************
Function	: TGo_get_register_state
Description : Get current register state
Input		: None
Output		: None
Return	    : Register state, see eTGo_Register_state degined
Remark      : None
Modified    : 2012/5/18    V1.0.0  Rookie John
************************************************************/
int TGo_get_register_state(void);

/************************************************************
Function	: TGo_set_log_file
Description : Set log file path
Input		: level => (debug level,see enum eTGo_engine_TraceLevel defined)
			  filepath => (path for save log file)
Output		: None
Return	    : Successful return 0 , Failure returns -1
Remark      : None
Modified    : 2012/5/18    V1.0.0  Rookie John
************************************************************/
int TGo_set_log_file(const enum eTGo_TGo_TraceLevel level, const char* filepath);


/************************************************************
Function	: TGo_get_codecs
Description : Get current SP codecs
Input		: pstCodecsList => (codecs list struct pointer)
Output		: pstCodecsList => (codecs list info)
Return	    : Successful return codecs number , Failure returns -1
Remark      : None
Modified    : 2012/5/18    V1.0.0  Rookie John
************************************************************/
int TGo_get_codecs(ME_codec_list_t* pstCodecsList);


/************************************************************
Function	: TGo_enable_Keep_Alive
Description : KeepAlive set  
Input		: enabled => (Whether to enabled KeepAlive, TRUE or FALSE)
Output		: None
Return	    : Successful return 0 , Failure returns -1
Remark      : None
Modified    : 2012/5/18    V1.0.0  Rookie John
************************************************************/
void TGo_enable_Keep_Alive(bool_t enabled);


/************************************************************
Function	: TGo_set_enable_ipv6
Description : IPv6 set  
Input		: enabled => (Whether to enabled IPv6, TRUE or FALSE)
Output		: None
Return	    : Successful return 0 , Failure returns -1
Remark      : None
Modified    : 2012/5/18    V1.0.0  Rookie John
************************************************************/	
int  TGo_set_enable_ipv6(bool_t enabled);


/************************************************************
Function	: SP_get_VoGo_config
Description : get VoGo module config
Input		: pstCtrlConfig => (Ctrl config info,, see ME_CTRL_config defined)
			  pstVIEConfig => (Vie config info, Please set NULL beacuse don't implement vigo module)
			  pstVQEConfig => (Voe config info, see ME_VQE_config defined)
			  pstRTPConfig => (Rtp config info, see ME_RTP_config defined)
Output		: None
Return	    : Successful return 0 , Failure returns -1
Remark      : None
Create      : 2012/12/27    V1.0.0  Rambo Fu
************************************************************/	
int TGo_get_config(ME_CTRL_cfg_t* pstCtrlConfig, 
					ME_ViGo_cfg_t* pstVIEConfig, 
					ME_VQE_cfg_t* pstVQEConfig, 
					ME_RTP_cfg_t* pstRTPConfig);


/************************************************************
Function	: SP_set_VoGo_config
Description : VoGo module config set  
Input		: pstCtrlConfig => (Ctrl config info,, see ME_CTRL_config defined)
			  pstVIEConfig => (VIGO config info,, Please set NULL beacuse don't implement vigo module)
			  pstVQEConfig => (Voe config info, see ME_VQE_config defined)
			  pstRTPConfig => (Rtp config info, see ME_RTP_config defined)
Output		: None
Return	    : Successful return 0 , Failure returns -1
Remark      : None
Modified    : 2012/5/18    V1.0.0  Rookie John
************************************************************/	
int TGo_set_config(ME_CTRL_cfg_t* pstCtrlConfig, 
					ME_ViGo_cfg_t* pstVIEConfig, 
					ME_VQE_cfg_t* pstVQEConfig, 
					ME_RTP_cfg_t* pstRTPConfig);


/************************************************************
 Function	: TGo_get_emodel_value;
 Description : get emodel value
 Input		: pemodel => (emodel value struct pointer)
 Output		: None
 Return	    : Success return 0, faild return -1
 Remark      : None
 Modified    : 2012/12/10     v1.0.0  Rookie John
 ************************************************************/
int TGo_get_emodel_value(ME_emodel_calculate_t* pemodel);
       
#endif

