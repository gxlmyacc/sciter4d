
#define SCAPI  __cdecl 
#define EXTERN_C extern "C"


typedef long LONG;

#pragma pack(push, 1)

typedef struct tagDOUBLE 
{
	int  d1;
	int  d2;
} mydouble;

typedef struct tagPOINT
{
	LONG  x;
	LONG  y;
} POINT, *PPOINT, *NPPOINT, *LPPOINT;

typedef struct tagRECT
{
	LONG    left;
	LONG    top;
	LONG    right;
	LONG    bottom;
} RECT, *PRECT, *NPRECT, *LPRECT;


// COM::IUnknown alike thing:
struct iasset 
{
public:
	// mandatory:
	virtual long  add_ref() = 0;
	virtual long  release() = 0;
	// optional:
	virtual bool  get_interface(const char* name, iasset** out) = 0;
};

struct video_source : public iasset
{
	virtual bool play() = 0;
	virtual bool pause() = 0;
	virtual bool stop() = 0;
	virtual bool get_is_ended(bool& eos) = 0;
	virtual bool get_position(mydouble& seconds) = 0;
	virtual bool set_position(mydouble seconds) = 0;
	virtual bool get_duration(mydouble& seconds) = 0;
	// audio
	virtual bool get_volume(mydouble& vol) = 0;
	virtual bool set_volume(mydouble vol) = 0;
	virtual bool get_balance(mydouble& vol) = 0;
	virtual bool set_balance(mydouble vol) = 0;
};


// video_destination interface, represents video rendering site 
struct video_destination : public iasset 
{
	// true if this instance of video_renderer is attached to DOM element and is capable of playing.
	virtual bool is_alive() = 0; 

	// start streaming/rendering 
	virtual bool start_streaming( int frame_width        // width
		, int frame_height       // height 
		, int color_space        // COLOR_SPACE above
		, void* src = 0 ) = 0;  // video_source interface implementation, can be null

	// stop streaming, eof.
	virtual bool stop_streaming() = 0;

	// render frame request, false - video_destination is not available ( isn't alive, document unloaded etc.) 
	virtual bool render_frame(const BYTE* frame_data, UINT frame_data_size) = 0;

};

struct fragmented_video_destination : public video_destination 
{
	// render frame part request, returns false - video_destination is not available ( isn't alive, document unloaded etc.) 
	virtual bool render_frame_part(const BYTE* frame_data, UINT frame_data_size, int x, int y, int width, int height) = 0;

};

EXTERN_C
{
	long SCAPI iasset_add_ref(void* self);
	long SCAPI iasset_release(void* self);
	bool SCAPI iasset_get_interface(void* self, const char* name, iasset** out);


	bool SCAPI video_source_play(void* self);
	bool SCAPI video_source_pause(void* self);
	bool SCAPI video_source_stop(void* self);
	bool SCAPI video_source_get_is_ended(void* self, bool& eos);
	bool SCAPI video_source_get_position(void* self, mydouble& seconds);
	bool SCAPI video_source_set_position(void* self, mydouble seconds);
	bool SCAPI video_source_get_duration(void* self, mydouble& seconds);
	bool SCAPI video_source_get_volume(void* self, mydouble& vol);
	bool SCAPI video_source_set_volume(void* self, mydouble vol);
	bool SCAPI video_source_get_balance(void* self, mydouble& vol);
	bool SCAPI video_source_set_balance(void* self, mydouble vol);

	bool SCAPI video_destination_is_alive(void* self);
	bool SCAPI video_destination_start_streaming(void* self, int frame_width,
		int frame_height, int color_space, void* src = 0 );
	bool SCAPI video_destination_stop_streaming(void* self);
	bool SCAPI video_destination_render_frame(void* self,
		const BYTE* frame_data, UINT frame_data_size);
	bool SCAPI fragmented_video_destination_render_frame_part(void* self, const BYTE* frame_data,
		UINT frame_data_size, int x, int y, int width, int height);
}

long SCAPI iasset_add_ref(void* self) {
	return reinterpret_cast<iasset*>(self)->add_ref();
}

long SCAPI iasset_release(void* self){
	return reinterpret_cast<iasset*>(self)->release();
}

bool SCAPI iasset_get_interface(void* self, const char* name, iasset** out){
	return reinterpret_cast<iasset*>(self)->get_interface(name, out);
}

bool SCAPI video_source_play(void* self) {
	return reinterpret_cast<video_source*>(self)->play();
}

bool SCAPI video_source_pause(void* self){
	return reinterpret_cast<video_source*>(self)->pause();
}
bool SCAPI video_source_stop(void* self) {
	return reinterpret_cast<video_source*>(self)->stop();
}
bool SCAPI video_source_get_is_ended(void* self, bool& eos) {
	return reinterpret_cast<video_source*>(self)->get_is_ended(eos);
}
bool SCAPI video_source_get_position(void* self, mydouble& seconds) {
	return reinterpret_cast<video_source*>(self)->get_position(seconds);
}
bool SCAPI video_source_set_position(void* self, mydouble seconds) {
	return reinterpret_cast<video_source*>(self)->set_position(seconds);
}
bool SCAPI video_source_get_duration(void* self, mydouble& seconds) {
	return reinterpret_cast<video_source*>(self)->get_duration(seconds);
}
bool SCAPI video_source_get_volume(void* self, mydouble& vol) {
	return reinterpret_cast<video_source*>(self)->get_volume(vol);
}
bool SCAPI video_source_set_volume(void* self, mydouble vol) {
	return reinterpret_cast<video_source*>(self)->set_volume(vol);
}
bool SCAPI video_source_get_balance(void* self, mydouble& vol) {
	return reinterpret_cast<video_source*>(self)->get_balance(vol);
}
bool SCAPI video_source_set_balance(void* self, mydouble vol) {
	return reinterpret_cast<video_source*>(self)->set_balance(vol);
}


bool video_destination_is_alive(void* self) {
	return reinterpret_cast<video_destination*>(self)->is_alive();
}

bool video_destination_start_streaming(void* self, int frame_width,
	int frame_height, int color_space, void* src ) {
		return reinterpret_cast<video_destination*>(self)->start_streaming(frame_width, frame_height, color_space, src);
}

bool video_destination_stop_streaming(void* self) {
	return reinterpret_cast<video_destination*>(self)->stop_streaming();
}

bool video_destination_render_frame(void* self,
	const BYTE* frame_data, UINT frame_data_size) {
		return reinterpret_cast<video_destination*>(self)->render_frame(frame_data, frame_data_size);
}

bool fragmented_video_destination_render_frame_part(void* self, const BYTE* frame_data,
	UINT frame_data_size, int x, int y, int width, int height) {     
		return reinterpret_cast<fragmented_video_destination*>(self)->render_frame_part(frame_data, frame_data_size, x, y, width, height);
}

#pragma pack(pop)
