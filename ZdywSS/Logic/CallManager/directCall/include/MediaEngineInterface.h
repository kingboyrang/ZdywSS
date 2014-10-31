#ifndef  _MEDIA_ENGINE_INTERFACE_H_
#define _MEDIA_ENGINE_INTERFACE_H_

#ifdef WIN32
#pragma warning (disable:4996)
#endif

#define RES_OK	0
#define RES_ERR -1
#define RES_ERR_USED -2 			 //VOE is sound send

#ifndef TRUE
#define TRUE  1
#endif

#ifndef FALSE
#define FALSE  0
#endif


/*********** media engine struct define ************/
enum eME_state
{
	eME_done,			  //done
	eME_init,			  //init
	eME_idle,			  //idle
	eME_Running, 		  //active
};

enum eME_event_type
{
	eME_RTP_TIMEOUT_EV,		// RTP timeout
	eME_RTP_UPSINGLEPASS_EV,// UP RTP single pass
	eME_RTP_DNSINGLEPASS_EV,// DN RTP single pass
	eME_NETWORK_STATE_EV,	// networt state ("general", "nice" ,"bad")
	eME_CALL_RINGING_EV,	// call ringing
	eME_DEVICE_EV,			// device status info	
    eME_LOG_TRACE_EV,		// trace log
	eME_OTHER_EV			// other			
};

enum eME_event_reason
{
	/**network state reason*****/
	eME_REASON_NETWORK_GENERAL,
	eME_REASON_NETWORK_NICE,
	eME_REASON_NETWORK_BAD,

	/**RTP timeout****/
	eME_REASON_RTP_TIMEOUT, 

	/**RTP singlepass****/
	eME_REASON_NETWORK_ERROR,				//network problem
	eME_REASON_AUDIO_DEVICE_INIT,			//local device init failed
	eME_REASON_START_SEND,					//send failed
	eME_REASON_START_RECEIVE_FAIL,			//create channel failed
	eME_REASON_SET_LOCAL_RECEIVER_FAIL,		//receive failed 

	/**call ringing***/
	eME_REASON_CALL_RINGING,

	/**device status info***/
	eME_REASON_INIT_MIC_FAILED,
	eME_REASON_INIT_SPEAKER_FAILED,

    /**log level**/
	eME_REASON_LOG_LEVEL_ERR,
	eME_REASON_LOG_LEVEL_INFO,
	
	/**unknow reason**/
	eME_REASON_UNKNOW
};

/*****trace level***/
enum eME_TraceLevel
{
    kME_TraceNone               = 0x0000, // no trace
    kME_TraceStateInfo          = 0x0001,
    kME_TraceWarning            = 0x0002,
    kME_TraceError              = 0x0004,
    
    // used for debug purposes
    kME_TraceDebug              = 0x0800, // debug
    kME_TraceInfo               = 0x1000, // debug info
    
    kME_TraceAll                = 0xffff
};


/*****Check codecs supported*****/
enum eME_codecs_check_method
{
    eME_codecs_mime_method,
    eME_codesc_payload_method
};

/*****configeration info for control*******/
typedef struct tag_CTRL_config
{	
	unsigned char ucRealTimeType;	//Real time protocol type, 0: RTP 1: PRTP, default 0
	unsigned char ucPhoneProtocol;	//Phone protocol, 0: disable 1: enable, default 0
	unsigned char ucVideoEnable;	//Video module, 0: disable 1: enable, default 0
	unsigned char ucEmodelEnable;	//Emodel module, 0: disable 1: enable, default 1
}ME_CTRL_cfg_t;

/*****configeration info for voice quality enhancement*******/
typedef struct tag_VQE_config
{
    bool Ec_enable;				//Enable EC function on send port if true, else disable
    bool Agc_enable;			//Enable Agc function on send port if true, else disable
    bool Ns_enable;				//Enable Ns function on send port if true, else disable
    bool Agc_Rx_enable;			//Enable Agc function on receive port if true, else disable
    bool Ns_Rx_enable;			//Enable Ns function on receive port if true, else disable
}ME_VQE_cfg_t;

/*****configeration info for RTP*******/
typedef struct tag_RTP_config
{
    unsigned int 	uiRTPTimeout;	//RTP time over, it is valid when set RTP as transport;
  	bool 			uiFixLowPayload;//when network is bad,we used this,only used in prtp protocal,if this enable,auto payload close
}ME_RTP_cfg_t;

typedef struct tag_ViGo_config
{
	unsigned short 		usWidth;		
	unsigned short 		usHeight;	

    unsigned int        uistartBitrate;
    unsigned char       ucmaxFramerate;

 	void *				pLiveRemoteVideo;   
	void *				pLiveVideo;
}ME_ViGo_cfg_t;

typedef struct tag_audio_payload_info
{
	int iPayLoadType;	       //audio codec payload type
	char cRemoteAudioIp[32];   //audio remote  ip addr
	int iRemoteAudioPort;	   //audio remote port
	int iLocalAudioPort;	   //audio local port
}ME_audio_payload_info_t;

typedef struct tag_video_payload_info
{
	int iPayLoadType;			//video codec payload type
	char cRemoteVideoIp[32];	//video remote ip addr
	int	iRemoteVideoPort;		//video remote port
	int iLocalVideoPort;		//video local port
	char ucVideoEnable;			//video enabled
}ME_video_payload_info_t;

/*****configeration info for emodel*******/
typedef struct tag_emodel_calc_info
{
	int    flag;
	int    count;
	double total;
	double average;
	double min;
	double max;
	double current;
}ME_emodel_calc_info_t;

typedef struct tag_emodel_calculate
{
	ME_emodel_calc_info_t emodel_mos;
	ME_emodel_calc_info_t emodel_tr;
	ME_emodel_calc_info_t emodel_ppl;
	ME_emodel_calc_info_t emodel_burstr;
	ME_emodel_calc_info_t emodel_ie;
}ME_emodel_calculate_t;


/*****configeration info for codec*******/
typedef struct tag_codec_info
{
    int pltype;			//playload type value
    char plname[32];	//codec name 
    int plfreq;			//codec freq value
    int pacsize;		//codec packet size
    int channels;		//channels number
    int rate;			//bit rate
    int enabled; 		//use enabled
}ME_codec_info_t;

#define MAX_CODEC_LIST_NUM		20
typedef struct tag_codec_list
{
 	int num;
	ME_codec_info_t codecs[MAX_CODEC_LIST_NUM];
}ME_codec_list_t;
#define ME_CODEC_LIST_T_SIZE	(sizeof(ME_codec_list_t))

typedef struct tag_media_event_node
{
	int ev_type;
	int ev_reason;
	char something[256];
}ME_event_node_t;
#define ME_EVENT_NODE_T_SIZE (sizeof(ME_event_node_t))

typedef void (*EngineCallback)(int ev_type, int ev_reason, void* something);

/******************************************/

namespace gl_media_engine {

typedef enum eEngine_Type
{
	eVoGo,
	eViGo,
}eEngine_Type;

class MediaEngineInterface{
 public:
	/* Voe module init */	
    virtual int init(void) = 0;
    
    
	/* Voe module destroy */
    virtual int destroy(void) = 0;
    
    
	/* App callback fuction register */
    virtual int callback_register(void (*cb_fun)(int ev_type, int ev_reason, void* something)) = 0;
    
    
	/* Start audio media streams */
    virtual int start_audio(void *pAudioPayloadInfo) = 0;
    
    
  	/* Stop audio media streams */
    virtual int stop_audio(void) = 0;

	/* Start video media streams */
    virtual int start_video(void *pVideoPayloadInfo) = 0;
    
    
  	/* Stop video media streams */
    virtual int stop_video(void) = 0;
    

#ifdef _WIN32    
	/* Start record */
    virtual int record_start(const char* filepath, int iMode = 0) = 0;
    
    
 	/* Stop record */
    virtual int record_stop(void) = 0;
#endif

	/* Whether music have been started */
    virtual int music_is_started(void) = 0;
    

    /* send DTMF */
    virtual int send_DTMF(char c_dtmf) = 0;
    
    
	/* Mute set */
    virtual int set_mic_mute(char enabled) = 0;
    
    
    /* Speaker set */
    virtual int set_speaker_mute(char enabled) = 0;
    
    
    /* Debug level set */
    virtual int set_debug_level(int level) = 0;
    
    
    /* Get current voe version */
    virtual int get_version(char * voe_version) = 0;
    
    
	/* Get current voe state */
    virtual int get_state(void) = 0;

  	/* Get current voe state */
    virtual void set_state(int state) = 0;
  
	/* Set codec supported by check methods */
    virtual int codec_supported(const char *codecs_str, int e_method) = 0;

	/* Get current SP codecs */
    virtual int get_codecs(ME_codec_list_t* codecs_list) = 0;

	/* Set log file path */
	virtual int set_log_file_path(const char* filepath) = 0;

	/* Get Emodel Calc values*/
	virtual int get_emodel_calc_value(void* evalue) = 0;
	
#ifdef ANDROID
   	/* Set App context object for android platform */
    virtual void set_android_obj(void* jvm,void* env,void* context) = 0;
	virtual void set_android_api_level(int level) = 0;
#endif

	/* get config prms of VoGo */	
	virtual int get_config(void* pstTGOConfig, void *pstVIEConfig, void* pstVQEConfig, void* pstRTPConfig) = 0;

	/* Voe module config set */	
	virtual int set_config(void* pstTGOConfig, void *pstVIEConfig, void* pstVQEConfig, void* pstRTPConfig) = 0;

	/*the below function is ready for test, maybe will use it in future*/
	virtual int set_audio_device(unsigned int wav_dev_in, unsigned int wav_dev_out) = 0;
	virtual int set_speaker_volume(unsigned int volume) = 0;
	virtual int set_mic_volume(unsigned int volume) = 0;
#ifdef _WIN32
	virtual int play_file(const char* filepath, int iFileFormat = 1) = 0;
	virtual int stop_file(const char* filepath) = 0;
#endif

#ifdef AUTO_P862_TEST
	virtual int set_test_mode(int iMode) = 0;
#endif
    
	virtual eEngine_Type kind() = 0;

};

}  // namespace gl_media_engine

#endif  //_MEDIASTREAMINTERFACE_H_

