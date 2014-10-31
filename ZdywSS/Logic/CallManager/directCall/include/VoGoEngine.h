#ifndef  _VOGO_MEDIA_ENGINE_H_
#define _VOGO_MEDIA_ENGINE_H_

#include "MediaEngineInterface.h"

namespace gl_media_engine {

class VoGoEngine : public MediaEngineInterface{

public:
	VoGoEngine(void);

public:
	/* VOGO module init */	
    virtual int init(void);
    
    
	/* VOGO module destroy */
    virtual int destroy(void);
        
	/* App callback fuction register */
    virtual int callback_register(void (*cb_fun)(int ev_type, int ev_reason, void* something));
    
    
	/* Start audio media streams */
    virtual int start_audio(void *pAudioPayloadInfo);
    
    
  	/* Stop audio media streams */
    virtual int stop_audio(void);

	/* Start video media streams */
    virtual int start_video(void *pVideoPayloadInfo);
    
    
  	/* Stop video media streams */
    virtual int stop_video(void);
    

#ifdef _WIN32    
	/* Start record */
    virtual int record_start(const char* filepath, int iMode = 0);
    
    
 	/* VOGO record */
    virtual int record_stop(void);
#endif

	/* Whether music have been started */
    virtual int music_is_started(void);
    

    /* send DTMF */
    virtual int send_DTMF(char c_dtmf);
    
    
	/* Mute set */
    virtual int set_mic_mute(char enabled);
    
    
    /* Speaker set */
    virtual int set_speaker_mute(char enabled);
    
    
    /* Debug level set */
    virtual int set_debug_level(int level);
    
    
    /* Get current VOGO version */
    virtual int get_version(char * voe_version);
    
    
	/* Get current VOGO state */
    virtual int get_state(void);
    
	/* Set current VOGO state */
    virtual void set_state(int state);
    
	/* Set codec supported by check methods */
    virtual int codec_supported(const char *codecs_str, int e_method);

	/* Get current SP codecs */
    virtual int get_codecs(ME_codec_list_t* codecs_list);

	/* Set log file path */
	virtual int set_log_file_path(const char* filepath);

	/* Get Emodel Calc values*/
	virtual int get_emodel_calc_value(void* evalue);
	
#ifdef ANDROID
   	/* Set App context object for android platform */
     virtual void set_android_obj(void* jvm,void* env,void* context);
     virtual void set_android_api_level(int level);
#endif

	/* get config prms of VoGo */	
	virtual int get_config(void* pstCTRLConfig, void* pstVIEConfig, void* pstVQEConfig, void* pstRTPConfig);


	/* VOGO module config set */	
	virtual int set_config(void* pstCTRLConfig, void* pstVIEConfig, void* pstVQEConfig, void* pstRTPConfig);

	/*the below function is ready for test, maybe will use it in future*/
	int set_audio_device(unsigned int wav_dev_in, unsigned int wav_dev_out);
	int set_speaker_volume(unsigned int volume);
	int set_mic_volume(unsigned int volume);
	int play_file(const char* filepath, int iFileFormat = 1);
	int stop_file(const char* filepath);

#ifdef AUTO_P862_TEST
	int set_test_mode(int iMode);
#endif
	virtual eEngine_Type kind();
	
	// The peer wants to  receive audio.
	bool has_audio() const { return has_audio_; }
	
	// The peer wants to receive video.
	bool has_video() const { return false; }

public:
  virtual ~VoGoEngine();

private:
	bool has_audio_;
	bool has_video_;

};

}  // namespace gl_media_engine

#endif  //_MEDIASTREAMINTERFACE_H_


