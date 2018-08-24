{*******************************************************************************
 标题:     SciterApiImpl.pas
 描述:     Sciter32.dll的接口单元
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterApiImpl;

interface

{$I Sciter.inc}

uses
  Windows, SysUtils, SciterTypes,
  TiscriptApiImpl, TypInfo, SciterGraphicApiImpl, SciterRequestApiImpl;

const
{$IFDEF CPUX64}
  SCITER_DLL_NAME = 'sciter64.dll';
{$ELSE}
  SCITER_DLL_NAME = 'sciter32.dll';
{$ENDIF}

type
  PIUnknown = ^IUnknown;
  (**Get name of Sciter window class.
   *
   * \return \b LPCWSTR, name of Sciter window class.
   *         \b NULL if initialization of the engine failed, Direct2D or DirectWrite are not supported on the OS.
   *
   * Use this function if you wish to create unicode version of Sciter.
   * The returned name can be used in CreateWindow(Ex)W function.
   * You can use #SciterClassNameT macro.
   **)                                   
  TSciterClassName = function (): LPCWSTR; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**Returns major and minor version of Sciter engine.
   * \return UINT, hiword (16-bit) contains major number and loword contains minor number;
  **)
  TSciterVersion = function (major: BOOL): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**This function is used in response to SCN_LOAD_DATA request.
   *
   * \param[in] hwnd \b HWINDOW, Sciter window handle.
   * \param[in] uri \b LPCWSTR, URI of the data requested by Sciter.
   * \param[in] data \b LPBYTE, pointer to data buffer.
   * \param[in] dataLength \b UINT, length of the data in bytes.
   * \return \b BOOL, TRUE if Sciter accepts the data or \c FALSE if error occured
   * (for example this function was called outside of #SCN_LOAD_DATA request).
   *
   * \warning If used, call of this function MUST be done ONLY while handling
   * SCN_LOAD_DATA request and in the same thread. For asynchronous resource loading
   * use SciterDataReadyAsync
   **)
  TSciterDataReady = function (hwnd: HWINDOW; uri: LPCWSTR; data: LPCBYTE; dataLength: UINT): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**Use this function outside of SCN_LOAD_DATA request. This function is needed when you
   * you have your own http client implemented in your application.
   *
   * \param[in] hwnd \b HWINDOW, Sciter window handle.
   * \param[in] uri \b LPCWSTR, URI of the data requested by Sciter.
   * \param[in] data \b LPBYTE, pointer to data buffer.
   * \param[in] dataLength \b UINT, length of the data in bytes.
   * \param[in] requestId \b LPVOID, SCN_LOAD_DATA requestId, can be NULL.
   * \return \b BOOL, TRUE if Sciter accepts the data or \c FALSE if error occured
   **)
  TSciterDataReadyAsync = function (hwnd: HWINDOW; uri: LPCWSTR; data: LPCBYTE; dataLength: UINT; requestId: LPVOID): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};

  (**Sciter Window Proc.*)
  TSciterProc = function (hwnd: HWINDOW; msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**Sciter Window Proc without call of DefWindowProc.*)
  TSciterProcND = function (hwnd: HWINDOW; msg: UINT; wParam: WPARAM; lParam: LPARAM; var pbHandled: BOOL): LRESULT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};

  (**Load HTML file.
   *
   * \param[in] hWndSciter \b HWINDOW, Sciter window handle.
   * \param[in] filename \b LPCWSTR, File name of an HTML file.
   * \return \b BOOL, \c TRUE if the text was parsed and loaded successfully, \c FALSE otherwise.
   **)
  TSciterLoadFile = function (hWndSciter: HWINDOW; filename: LPCWSTR): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**Load HTML from in memory buffer with base.
   *
   * \param[in] hWndSciter \b HWINDOW, Sciter window handle.
   * \param[in] html \b LPCBYTE, Address of HTML to load.
   * \param[in] htmlSize \b UINT, Length of the array pointed by html parameter.
   * \param[in] baseUrl \b LPCWSTR, base URL. All relative links will be resolved against
   *                                this URL.
   * \return \b BOOL, \c TRUE if the text was parsed and loaded successfully, FALSE otherwise.
   **)
  TSciterLoadHtml = function (hWndSciter: HWINDOW; html: LPCBYTE; htmlSize: UINT; baseUrl: LPCWSTR): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};

  (**Set \link #SCITER_NOTIFY() notification callback function \endlink.
   *
   * \param[in] hWndSciter \b HWINDOW, Sciter window handle.
   * \param[in] cb \b SCITER_NOTIFY*, \link #SCITER_NOTIFY() callback function \endlink.
   * \param[in] cbParam \b LPVOID, parameter that will be passed to \link #SCITER_NOTIFY() callback function \endlink as vParam paramter.
   **)
  TSciterSetCallback = procedure (hWndSciter: HWINDOW; cb: LPSciterHostCallback; cbParam: LPVOID); {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**Set Master style sheet.
   *
   * \param[in] utf8 \b LPCBYTE, start of CSS buffer.
   * \param[in] numBytes \b UINT, number of bytes in utf8.
   **)
  TSciterSetMasterCSS = function (utf8: LPCBYTE; numBytes: UINT): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**Append Master style sheet.
   *
   * \param[in] utf8 \b LPCBYTE, start of CSS buffer.
   * \param[in] numBytes \b UINT, number of bytes in utf8.
   *
   **)
  TSciterAppendMasterCSS = function (utf8: LPCBYTE; numBytes: UINT): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};

  (**Set (reset) style sheet of current document.
   Will reset styles for all elements according to given CSS (utf8)
   *
   * \param[in] hWndSciter \b HWINDOW, Sciter window handle.
   * \param[in] utf8 \b LPCBYTE, start of CSS buffer.
   * \param[in] numBytes \b UINT, number of bytes in utf8.
   **)
  TSciterSetCSS = function (hWndSciter: HWINDOW; utf8: LPCBYTE; numBytes: UINT; baseUrl: LPCWSTR; mediaType: LPCWSTR): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};

  (**Set media type of this sciter instance.
   *
   * \param[in] hWndSciter \b HWINDOW, Sciter window handle.
   * \param[in] mediaType \b LPCWSTR, media type name.
   *
   * For example media type can be "handheld", "projection", "screen", "screen-hires", etc.
   * By default sciter window has "screen" media type.
   *
   * Media type name is used while loading and parsing style sheets in the engine so
   * you should call this function *before* loading document in it.
   *
   **)
  TSciterSetMediaType = function (hWndSciter: HWINDOW; mediaType: LPCWSTR): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**Set media variables of this sciter instance.
   *
   * \param[in] hWndSciter \b HWINDOW, Sciter window handle.
   * \param[in] mediaVars \b SCITER_VALUE, map that contains name/value pairs - media variables to be set.
   *
   * For example media type can be "handheld:true", "projection:true", "screen:true", etc.
   * By default sciter window has "screen:true" and "desktop:true"/"handheld:true" media variables.
   *
   * Media variables can be changed in runtime. This will cause styles of the document to be reset.
   *
   **)
  TSciterSetMediaVars = function (hWndSciter: HWINDOW; const mediaVars: SCITER_VALUE): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};

  TSciterGetMinWidth  = function (hWndSciter: HWINDOW): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  TSciterGetMinHeight = function (hWndSciter: HWINDOW; width: UINT): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};

  TSciterCall = function (hWnd: HWINDOW; functionName: LPCSTR; argc: UINT; const argv: PSCITER_VALUE_ARRAY; var retval: SCITER_VALUE): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  TSciterEval = function (hwnd: HWINDOW; script: LPCWSTR; scriptLength: UINT; var pretval: SCITER_VALUE): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};

  (**Update pending changes in Sciter window.
   *
   * \param[in] hwnd \b HWINDOW, Sciter window handle.
   *
   **)
   TSciterUpdateWindow = procedure (hwnd: HWINDOW); {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (** Try to translate message that sciter window is interested in.
   *
   * \param[in,out] lpMsg \b MSG*, address of message structure that was passed before to ::DispatchMessage(), ::PeekMessage().
   *
   * SciterTranslateMessage has the same meaning as ::TranslateMessage() and should be called immediately before it.
   * Example:
   *
   *   if( !SciterTranslateMessage(&msg) ) 
   *      TranslateMessage(&msg);         
   *
   * ATTENTION!: SciterTranslateMessage call is critical for popup elements in MoSciter.
   *             On Desktop versions of the Sciter this function does nothing so can be ommited.
   *
   **)
   TSciterTranslateMessage = function (var lpMsg: TMsg): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**Set various options.
   *
   * \param[in] hWnd \b HWINDOW, Sciter window handle.
   * \param[in] option \b UINT, id of the option, one of SCITER_RT_OPTIONS
   * \param[in] option \b UINT, value of the option.
   *
   **)
  TSciterSetOption = function (hWnd: HWINDOW; option: TSciterRtOption; value: UINT_PTR): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**Get current pixels-per-inch metrics of the Sciter window 
   *
   * \param[in] hWndSciter \b HWINDOW, Sciter window handle.
   * \param[out] px \b PUINT, get ppi in horizontal direction.
   * \param[out] py \b PUINT, get ppi in vertical direction.
   *
   **)
  TSciterGetPPI = procedure (hWndSciter: HWINDOW; var px: UINT; var py: UINT); {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**Get "expando" of the view object 
   *
   * \param[in] hWndSciter \b HWINDOW, Sciter window handle.
   * \param[out] pval \b VALUE*, expando as sciter::value.
   *
   **)
  TSciterGetViewExpando = function (hwnd: HWINDOW; var pval: SCITER_VALUE): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (** Get url resource data received by the engine
   *  Note: this function really works only if the engine is set to debug mode.
   *
   * \param[in] hWndSciter \b HWINDOW, Sciter window handle.
   * \param[in] receiver \b URL_DATA_RECEIVER, address of reciver callback.
   * \param[in] param \b LPVOID, param passed to callback as it is.
   * \param[in] url \b LPCSTR, optional, url of the data. If not provided the engine will list all loaded resources
   * \return \b BOOL, \c TRUE if receiver is called at least once, FALSE otherwise.
   *
   **)
  TSciterEnumUrlData = function (hWndSciter: HWINDOW; receiver: TUrlDataReceiver; param: LPVOID; url: LPCSTR): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};

{$IFDEF WINDOWS}
  (**Creates instance of Sciter Engine on window controlled by DirectX
  *
  * \param[in] hwnd \b HWINDOW, window handle to create Sciter on.
  * \param[in] IDXGISwapChain \b pSwapChain,  reference of IDXGISwapChain created on the window.
  * \return \b BOOL, \c TRUE if engine instance is created, FALSE otherwise.
  *
  **)
  TSciterCreateOnDirectXWindow = function (hwnd: HWINDOW; pSwapChain: IUnknown): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF}; // IDXGISwapChain
  (**Renders content of the document loaded into the window
  * Optionally allows to render parts of document (separate DOM elements) as layers
  *
  * \param[in] hwnd \b HWINDOW, window handle to create Sciter on.
  * \param[in] HELEMENT \b elementToRenderOrNull,  html element to render. If NULL then the engine renders whole document.
  * \param[in] BOOL \b frontLayer,  TRUE if elementToRenderOrNull is not NULL and this is the topmost layer.
  * \return \b BOOL, \c TRUE if layer was rendered successfully.
  *
  **)
  TSciterRenderOnDirectXWindow = function (hwnd: HWINDOW; elementToRenderOrNull: HELEMENT; frontLayer: BOOL): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  TSciterRenderOnDirectXTexture = function (hwnd: HWINDOW; elementToRenderOrNull: HELEMENT; surface: IUnknown): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF}; // IDXGISurface

  (**Render document to ID2D1RenderTarget
   *
   * \param[in] hWndSciter \b HWINDOW, Sciter window handle.
   * \param[in] ID2D1RenderTarget \b prt, Direct2D render target.
   * \return \b BOOL, \c TRUE if hBmp is 24bpp or 32bpp, FALSE otherwise.
   *
   **)
  TSciterRenderD2D = function (hWndSciter: HWINDOW; var prt: IUnknown (*ID2D1RenderTarget**)): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};

  (** Obtain pointer to ID2D1Factory instance used by the engine:
   *
   * \param[in] ID2D1Factory \b **ppf, address of variable receiving pointer of ID2D1Factory.
   * \return \b BOOL, \c TRUE if parameters are valid and *ppf was set by valid pointer.
   *
   * NOTE 1: ID2D1Factory returned by the function is "add-refed" - it is your responsibility to call Release() on it. 
   * NOTE 2: *ppf variable shall be initialized to NULL before calling the function. 
   *
   **)
  TSciterD2DFactory = function (out ppf: Pointer (*ID2D1Factory ***)): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (** Obtain pointer to IDWriteFactory instance used by the engine:
   *
   * \param[in] IDWriteFactory \b **ppf, address of variable receiving pointer of IDWriteFactory.
   * \return \b BOOL, \c TRUE if parameters are valid and *ppf was set by valid pointer.
   *
   * NOTE 1: IDWriteFactory returned by the function is "add-refed" - it is your responsibility to call Release() on it. 
   * NOTE 2: *ppf variable shall be initialized to NULL before calling the function. 
   *
   **)
  TSciterDWFactory = function (out ppf: Pointer (*IDWriteFactory ***)): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
{$ENDIF}

  (** Get graphics capabilities of the system
   *
   * \pcaps[in] LPUINT \b pcaps, address of variable receiving: 
   *                             0 - no compatible graphics found;
   *                             1 - compatible graphics found but Direct2D will use WARP driver (software emulation);
   *                             2 - Direct2D will use hardware backend (best performance);
   * \return \b BOOL, \c TRUE if pcaps is valid pointer.
   *
   **)
  TSciterGraphicsCaps = function (pcaps: LPUINT): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (** Set sciter home url.
   *  home url is used for resolving sciter: urls
   *  If you will set it like SciterSetHomeURL(hwnd,"http://sciter.com/modules/")
   *  then <script src="sciter:lib/root-extender.tis"> will load
   *  root-extender.tis from http://sciter.com/modules/lib/root-extender.tis
   *
   * \param[in] hWndSciter \b HWINDOW, Sciter window handle.
   * \param[in] baseUrl \b LPCWSTR, URL of sciter home.
   *
   **)
  TSciterSetHomeURL = function (hWndSciter: HWINDOW; baseUrl: LPCWSTR): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};

  {$IFDEF OSX}
  TSciterCreateNSView = function (frame: LPRECT): HWINDOW; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF}; // returns NSView*
  {$ENDIF}

  (** Create sciter window.
   *  On Windows returns HWND of either top-level or child window created.
   *  On OS X returns NSView* of either top-level window or child view .
   *
   * \param[in] creationFlags \b SCITER_CREATE_WINDOW_FLAGS, creation flags.
   * \param[in] frame \b LPRECT, window frame position and size.
   * \param[in] delegate \b SciterWindowDelegate, either partial WinProc implementation or thing implementing NSWindowDelegate protocol.
   * \param[in] delegateParam \b LPVOID, optional param passed to SciterWindowDelegate.
   * \param[in] parent \b HWINDOW, optional parent window.
   *
   **)
  TSciterCreateWindow = function (creationFlags: UINT; frame: LPRECT;
      delegate: TSciterWindowDelegate; delegateParam: LPVOID; parent: HWINDOW): HWINDOW; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};

  (** SciterSetupDebugOutput - setup debug output function.
   *
   *  This output function will be used for reprting problems
   *  found while loading html and css documents.
   *
   **)
  TSciterSetupDebugOutput =  procedure (
      hwndOrNull: HWINDOW;        // HWINDOW or null if this is global output handler
      param: LPVOID;              // param to be passed "as is" to the pfOutput
      pfOutput: TDebugOutputProc  // output function, output stream alike thing.
    ); {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  TSciterDebugSetupClient = function (
      hwnd:            HWINDOW;                // HWINDOW of the sciter
      param:           LPVOID;                 // param to be passed "as is" to these functions:
      onBreakpointHit: TSciterDebugBpHitCb;    // breakpoint hit event receiver
      onDataRead:      TSciterDebugDataCb      // receiver of requested data
    ): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  TSciterDebugAddBreakpoint = function (hwnd: HWINDOW; fileUrl: LPCWSTR; lineNo: UINT): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  TSciterDebugRemoveBreakpoint = function (hwnd: HWINDOW; fileUrl: LPCWSTR; lineNo: UINT): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  TSciterDebugEnumBreakpoints = function (hwnd: HWINDOW; param: LPVOID; receiver: TSciterDebugBreakpointCb): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};

  TSciter_UseElement = procedure (he: HELEMENT); safecall;
  (**Marks DOM object as unused (a.k.a. Release).
   * Get handle of every element's child element.
   * \param[in] he \b #HELEMENT
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   *
   * Application should call this function when it does not need element's
   * handle anymore.
   * \sa #Sciter_UseElement()
   **)
  TSciter_UnuseElement = procedure (he: HELEMENT); safecall;
  (**Get root DOM element of HTML document.
   * \param[in] hwnd \b HWINDOW, Sciter window for which you need to get root 
   * element
   * \param[out ] phe \b #HELEMENT*, variable to receive root element
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   * 
   * Root DOM object is always a 'HTML' element of the document.
   **)
  TSciterGetRootElement = function (hwnd: HWINDOW): HELEMENT; safecall;
  (**Get focused DOM element of HTML document.
   * \param[in] hwnd \b HWINDOW, Sciter window for which you need to get focus
   * element
   * \param[out ] phe \b #HELEMENT*, variable to receive focus element
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   *
   * phe can have null value (0).
   *
   * COMMENT: To set focus on element use SciterSetElementState(STATE_FOCUS,0)
   **)
  TSciterGetFocusElement = function (hwnd: HWINDOW): HELEMENT; safecall;
  (**Find DOM element by coordinate.
   * \param[in] hwnd \b HWINDOW, Sciter window for which you need to find
   * elementz
   * \param[in] pt \b POINT, coordinates, window client area relative.
   * \param[out ] phe \b #HELEMENT*, variable to receive found element handle.
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   *
   * If element was not found then *phe will be set to zero.
   **)
  TSciterFindElement = function (hwnd: HWINDOW; pt: TPoint): HELEMENT; safecall;
  (**Get number of child elements.
   * \param[in] he \b #HELEMENT, element which child elements you need to count
   * \param[out] count \b UINT*, variable to receive number of child elements
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   *
   * \par Example:
   * for paragraph defined as
   * \verbatim <p>Hello <b>wonderfull</b> world!</p> \endverbatim
   * count will be set to 1 as the paragraph has only one sub element:
   * \verbatim <b>wonderfull</b> \endverbatim
   **)
  TSciterGetChildrenCount = function (he: HELEMENT): UINT; safecall;
  (**Get handle of every element's child element.
   * \param[in] he \b #HELEMENT
   * \param[in] n \b UINT, number of the child element
   * \param[out] phe \b #HELEMENT*, variable to receive handle of the child 
   * element
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   *
   * \par Example:
   * for paragraph defined as
   * \verbatim <p>Hello <b>wonderfull</b> world!</p> \endverbatim
   * *phe will be equal to handle of &lt;b&gt; element:
   * \verbatim <b>wonderfull</b> \endverbatim
   **)
  TSciterGetNthChild = function (he: HELEMENT; n: UINT): HELEMENT; safecall;
  (**Get parent element.
   * \param[in] he \b #HELEMENT, element which parent you need
   * \param[out] p_parent_he \b #HELEMENT*, variable to recieve handle of the 
   * parent element
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   **)
  TSciterGetParentElement = function (he: HELEMENT; var p_parent_he: HELEMENT): SCDOM_RESULT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (** Get html representation of the element.
   * \param[in] he \b #HELEMENT
   * \param[in] outer \b BOOL, if TRUE will return outer HTML otherwise inner.
   * \param[in] rcv \b pointer to function receiving UTF8 encoded HTML.
   * \param[in] rcv_param \b parameter that passed to rcv as it is.
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   *)
  TSciterGetElementHtmlCB = procedure (he: HELEMENT; outer: BOOL; rcv: TLCPBYTEReceiver; rcv_param: LPVOID); {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**Get inner text of the element as LPCWSTR (utf16 words).
   * \param[in] he \b #HELEMENT
   * \param[in] rcv \b pointer to the function receiving UTF16 encoded plain text
   * \param[in] rcv_param \b param passed that passed to LPCWSTR_RECEIVER "as is"
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   *)
  TSciterGetElementTextCB = procedure (he: HELEMENT; rcv: TLPCWSTRReceiver; rcv_param: LPVOID); {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**Set inner text of the element from LPCWSTR buffer (utf16 words).
   * \param[in] he \b #HELEMENT
   * \param[in] utf16words \b pointer, UTF16 encoded plain text
   * \param[in] length \b UINT, number of words in utf16words sequence
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   *)
  TSciterSetElementText = procedure (he: HELEMENT; utf16: LPCWSTR; length: UINT); {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**Get number of element's attributes.
   * \param[in] he \b #HELEMENT
   * \param[out] p_count \b LPUINT, variable to receive number of element
   * attributes.
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   **)
  TSciterGetAttributeCount = function (he: HELEMENT): UINT; safecall;
  (**Get value of any element's attribute by attribute's number.
   * \param[in] he \b #HELEMENT 
   * \param[in] n \b UINT, number of desired attribute
   * \param[out] p_name \b LPCSTR*, will be set to address of the string 
   * containing attribute name
   * \param[out] p_value \b LPCWSTR*, will be set to address of the string 
   * containing attribute value
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   **)
  TSciterGetNthAttributeNameCB = procedure (he: HELEMENT; n: UINT; rcv: LPCSTR_RECEIVER; rcv_param: LPVOID); safecall;
  TSciterGetNthAttributeValueCB = procedure (he: HELEMENT; n: UINT; rcv: LPCWSTR_RECEIVER; rcv_param: LPVOID); safecall;
  (**Get value of any element's attribute by name.
     * \param[in] he \b #HELEMENT
     * \param[in] name \b LPCSTR, attribute name
     * \param[out] p_value \b LPCWSTR*, will be set to address of the string
     * containing attribute value
     * \return \b #EXTERN_C SCDOM_RESULT SCAPI
     **)
  TSciterGetAttributeByNameCB = function (he: HELEMENT; name: LPCSTR; rcv: LPCWSTR_RECEIVER; rcv_param: LPVOID): SCDOM_RESULT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**Set attribute's value.
   * \param[in] he \b #HELEMENT
   * \param[in] name \b LPCSTR, attribute name
   * \param[in] value \b LPCWSTR, new attribute value or 0 if you want to remove attribute.
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   **)
  TSciterSetAttributeByName = procedure (he: HELEMENT; name: LPCSTR; value: LPCWSTR); safecall;
  (**Remove all attributes from the element.
   * \param[in] he \b #HELEMENT
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   **)
  TSciterClearAttributes = procedure (he: HELEMENT); safecall;
  (**Get element index. 
   * \param[in] he \b #HELEMENT 
   * \param[out] p_index \b LPUINT, variable to receive number of the element 
   * among parent element's subelements.
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   **)
  TSciterGetElementIndex = function (he: HELEMENT): UINT; safecall;
  (**Get element's type.
   * \param[in] he \b #HELEMENT
   * \param[out] p_type \b LPCSTR*, receives name of the element type.
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   *
   * \par Example:
   * For &lt;div&gt; tag p_type will be set to "div".
   **)
  TSciterGetElementType = function (he: HELEMENT): LPCSTR; safecall;
  (**Get element's type.
   * \param[in] he \b #HELEMENT
   * \param[out] rcv \b LPCSTR_RECEIVER, receives name of the element type.
   * \param[out] rcv_param \b LPVOID, parameter passed as it is to the receiver.
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   *
   **)
  TSciterGetElementTypeCB = procedure (he: HELEMENT; rcv: LPCSTR_RECEIVER; rcv_param: LPVOID); safecall;
  (**Get element's style attribute.
   * \param[in] he \b #HELEMENT
   * \param[in] name \b LPCSTR, name of the style attribute
   * \param[in] rcv \b pointer to the function receiving UTF16 encoded plain text
   * \param[in] rcv_param \b param passed that passed to LPCWSTR_RECEIVER "as is"
   *
   * Style attributes are those that are set using css. E.g. "font-face: arial" or "display: block".
   *
   * \sa #SciterSetStyleAttribute()
   **)
  TSciterGetStyleAttributeCB = function (he: HELEMENT; name: LPCSTR; rcv: LPCWSTR_RECEIVER; rcv_param: LPVOID): SCDOM_RESULT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**Get element's style attribute.
   * \param[in] he \b #HELEMENT
   * \param[in] name \b LPCSTR, name of the style attribute
   * \param[out] value \b LPCWSTR, value of the style attribute.
   *
   * Style attributes are those that are set using css. E.g. "font-face: arial" or "display: block".
   *
   * \sa #SciterGetStyleAttribute()
   **)
  TSciterSetStyleAttribute = function (he: HELEMENT; name: LPCSTR; value: LPCWSTR): SCDOM_RESULT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (*Get bounding rectangle of the element.
   * \param[in] he \b #HELEMENT
   * \param[out] p_location \b LPRECT, receives bounding rectangle of the element
   * \param[in] rootRelative \b BOOL, if TRUE function returns location of the
   * element relative to Sciter window, otherwise the location is given
   * relative to first scrollable container.
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   **)
  TSciterGetElementLocation = procedure (he: HELEMENT; var p_location: TRect; areas: UINT{ELEMENT_AREAS}); safecall;
  (*Scroll to view.
   * \param[in] he \b #HELEMENT
   * \param[in] SciterScrollFlags \b #UINT, combination of SCITER_SCROLL_FLAGS above or 0
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   **)
  TSciterScrollToView = procedure (he: HELEMENT; SciterScrollFlags: UINT{SCITER_SCROLL_FLAGS}); safecall;
  (**Apply changes and refresh element area in its window.
   * \param[in] he \b #HELEMENT
   * \param[in] andForceRender \b BOOL, TRUE to force UpdateWindow() call.
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   **)
  TSciterUpdateElement = procedure (he: HELEMENT; andForceRender: BOOL); safecall;
  (**refresh element area in its window.
   * \param[in] he \b #HELEMENT
   * \param[in] rc \b RECT, rect to refresh.
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   **)
  TSciterRefreshElementArea = procedure (he: HELEMENT; rc: TRect); safecall;
  (**Set the mouse capture to the specified element.
   * \param[in] he \b #HELEMENT
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   *
   * After call to this function all mouse events will be targeted to the element.
   * To remove mouse capture call ReleaseCapture() function.
   **)
  TSciterSetCapture = procedure (he: HELEMENT); safecall;
  TSciterReleaseCapture = procedure (he: HELEMENT); safecall;
  (**Get HWINDOW of containing window.
   * \param[in] he \b #HELEMENT
   * \param[out] p_hwnd \b HWINDOW*, variable to receive window handle
   * \param[in] rootWindow \b BOOL, handle of which window to get:
   * - TRUE - Sciter window
   * - FALSE - nearest parent element having overflow:auto or :scroll
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   **)
  TSciterGetElementHwnd = procedure (he: HELEMENT; var p_hwnd: HWINDOW; rootWindow: BOOL); safecall;
  (**Combine given URL with URL of the document element belongs to.
   * \param[in] he \b #HELEMENT
   * \param[in, out] szUrlBuffer \b LPWSTR, at input this buffer contains
   * zero-terminated URL to be combined, after function call it contains
   * zero-terminated combined URL
   * \param[in] UrlBufferSize \b UINT, size of the buffer pointed by
   * \c szUrlBuffer
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   *
   * This function is used for resolving relative references.
   **)
  TSciterCombineURL = procedure (he: HELEMENT; szUrlBuffer: LPWSTR; UrlBufferSize: UINT); safecall;
  (**Call specified function for every element in a DOM that meets specified
   * CSS selectors.
   * See list of supported selectors: http://www.terrainformatica.com/sciter/css/selectors.htm
   * \param[in] he \b #HELEMENT
   * \param[in] selector \b LPCSTR, comma separated list of CSS selectors, e.g.: div, #id, div[align="right"].
   * \param[in] callback \b #SciterElementCallback*, address of callback
   * function being called on each element found.
   * \param[in] param \b LPVOID, additional parameter to be passed to callback
   * function.
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   *
   **)
  TSciterSelectElements = procedure (he: HELEMENT; CSS_selectors: LPCSTR; callback: TSciterElementCallback; param: LPVOID); safecall;
  TSciterSelectElementsW = procedure (he: HELEMENT; CSS_selectors: LPCWSTR; callback: TSciterElementCallback; param: LPVOID); safecall;
  (**Find parent of the element by CSS selector. 
   * ATTN: function will test first element itself.
   * See list of supported selectors: http://www.terrainformatica.com/sciter/css/selectors.htm
   * \param[in] he \b #HELEMENT
   * \param[in] selector \b LPCSTR, comma separated list of CSS selectors, e.g.: div, #id, div[align="right"].
   * \param[out] heFound \b #HELEMENT*, address of result HELEMENT
   * \param[in] depth \b LPVOID, depth of search, if depth == 1 then it will test only element itself.
   *                     Use depth = 1 if you just want to test he element for matching given CSS selector(s).
   *                     depth = 0 will scan the whole child parent chain up to the root.
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   *
   **)
  TSciterSelectParent = function (he: HELEMENT; selector: LPCSTR; depth: UINT): HELEMENT; safecall;
  TSciterSelectParentW = function (he: HELEMENT; selector: LPCWSTR; depth: UINT): HELEMENT; safecall;
  (**Set inner or outer html of the element.
   * \param[in] he \b #HELEMENT
   * \param[in] html \b LPCBYTE, UTF-8 encoded string containing html text
   * \param[in] htmlLength \b UINT, length in bytes of \c html.
   * \param[in] where \b UINT, possible values are:
   * - SIH_REPLACE_CONTENT - replace content of the element
   * - SIH_INSERT_AT_START - insert html before first child of the element
   * - SIH_APPEND_AFTER_LAST - insert html after last child of the element
   *                
   * - SOH_REPLACE - replace element by html, a.k.a. element.outerHtml = "something"
   * - SOH_INSERT_BEFORE - insert html before the element
   * - SOH_INSERT_AFTER - insert html after the element
   *   ATTN: SOH_*** operations do not work for inline elements like <SPAN>
   *
   * \return /b #EXTERN_C SCDOM_RESULT SCAPI
    **)
  TSciterSetElementHtml = procedure (he: HELEMENT; const html: PByte; htmlLength: UINT; where: TSetElementHtml); safecall;
  
  (** Element UID support functions.
   *
   *  Element UID is unique identifier of the DOM element.
   *  UID is suitable for storing it in structures associated with the view/document.
   *  Access to the element using HELEMENT is more effective but table space of handles is limited.
   *  It is not recommended to store HELEMENT handles between function calls.
   **)
  (** Get Element UID.
   * \param[in] he \b #HELEMENT
   * \param[out] puid \b UINT*, variable to receive UID of the element.
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   *
   * This function retrieves element UID by its handle.
   *
   **)
  TSciterGetElementUID = function (he: HELEMENT): UINT; safecall;
  (** Get Element handle by its UID.
   * \param[in] hwnd \b HWINDOW, HWINDOW of Sciter window
   * \param[in] uid \b UINT
   * \param[out] phe \b #HELEMENT*, variable to receive HELEMENT handle
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   *
   * This function retrieves element UID by its handle.
   *
   **)
  TSciterGetElementByUID = function (hwnd: HWINDOW; uid: UINT): HELEMENT; safecall;
  (** Shows block element (DIV) in popup window.
   * \param[in] hePopup \b HELEMENT, element to show as popup
   * \param[in] heAnchor \b HELEMENT, anchor element - hePopup will be shown near this element
   * \param[in] placement \b UINT, values: 
   *     2 - popup element below of anchor
   *     8 - popup element above of anchor
   *     4 - popup element on left side of anchor
   *     6 - popup element on right side of anchor
   *     ( see numpad on keyboard to get an idea of the numbers)
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   *
   **)
  TSciterShowPopup = procedure (hePopup: HELEMENT; heAnchor: HELEMENT; placement: UINT); safecall;
  (** Shows block element (DIV) in popup window at given position.
   * \param[in] hePopup \b HELEMENT, element to show as popup
   * \param[in] pos \b POINT, popup element position, relative to origin of Sciter window.
   * \param[in] animate \b BOOL, true if animation is needed.
   **)
  TSciterShowPopupAt = function (hePopup: HELEMENT; pos: TPoint; animate: BOOL): SCDOM_RESULT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (** Removes popup window.
   * \param[in] he \b HELEMENT, element which belongs to popup window or popup element itself
   **)
  TSciterHidePopup = function (hePopup: HELEMENT): SCDOM_RESULT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (** Get/set state bits, stateBits*** accept or'ed values above **)
  TSciterGetElementState = function (he: HELEMENT): UINT; safecall;
  TSciterSetElementState = procedure (he: HELEMENT; stateBitsToSet, stateBitsToClear: UINT; updateView: BOOL); safecall;
  (** Create new element, the element is disconnected initially from the DOM.
      Element created with ref_count = 1 thus you \b must call Sciter_UnuseElement on returned handler.
   * \param[in] tagname \b LPCSTR, html tag of the element e.g. "div", "option", etc.
   * \param[in] textOrNull \b LPCWSTR, initial text of the element or NULL. text here is a plain text - method does no parsing.
   * \param[out ] phe \b #HELEMENT*, variable to receive handle of the element
    **)
  TSciterCreateElement = function (tagname: LPCSTR; textOrNull: LPCWSTR): HELEMENT; safecall;
  (** Create new element as copy of existing element, new element is a full (deep) copy of the element and
      is disconnected initially from the DOM.
      Element created with ref_count = 1 thus you \b must call Sciter_UnuseElement on returned handler.
   * \param[in] he \b #HELEMENT, source element.
   * \param[out ] phe \b #HELEMENT*, variable to receive handle of the new element.
    **)
  TSciterCloneElement = function (he: HELEMENT): HELEMENT; safecall;
  (** Insert element at \i index position of parent.
      It is not an error to insert element which already has parent - it will be disconnected first, but
      you need to update elements parent in this case.
   * \param index \b UINT, position of the element in parent collection.
     It is not an error to provide index greater than elements count in parent -
     it will be appended.
   **)
  TSciterInsertElement = function (he, hparent: HELEMENT; index: UINT): SCDOM_RESULT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (** Take element out of its container (and DOM tree).
      Element will be destroyed when its reference counter will become zero
   **)
  TSciterDetachElement = procedure (he: HELEMENT); safecall;
  (** Take element out of its container (and DOM tree) and force destruction of all behaviors. 
      Element will be destroyed when its reference counter will become zero
   **)
  TSciterDeleteElement = procedure (he: HELEMENT); safecall;
  (** Start Timer for the element. 
      Element will receive on_timer event
      To stop timer call SciterSetTimer( he, 0 );
   **)
  TSciterSetTimer = procedure (he: HELEMENT; milliseconds: UINT; timer_id: UINT_PTR); safecall;
  (** Attach/Detach ElementEventProc to the element 
      See htmlayout::event_handler.
   **)
  TSciterDetachEventHandler = procedure (he: HELEMENT; pep: TElementEventProc; tag: LPVOID); safecall;
  (** Attach ElementEventProc to the element and subscribe it to events providede by subscription parameter
      See Sciter::attach_event_handler.
   **)
  TSciterAttachEventHandler = procedure (he: HELEMENT; pep: TElementEventProc; tag: LPVOID); safecall;
  (** Attach/Detach ElementEventProc to the Sciter window. 
      All events will start first here (in SINKING phase) and if not consumed will end up here.
      You can install Window EventHandler only once - it will survive all document reloads.
   **)
  TSciterWindowAttachEventHandler = procedure (hwndLayout: HWINDOW; pep: TElementEventProc; tag: LPVOID; subscription: UINT); safecall;
  TSciterWindowDetachEventHandler = procedure (hwndLayout: HWINDOW; pep: TElementEventProc; tag: LPVOID); safecall;
  (** SciterSendEvent - sends sinking/bubbling event to the child/parent chain of he element.
      First event will be send in SINKING mode (with SINKING flag) - from root to he element itself.
      Then from he element to its root on parents chain without SINKING flag (bubbling phase).

   * \param[in] he \b HELEMENT, element to send this event to.
   * \param[in] appEventCode \b UINT, event ID, see: #BEHAVIOR_EVENTS
   * \param[in] heSource \b HELEMENT, optional handle of the source element, e.g. some list item
   * \param[in] reason \b UINT, notification specific event reason code
   * \param[out] handled \b BOOL*, variable to receive TRUE if any handler handled it, FALSE otherwise.

   **)
  TSciterSendEvent = function (he: HELEMENT; appEventCode: UINT; heSource: HELEMENT; reason: UINT_PTR): BOOL; safecall;
  (** SciterPostEvent - post sinking/bubbling event to the child/parent chain of he element.
   *  Function will return immediately posting event into input queue of the application. 
   *
   * \param[in] he \b HELEMENT, element to send this event to.
   * \param[in] appEventCode \b UINT, event ID, see: #BEHAVIOR_EVENTS
   * \param[in] heSource \b HELEMENT, optional handle of the source element, e.g. some list item
   * \param[in] reason \b UINT, notification specific event reason code

   **)
  TSciterPostEvent = procedure (he: HELEMENT; appEventCode: UINT; heSource: HELEMENT; reason: UINT_PTR); safecall;
  (** SciterCallMethod - calls behavior specific method.
   * \param[in] he \b HELEMENT, element - source of the event.
   * \param[in] params \b METHOD_PARAMS, pointer to method param block
   **)
  TSciterCallBehaviorMethod = function (he: HELEMENT; params: PMethodParams): SCDOM_RESULT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (** SciterRequestElementData  - request data download for the element.
   * \param[in] he \b HELEMENT, element to deleiver data to.
   * \param[in] url \b LPCWSTR, url to download data from.
   * \param[in] dataType \b UINT, data type, see SciterResourceType.
   * \param[in] hInitiator \b HELEMENT, element - initiator, can be NULL.

    event handler on the he element (if any) will be notified
    when data will be ready by receiving HANDLE_DATA_DELIVERY event.

    **)
  TSciterRequestElementData = function (he: HELEMENT; url: LPCWSTR; dataType: SciterResourceType; initiator: HELEMENT): SCDOM_RESULT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   *  SciterHttpRequest - send GET or POST request for the element
   *
   * event handler on the 'he' element (if any) will be notified
   * when data will be ready by receiving HANDLE_DATA_DELIVERY event.
   *
   **)
  TSciterHttpRequest = procedure (
    he:            HELEMENT;           // element to deliver data
    url:           LPCWSTR;            // url
    dataType:      SciterResourceType; // data type, see SciterResourceType.
    requestType:   TRequestType;       // one of REQUEST_TYPE values
    requestParams: PRequestParamArray; // parameters
    nParams:       UINT                // number of parameters
  ); safecall;

  (** SciterGetScrollInfo  - get scroll info of element with overflow:scroll or auto.
   * \param[in] he \b HELEMENT, element.
   * \param[out] scrollPos \b LPPOINT, scroll position.
   * \param[out] viewRect \b LPRECT, position of element scrollable area, content box minus scrollbars.
   * \param[out] contentSize \b LPSIZE, size of scrollable element content.
   **)
  TSciterGetScrollInfo = procedure (he: HELEMENT; var scrollPos: TPoint; var viewRect: TRect; var contentSize: TSize); safecall;
  (** SciterSetScrollPos  - set scroll position of element with overflow:scroll or auto.
   * \param[in] he \b HELEMENT, element.
   * \param[in] scrollPos \b POINT, new scroll position.
   * \param[in] smooth \b BOOL, TRUE - do smooth scroll.
   **)
  TSciterSetScrollPos = procedure (he: HELEMENT; scrollPos: TPoint; smooth: BOOL); safecall;
  (** SciterGetElementIntrinsicWidths  - get min-intrinsic and max-intrinsic widths of the element.
   * \param[in] he \b HELEMENT, element.
   * \param[out] pMinWidth \b INT*, calculated min-intrinsic width.
   * \param[out] pMaxWidth \b INT*, calculated max-intrinsic width.
   **)
  TSciterGetElementIntrinsicWidths = procedure (he: HELEMENT; var pMinWidth: Integer; var pMaxWidth: Integer); safecall;
  (** SciterGetElementIntrinsicHeight  - get min-intrinsic height of the element calculated for forWidth.
   * \param[in] he \b HELEMENT, element.
   * \param[in] forWidth \b INT*, width to calculate intrinsic height for.
   * \param[out] pHeight \b INT*, calculated min-intrinsic height.
   **)
  TSciterGetElementIntrinsicHeight = function (he: HELEMENT; forWidth: Integer): Integer; safecall;
  (** SciterIsElementVisible - deep visibility, determines if element visible - has no visiblity:hidden and no display:none defined 
      for itself or for any its parents.
   * \param[in] he \b HELEMENT, element.
   * \param[out] pVisible \b LPBOOL, visibility state.
   **)
  TSciterIsElementVisible = function (he: HELEMENT): BOOL; safecall;
  (** SciterIsElementEnabled - deep enable state, determines if element enabled - is not disabled by itself or no one  
      of its parents is disabled.
   * \param[in] he \b HELEMENT, element.
   * \param[out] pEnabled \b LPBOOL, enabled state.
   **)
  TSciterIsElementEnabled = function (he: HELEMENT): BOOL; safecall;
  (** SciterSortElements - sort children of the element.
   * \param[in] he \b HELEMENT, element which children to be sorted.
   * \param[in] firstIndex \b UINT, first child index to start sorting from.
   * \param[in] lastIndex \b UINT, last index of the sorting range, element with this index will not be included in the sorting.
   * \param[in] cmpFunc \b ELEMENT_COMPARATOR, comparator function.
   * \param[in] cmpFuncParam \b LPVOID, parameter to be passed in comparator function.
   **)
  TSciterSortElements = procedure (he: HELEMENT; firstIndex, lastIndex: UINT; cmpFunc: TElementComparator; cmpFuncParam: LPVOID); safecall;
  (** SciterSwapElements - swap element positions.
   * Function changes "insertion points" of two elements. So it swops indexes and parents of two elements.
   * \param[in] he1 \b HELEMENT, first element.
   * \param[in] he2 \b HELEMENT, second element.
   **)
  TSciterSwapElements = procedure (he1, he2: HELEMENT); safecall;
  (** SciterTraverseUIEvent - traverse (sink-and-bubble) MOUSE or KEY event.
   * \param[in] evt \b EVENT_GROUPS, either HANDLE_MOUSE or HANDLE_KEY code.
   * \param[in] eventCtlStruct \b LPVOID, pointer on either MOUSE_PARAMS or KEY_PARAMS structure.
   * \param[out] bOutProcessed \b LPBOOL, pointer to BOOL receiving TRUE if event was processed by some element and FALSE otherwise.
   **)
  TSciterTraverseUIEvent = function (evt: UINT; eventCtlStruct: LPVOID): BOOL; safecall;
  (** CallScriptingMethod - calls scripting method defined for the element.
   * \param[in] he \b HELEMENT, element which method will be callled.
   * \param[in] name \b LPCSTR, name of the method to call.
   * \param[in] argv \b SCITER_VALUE[], vector of arguments.
   * \param[in] argc \b UINT, number of arguments.
   * \param[out] retval \b SCITER_VALUE*, pointer to SCITER_VALUE receiving returning value of the function.
   **)
  TSciterCallScriptingMethod = function (he: HELEMENT; name: LPCSTR; const argv: PSCITER_VALUE_ARRAY; argc: UINT; var retval: SCITER_VALUE): SCDOM_RESULT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (** CallScriptingFunction - calls scripting function defined in the namespace of the element (a.k.a. global function).
   * \param[in] he \b HELEMENT, element which namespace will be used.
   * \param[in] name \b LPCSTR, name of the method to call.
   * \param[in] argv \b SCITER_VALUE[], vector of arguments.
   * \param[in] argc \b UINT, number of arguments.
   * \param[out] retval \b SCITER_VALUE*, pointer to SCITER_VALUE receiving returning value of the function.
   *
   * SciterCallScriptingFunction allows to call functions defined on global level of main document or frame loaded in it.
   *
   **)
  TSciterCallScriptingFunction = procedure (he: HELEMENT; name: LPCSTR; const argv: PSCITER_VALUE_ARRAY; argc: UINT; var retval: SCITER_VALUE); safecall;
  TSciterEvalElementScript = function (he: HELEMENT; script: LPCWSTR; scriptLength: UINT; var retval: SCITER_VALUE): SCDOM_RESULT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**Attach HWINDOW to the element.
   * \param[in] he \b #HELEMENT 
   * \param[in] hwnd \b HWINDOW, window handle to attach
   * \return \b #EXTERN_C SCDOM_RESULT SCAPI
   **)
  TSciterAttachHwndToElement = procedure (he: HELEMENT; hwnd: HWINDOW); safecall;
  (** SciterControlGetType - get type of control - type of behavior assigned to the element.
   * \param[in] he \b HELEMENT, element.
   * \param[out] pType \b UINT*, pointer to variable receiving control type,
   *             for list of values see CTL_TYPE.
   **)
  TSciterControlGetType = function (he: HELEMENT): TControlType{CTL_TYPE}; safecall;
  (** SciterGetValue - get value of the element. 'value' is value of correspondent behavior attached to the element or its text.
   * \param[in] he \b HELEMENT, element which value will be retrieved.
   * \param[out] pval \b VALUE*, pointer to VALUE that will get elements value. 
   *  ATTN: if you are not using json::value wrapper then you shall call ValueClear aginst the returned value
   *        otherwise memory will leak.
   **)
  TSciterGetValue = procedure (he: HELEMENT; var pval: SCITER_VALUE); safecall;
  (** SciterSetValue - set value of the element.
   * \param[in] he \b HELEMENT, element which value will be changed.
   * \param[in] pval \b VALUE*, pointer to the VALUE to set. 
   **)
  TSciterSetValue = procedure (he: HELEMENT; const pval: SCITER_VALUE); safecall;
  (** SciterGetExpando - get 'expando' of the element. 'expando' is a scripting object (of class Element) 
   *  that is assigned to the DOM element. 'expando' could be null as they are created on demand by script.
   * \param[in] he \b HELEMENT, element which expando will be retrieved.
   * \param[out] pval \b VALUE*, pointer to VALUE that will get value of type T_OBJECT/UT_OBJECT_NATIVE or null. 
   * \param[in] forceCreation \b BOOL, if there is no expando then when forceCreation==TRUE the function will create it.
   *  ATTN: if you are not using json::value wrapper then you shall call ValueClear aginst the returned value
   *        otherwise it will leak memory.
   **)
  TSciterGetExpando = procedure (he: HELEMENT; var pval: SCITER_VALUE; forceCreation: BOOL); safecall;
  (** SciterGetObject - get 'expando' object of the element. 'expando' is a scripting object (of class Element) 
   *  that is assigned to the DOM element. 'expando' could be null as they are created on demand by script.
   * \param[in] he \b HELEMENT, element which expando will be retrieved.
   * \param[out] pval \b tiscript::value*, pointer to tiscript::value that will get reference to the scripting object associated wuth the element or null. 
   * \param[in] forceCreation \b BOOL, if there is no expando then when forceCreation==TRUE the function will create it.
   *
   *  ATTN!: if you plan to store the reference or use it inside code that calls script VM functions 
   *         then you should use tiscript::pinned holder for the value.
   **)
  TSciterGetObject = procedure (he: HELEMENT; var pval: tiscript_value; forceCreation: BOOL); safecall;
  (** SciterGetElementNamespace - get namespace of document of the DOM element.
   * \param[in] he \b HELEMENT, element which expando will be retrieved.
   * \param[out] pval \b tiscript::value*, pointer to tiscript::value that will get reference to the namespace scripting object. 
   *
   *  ATTN!: if you plan to store the reference or use it inside code that calls script VM functions 
   *         then you should use tiscript::pinned holder for the value.
   **)
  TSciterGetElementNamespace = function (he: HELEMENT): tiscript_value; safecall;
  // get/set highlighted element. Used for debugging purposes.
  TSciterGetHighlightedElement = function (hwnd: HWINDOW): HELEMENT; safecall;
  TSciterSetHighlightedElement = procedure (hwnd: HWINDOW; he: HELEMENT); safecall;

  // ATTENTION: node handles returned by functions below are not AddRef'ed
  TSciterNodeAddRef = procedure (hn: HNODE); safecall;
  TSciterNodeRelease = procedure (hn: HNODE); safecall;
  TSciterNodeCastFromElement = function (he: HELEMENT): HNODE; safecall;
  TSciterNodeCastToElement = function (hn: HNODE): HELEMENT; safecall;
  TSciterNodeFirstChild = function (hn: HNODE): HNODE; safecall;
  TSciterNodeLastChild = function (hn: HNODE): HNODE; safecall;
  TSciterNodeNextSibling = function (hn: HNODE): HNODE; safecall;
  TSciterNodePrevSibling = function (hn: HNODE): HNODE; safecall;
  TSciterNodeParent = function (hn: HNODE): HELEMENT; safecall;
  TSciterNodeNthChild = function (hn: HNODE; n: UINT): HNODE; safecall;
  TSciterNodeChildrenCount = function (hn: HNODE): UINT; safecall;
  TSciterNodeType = function (hn: HNODE): TNodeType{NODE_TYPE}; safecall;
  TSciterNodeGetText = procedure (hn: HNODE; rcv: LPCWSTR_RECEIVER; rcv_param: LPVOID); safecall;
  TSciterNodeSetText = procedure (hn: HNODE; text: LPCWSTR; textLength: UINT); safecall;
  TSciterNodeInsert = procedure (hn: HNODE; where: TNodeInsTarget; what: HNODE); safecall;
  // remove the node from the DOM, use finalize=FALSE if you plan to attach the node to the DOM later. 
  TSciterNodeRemove = procedure (hn: HNODE; finalize: BOOL); safecall;
  // ATTENTION: node handles returned by these two functions are AddRef'ed
  TSciterCreateTextNode = function (text: LPCWSTR; textLength: UINT): HNODE; safecall;
  TSciterCreateCommentNode = function (text: LPCWSTR; textLength: UINT): HNODE; safecall;

  (**
   * ValueInit - initialize VALUE storage
   * This call has to be made before passing VALUE* to any other functions
   *)
  TValueInit =  function (var pval: SCITER_VALUE): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueClear - clears the VALUE and deallocates all assosiated structures that are not used anywhere else.
   *)
  TValueClear = function (var pval: SCITER_VALUE): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueCompare - compares two values, returns HV_OK_TRUE if val1 == val2.
   *)
  TValueCompare = function (const pval1, pval2: SCITER_VALUE): Integer; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueCopy - copies src VALUE to dst VALUE. dst VALUE must be in ValueInit state.
   *)
  TValueCopy = function (var pdst: SCITER_VALUE; const psrc: SCITER_VALUE): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueIsolate - converts T_OBJECT value types to T_MAP or T_ARRAY.
   * use this method if you need to pass values between different threads.
   * The fanction is applicable for the Sciter 
   *)
  TValueIsolate = function (pdst: PSCITER_VALUE): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueType - returns VALUE_TYPE and VALUE_UNIT_TYPE flags of the VALUE
   *)
  TValueType = function (const pval: SCITER_VALUE; var pType: TDomValueType; var pUnits: UINT): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueStringData - returns string data for T_STRING type
   * For T_FUNCTION returns name of the fuction. 
   *)
  TValueStringData = function (const pval: SCITER_VALUE; var pChars: LPCWSTR; var pNumChars: UINT): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueStringDataSet - sets VALUE to T_STRING type and copies chars/numChars to
   * internal refcounted buffer assosiated with the value. 
   *)
  TValueStringDataSet = function (var pval: SCITER_VALUE; chars: LPCWSTR; numChars: UINT; units: UINT): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueIntData - retreive integer data of T_INT, T_LENGTH and T_BOOL types
   *)
  TValueIntData = function (const pval: SCITER_VALUE; var pData: Integer): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueIntDataSet - sets VALUE integer data of T_INT and T_BOOL types 
   * Optionally sets units field too.
   *)
  TValueIntDataSet = function (var pval: SCITER_VALUE; data: Integer; _type: TDomValueType; units: UINT): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueInt64Data - retreive 64bit integer data of T_CURRENCY and T_DATE values.
   *)
  TValueInt64Data = function (const pval: SCITER_VALUE; var pData: Int64): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueInt64DataSet - sets 64bit integer data of T_CURRENCY and T_DATE values.
   *)
  TValueInt64DataSet = function (var pval: SCITER_VALUE; data: Int64; _type: TDomValueType; units: UINT): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueFloatData - retreive FLOAT_VALUE (double) data of T_FLOAT and T_LENGTH values.
   *)
  TValueFloatData = function (const pval: SCITER_VALUE; var pData: FLOAT_VALUE): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueFloatDataSet - sets FLOAT_VALUE data of T_FLOAT and T_LENGTH values.
   *)
  TValueFloatDataSet = function (var pval: SCITER_VALUE; data: FLOAT_VALUE; _type: TDomValueType; uints: UINT): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueBinaryData - retreive integer data of T_BYTES type
   *)
  TValueBinaryData = function (const pval: SCITER_VALUE; var pBytes: LPCBYTE; var pnBytes: UINT): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueBinaryDataSet - sets VALUE to sequence of bytes of type T_BYTES 
   * 'type' here must be set to T_BYTES. Optionally sets units field too.
   * The function creates local copy of bytes in its own storage.
   *)
  TValueBinaryDataSet = function (var pval: SCITER_VALUE; pBytes: LPCBYTE; nBytes: UINT; _type: TDomValueType; units: UINT): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueElementsCount - retreive number of sub-elements for:
   * - T_ARRAY - number of elements in the array; 
   * - T_MAP - number of key/value pairs in the map;
   * - T_FUNCTION - number of arguments in the function;
   *)
  TValueElementsCount = function (const pval: SCITER_VALUE; var pn: UINT): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueNthElementValue - retreive value of sub-element at index n for:
   * - T_ARRAY - nth element of the array;
   * - T_MAP - value of nth key/value pair in the map;
   * - T_FUNCTION - value of nth argument of the function;
   *)
  TValueNthElementValue = function (const pval: SCITER_VALUE; n: Integer; var pretval: SCITER_VALUE): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueNthElementValueSet - sets value of sub-element at index n for:
   * - T_ARRAY - nth element of the array; 
   * - T_MAP - value of nth key/value pair in the map;
   * - T_FUNCTION - value of nth argument of the function;
   * If the VALUE is not of one of types above then it makes it of type T_ARRAY with 
   * single element - 'val_to_set'.
   *)
  TValueNthElementValueSet = function (var pval: SCITER_VALUE; n: Integer; const pval_to_set: SCITER_VALUE): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueEnumElements - enumeartes key/value pairs of T_MAP, T_FUNCTION and T_OBJECT values
   * - T_MAP - key of nth key/value pair in the map;
   * - T_FUNCTION - name of nth argument of the function (if any);
   *)
  TValueNthElementKey = function (const pval: SCITER_VALUE; n: Integer; var pretval: SCITER_VALUE): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  TValueEnumElements = function (const pval: SCITER_VALUE; penum: TKeyValueCallback; param: LPVOID): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueSetValueToKey - sets value of sub-element by key:
   * - T_MAP - value of key/value pair with the key;
   * - T_FUNCTION - value of argument with the name key;
   * - T_OBJECT (tiscript) - value of property of the object
   * If the VALUE is not of one of types above then it makes it of type T_MAP with 
   * single pair - 'key'/'val_to_set'.
   *
   * key usually is a value of type T_STRING
   *
   *)
  TValueSetValueToKey = function (var pval: SCITER_VALUE; const pkey, pval_to_set: SCITER_VALUE): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueGetValueOfKey - retrieves value of sub-element by key:
   * - T_MAP - value of key/value pair with the key;
   * - T_FUNCTION - value of argument with the name key;
   * - T_OBJECT (tiscript) - value of property of the object
   * Otherwise *pretval will have T_UNDEFINED value.
   *)
  TValueGetValueOfKey = function (const pval, pkey: SCITER_VALUE; var pretval: SCITER_VALUE): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueToString - converts value to T_STRING inplace:
   * - CVT_SIMPLE - parse/emit terminal values (T_INT, T_FLOAT, T_LENGTH, T_STRING)
   * - CVT_JSON_LITERAL - parse/emit value using JSON literal rules: {}, [], "string", true, false, null 
   * - CVT_JSON_MAP - parse/emit MAP value without enclosing '{' and '}' brackets.
   *)
  TValueToString = function (var pval: SCITER_VALUE; how: TDomValueStringCvtType): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueFromString - parses string into value:
   * - CVT_SIMPLE - parse/emit terminal values (T_INT, T_FLOAT, T_LENGTH, T_STRING), "guess" non-strict parsing
   * - CVT_JSON_LITERAL - parse/emit value using JSON literal rules: {}, [], "string", true, false, null 
   * - CVT_JSON_MAP - parse/emit MAP value without enclosing '{' and '}' brackets.
   * Returns:
   *   Number of non-parsed characters in case of errors. Thus if string was parsed in full it returns 0 (success)  
   *)
  TValueFromString = function (var pval: SCITER_VALUE; str: LPCWSTR; strLength: UINT; how: TDomValueStringCvtType): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueInvoke - function invocation (Sciter/TIScript).
   * - VALUE* pval is a value of type T_OBJECT/UT_OBJECT_FUNCTION
   * - VALUE* pthis - object that will be known as 'this' inside that function.
   * - UINT argc, const VALUE* argv - vector of arguments to pass to the function. 
   * - VALUE* pretval - parse/emit MAP value without enclosing '{' and '}' brackets.
   * - LPCWSTR url - url or name of the script - used for error reporting in the script.
   * Returns:
   *   HV_OK, HV_BAD_PARAMETER or HV_INCOMPATIBLE_TYPE
   *)
  TValueInvoke = function (const pval: SCITER_VALUE; pthis: PSCITER_VALUE; argc: UINT; const argv: PSCITER_VALUE_ARRAY; var pretval: SCITER_VALUE; url: LPCWSTR): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  (**
   * ValueNativeFunctorSet - set reference to native function
   * - VALUE* pval - value to be initialized
   * - NATIVE_FUNCTOR_INVOKE* pinvoke - reference to native functor implementation.
   * - NATIVE_FUNCTOR_RELEASE* prelease - reference to native functor dtor implementation.
   * - VOID* tag - optional tag, passed as it is to pinvoke and prelease
   * Returns:
   *   HV_OK, HV_BAD_PARAMETER or HV_INCOMPATIBLE_TYPE
   *)
  TValueNativeFunctorSet = function (const pval: PSCITER_VALUE; pinvoke: TNativeFunctorInvoke; prelease: TNativeFunctorRelease = nil; tag: Pointer = nil): UINT; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  TValueIsNativeFunctor = function (const pval: PSCITER_VALUE): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};

  // tiscript VM API
  TTIScriptAPI =  function (): Ptiscript_native_interface; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  TSciterGetVM = function (hwnd: HWINDOW): HVM; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};

  // conversion between script (managed) value and the VALUE ( com::variant alike thing )
  TSciter_T2S = function (vm: HVM; const script_value: tiscript_value; out_value: PSCITER_VALUE; isolate: BOOL): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  TSciter_S2T = function (vm: HVM; const valuev: PSCITER_VALUE; var out_script_value: tiscript_value): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};

  TSciterOpenArchive = function (archiveData: LPCBYTE; archiveDataLength: UINT): HSARCHIVE; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  TSciterGetArchiveItem = function (harc: HSARCHIVE; path: LPCWSTR; var pdata: LPCBYTE; var pdataLength: UINT): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  TSciterCloseArchive = function (harc: HSARCHIVE): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};

  (** SciterFireEvent - sends or posts sinking/bubbling event to the child/parent chain of specified element.
      First event will be send in SINKING mode (with SINKING flag) - from root to element itself.
      Then from element to its root on parents chain without SINKING flag (bubbling phase).

   * \param[in] evt \b BEHAVIOR_EVENT_PARAMS, pointer to event param block
   * \param[in] post \b BOOL, \c TRUE to post event asynchronously, \c FALSE otherwise
   * \param[out] handled \b BOOL*, variable to receive TRUE if any handler handled it, FALSE otherwise.

   **)
  TSciterFireEvent = function (const evt: TBehaviorEventParams; post: BOOL): BOOL; safecall;

  TSciterGetCallbackParam = function (hwnd: HWINDOW): LPVOID; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  TSciterPostCallback = function (hwnd: HWINDOW; wparam: UINT_PTR; lparam: UINT_PTR; timeoutms: UINT): UINT_PTR; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};

  TGetSciterGraphicsAPI = function (): PSciterGraphicsAPI; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  TGetSciterRequestAPI = function (): LPSciterRequestAPI; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};

  TSciterProcX = function (hwnd: HWINDOW; pMsg: PSCITER_X_MSG): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF}; // returns TRUE if handled

  _ISciterAPI  = record
    version: UINT; // is zero for now

    SciterClassName: TSciterClassName;
    SciterVersion: TSciterVersion;
    SciterDataReady: TSciterDataReady;
    SciterDataReadyAsync: TSciterDataReadyAsync;

  {$IFDEF WINDOWS}
    SciterProc: TSciterProc;
    SciterProcND: TSciterProcND;
  {$ENDIF}

    SciterLoadFile: TSciterLoadFile;
    SciterLoadHtml: TSciterLoadHtml;

    SciterSetCallback: TSciterSetCallback;

    SciterSetMasterCSS: TSciterSetMasterCSS;
    SciterAppendMasterCSS: TSciterAppendMasterCSS;

    SciterSetCSS: TSciterSetCSS;
    SciterSetMediaType: TSciterSetMediaType;
    SciterSetMediaVars: TSciterSetMediaVars;

    SciterGetMinWidth: TSciterGetMinWidth;
    SciterGetMinHeight: TSciterGetMinHeight;

    SciterCall: TSciterCall;
    SciterEval: TSciterEval;
    
    SciterUpdateWindow: TSciterUpdateWindow;
  {$IFDEF WINDOWS}
    SciterTranslateMessage: TSciterTranslateMessage;
  {$ENDIF}
    SciterSetOption: TSciterSetOption;
    SciterGetPPI: TSciterGetPPI;

    SciterGetViewExpando: TSciterGetViewExpando;
   // SciterEnumUrlData: TSciterEnumUrlData;

  {$IFDEF WINDOWS}
    SciterRenderD2D: TSciterRenderD2D;
    SciterD2DFactory: TSciterD2DFactory;
    SciterDWFactory: TSciterDWFactory;
  {$ENDIF}
    SciterGraphicsCaps: TSciterGraphicsCaps;
    SciterSetHomeURL: TSciterSetHomeURL;
  {$IFDEF OSX}
    SciterCreateNSView: TSciterCreateNSView; // returns NSView*
  {$ENDIF}

    SciterCreateWindow: TSciterCreateWindow;

    SciterSetupDebugOutput: TSciterSetupDebugOutput;
//    SciterDebugSetupClient: TSciterDebugSetupClient;
//    SciterDebugAddBreakpoint: TSciterDebugAddBreakpoint;
//    SciterDebugRemoveBreakpoint: TSciterDebugRemoveBreakpoint;
//    SciterDebugEnumBreakpoints: TSciterDebugEnumBreakpoints;

  //|
  //| DOM Element API 
  //|
    Sciter_UseElement: TSciter_UseElement;
    Sciter_UnuseElement: TSciter_UnuseElement;
    SciterGetRootElement: TSciterGetRootElement;
    SciterGetFocusElement: TSciterGetFocusElement;
    SciterFindElement: TSciterFindElement;
    SciterGetChildrenCount: TSciterGetChildrenCount;
    SciterGetNthChild: TSciterGetNthChild;
    SciterGetParentElement: TSciterGetParentElement;
    SciterGetElementHtmlCB: TSciterGetElementHtmlCB;
    SciterGetElementTextCB: TSciterGetElementTextCB;
    SciterSetElementText: TSciterSetElementText;
    SciterGetAttributeCount: TSciterGetAttributeCount;
    SciterGetNthAttributeNameCB: TSciterGetNthAttributeNameCB;
    SciterGetNthAttributeValueCB: TSciterGetNthAttributeValueCB;
    SciterGetAttributeByNameCB: TSciterGetAttributeByNameCB;
    SciterSetAttributeByName: TSciterSetAttributeByName;
    SciterClearAttributes: TSciterClearAttributes;
    SciterGetElementIndex: TSciterGetElementIndex;
    SciterGetElementType: TSciterGetElementType;
    SciterGetElementTypeCB: TSciterGetElementTypeCB;
    SciterGetStyleAttributeCB: TSciterGetStyleAttributeCB;
    SciterSetStyleAttribute: TSciterSetStyleAttribute;
    SciterGetElementLocation: TSciterGetElementLocation;
    SciterScrollToView: TSciterScrollToView;
    SciterUpdateElement: TSciterUpdateElement;
    SciterRefreshElementArea: TSciterRefreshElementArea;
    SciterSetCapture: TSciterSetCapture;
    SciterReleaseCapture: TSciterReleaseCapture;
    SciterGetElementHwnd: TSciterGetElementHwnd;
    SciterCombineURL: TSciterCombineURL;
    SciterSelectElements: TSciterSelectElements;
    SciterSelectElementsW: TSciterSelectElementsW;
    SciterSelectParent: TSciterSelectParent;
    SciterSelectParentW: TSciterSelectParentW;
    SciterSetElementHtml: TSciterSetElementHtml;
    SciterGetElementUID: TSciterGetElementUID;
    SciterGetElementByUID: TSciterGetElementByUID;
    SciterShowPopup: TSciterShowPopup;
    SciterShowPopupAt: TSciterShowPopupAt;
    SciterHidePopup: TSciterHidePopup;
    SciterGetElementState: TSciterGetElementState;
    SciterSetElementState: TSciterSetElementState;
    SciterCreateElement: TSciterCreateElement;
    SciterCloneElement: TSciterCloneElement;
    SciterInsertElement: TSciterInsertElement;
    SciterDetachElement: TSciterDetachElement;
    SciterDeleteElement: TSciterDeleteElement;
    SciterSetTimer: TSciterSetTimer;
    SciterDetachEventHandler: TSciterDetachEventHandler;
    SciterAttachEventHandler: TSciterAttachEventHandler;
    SciterWindowAttachEventHandler: TSciterWindowAttachEventHandler;
    SciterWindowDetachEventHandler: TSciterWindowDetachEventHandler;
    SciterSendEvent: TSciterSendEvent;
    SciterPostEvent: TSciterPostEvent;
    SciterCallBehaviorMethod: TSciterCallBehaviorMethod;
    SciterRequestElementData: TSciterRequestElementData;
    SciterHttpRequest: TSciterHttpRequest;
    
    SciterGetScrollInfo: TSciterGetScrollInfo;
    SciterSetScrollPos: TSciterSetScrollPos;
    SciterGetElementIntrinsicWidths: TSciterGetElementIntrinsicWidths;
    SciterGetElementIntrinsicHeight: TSciterGetElementIntrinsicHeight;
    SciterIsElementVisible: TSciterIsElementVisible;
    SciterIsElementEnabled: TSciterIsElementEnabled;
    SciterSortElements: TSciterSortElements;
    SciterSwapElements: TSciterSwapElements;
    SciterTraverseUIEvent: TSciterTraverseUIEvent;
    SciterCallScriptingMethod: TSciterCallScriptingMethod;
    SciterCallScriptingFunction: TSciterCallScriptingFunction;
    SciterEvalElementScript: TSciterEvalElementScript;
    SciterAttachHwndToElement: TSciterAttachHwndToElement;
    SciterControlGetType: TSciterControlGetType;
    SciterGetValue: TSciterGetValue;
    SciterSetValue: TSciterSetValue;
    SciterGetExpando: TSciterGetExpando;
    SciterGetObject: TSciterGetObject;
    SciterGetElementNamespace: TSciterGetElementNamespace;
    SciterGetHighlightedElement: TSciterGetHighlightedElement;
    SciterSetHighlightedElement: TSciterSetHighlightedElement;

  ////|
  ////| DOM Node API
  ////|
    SciterNodeAddRef: TSciterNodeAddRef;
    SciterNodeRelease: TSciterNodeRelease;
    SciterNodeCastFromElement: TSciterNodeCastFromElement;
    SciterNodeCastToElement: TSciterNodeCastToElement;
    SciterNodeFirstChild: TSciterNodeFirstChild;
    SciterNodeLastChild: TSciterNodeLastChild;
    SciterNodeNextSibling: TSciterNodeNextSibling;
    SciterNodePrevSibling: TSciterNodePrevSibling;
    SciterNodeParent: TSciterNodeParent;
    SciterNodeNthChild: TSciterNodeNthChild;
    SciterNodeChildrenCount: TSciterNodeChildrenCount;
    SciterNodeType: TSciterNodeType;
    SciterNodeGetText: TSciterNodeGetText;
    SciterNodeSetText: TSciterNodeSetText;
    SciterNodeInsert: TSciterNodeInsert;
    SciterNodeRemove: TSciterNodeRemove;
    SciterCreateTextNode: TSciterCreateTextNode;
    SciterCreateCommentNode: TSciterCreateCommentNode;
  ////|
  ////| Value API 
  ////|
    ValueInit:  TValueInit;
    ValueClear: TValueClear;
    ValueCompare: TValueCompare;
    ValueCopy: TValueCopy;
    ValueIsolate: TValueIsolate;
    ValueType: TValueType;
    ValueStringData: TValueStringData;
    ValueStringDataSet: TValueStringDataSet;
    ValueIntData: TValueIntData;
    ValueIntDataSet: TValueIntDataSet;
    ValueInt64Data: TValueInt64Data;
    ValueInt64DataSet: TValueInt64DataSet;
    ValueFloatData: TValueFloatData;
    ValueFloatDataSet: TValueFloatDataSet;
    ValueBinaryData: TValueBinaryData;
    ValueBinaryDataSet: TValueBinaryDataSet;
    ValueElementsCount: TValueElementsCount;
    ValueNthElementValue: TValueNthElementValue;
    ValueNthElementValueSet: TValueNthElementValueSet;
    ValueNthElementKey: TValueNthElementKey;
    ValueEnumElements: TValueEnumElements;
    ValueSetValueToKey: TValueSetValueToKey;
    ValueGetValueOfKey: TValueGetValueOfKey;
    ValueToString: TValueToString;
    ValueFromString: TValueFromString;
    ValueInvoke: TValueInvoke;
    ValueNativeFunctorSet: TValueNativeFunctorSet;
    ValueIsNativeFunctor: TValueIsNativeFunctor;


    // tiscript VM API
    TIScriptAPI: TTIScriptAPI;
    SciterGetVM: TSciterGetVM;

    // conversion between script (managed) value and the VALUE ( com::variant alike thing )
    Sciter_T2S: TSciter_T2S;
    Sciter_S2T: TSciter_S2T;

    SciterOpenArchive: TSciterOpenArchive;
    SciterGetArchiveItem: TSciterGetArchiveItem;
    SciterCloseArchive: TSciterCloseArchive;

    SciterFireEvent: TSciterFireEvent;

    SciterGetCallbackParam: TSciterGetCallbackParam;
    SciterPostCallback: TSciterPostCallback;

    GetSciterGraphicsAPI: TGetSciterGraphicsAPI;
    GetSciterRequestAPI: TGetSciterRequestAPI;
{$IFDEF WINDOWS}
    SciterCreateOnDirectXWindow: TSciterCreateOnDirectXWindow;
    SciterRenderOnDirectXWindow: TSciterRenderOnDirectXWindow;
    SciterRenderOnDirectXTexture: TSciterRenderOnDirectXTexture;
{$ENDIF}
    SciterProcX: TSciterProcX;
  end;
  ISciterAPI = _ISciterAPI;
  PISciterAPI = ^ISciterAPI;

  { Exceptions }
  ESciterException = class(Exception)
  end;
  ESciterNullPointerException = class(ESciterException)
  public
    constructor Create;
  end;
  ESciterCallException = class(ESciterException)
  public
    constructor Create(const MethodName: String);
  end;

var
  SciterDLLFile: SciterString = SCITER_DLL_NAME;

function SAPI(const ext: PISciterAPI = nil): PISciterAPI;
procedure FreeSAPI;

function SciterModulePath: string;
function SciterMainModulePath: string;

{ Conversion functions. Mnemonics are: T - tiscript_value, S - TSciterValue, V - VARIANT }
function  S2V(var Value: SCITER_VALUE; var OleValue: OleVariant; vm: HVM; ReturnType: PPTypeInfo = nil): UINT;
function  V2S(const SCITER_VALUE: OleVariant; var SciterValue: SCITER_VALUE; vm: HVM; ReturnType: PPTypeInfo = nil): UINT;
function  GetNativeObjectJson(var Value: SCITER_VALUE): SciterString;

procedure Log(const ALog: string);
procedure LogFmt(const ALog: string; const Args: array of const);
procedure Trace(const ALog: string);
procedure TraceFmt(const ALog: string; const Args: array of const);
procedure TraceError(const AMsg: string);
procedure TraceWarnning(const AMsg: string);
procedure TraceException(const AMsg: string);

function HTTPEncode(const AStr: SciterString): SciterString;
function HTTPDecode(const AStr: SciterString): SciterString;
function EncodeURI(const WS: SciterString): SciterString;

function ShellExecuteW(hWnd: HWND; Operation, FileName, Parameters,
  Directory: PWideChar; ShowCmd: Integer): HINST; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF} external 'shell32.dll' name 'ShellExecuteW';

procedure _LPCWSTR2String(str: LPCWSTR; str_length: UINT; param: LPVOID); {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF}
procedure _LPCBYTE2AString(bytes: LPCBYTE; num_bytes: UINT; param: LPVOID); {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF}
procedure _LPCSTR2String(str: LPCSTR; str_length: UINT; param: LPVOID); {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF}

{$IF CompilerVersion <= 18.5}
function CharInSet(const C: WideChar; const CharSet: TSysCharSet): Boolean;
{$IFEND}
function FastFileExists(const AFileName: WideString): Boolean;
function GetDPI: Cardinal;

implementation



var
  _LogLock: TRTLCriticalSection;
  _api: PISciterAPI = nil;
  _SciterModulePath: string;
  _SciterMainModulePath: string;
  _hm: HMODULE = 0;

type
  SciterAPI_ptr = function ():PISciterAPI; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
function SAPI(const ext: PISciterAPI): PISciterAPI;
var
  sciterAPI: SciterAPI_ptr;
begin
  if ext <> nil then
    _api := ext
  else
  if _api = nil then
  begin
    _hm := LoadLibraryW(PWideChar(SciterDLLFile));
    if _hm <> 0 then
    begin
      @sciterAPI := GetProcAddress(_hm, 'SciterAPI');
      if @sciterAPI <> nil then
      begin
        _api := sciterAPI;
        ni(_api.TIScriptAPI);
        GAPI(_api.GetSciterGraphicsAPI)
      end
      else
      begin
        FreeLibrary(_hm);
        _hm := 0;
      end;
    end
    else
      TraceFmt('[SAPI][%d]%s', [GetLastError, SysErrorMessage(GetLastError)]);
  end;

  Result := _api;
end;

procedure FreeSAPI;
begin
  if _hm <> 0 then
  try
    _api := nil;
    FreeLibrary(_hm);
    _hm := 0;
  except
  end;  
end;

function SciterModulePath: string;
begin
  if _SciterModulePath = '' then
    _SciterModulePath := ExtractFilePath(GetModuleName(HInstance));
  Result := _SciterModulePath;
end;

function SciterMainModulePath: string;
begin
  if _SciterMainModulePath = '' then
    _SciterMainModulePath := ExtractFilePath(GetModuleName(MainInstance));
  Result := _SciterMainModulePath;
end;

procedure Trace(const ALog: string);
var
  f: textfile;
  sLogFile: SciterString;
begin
  EnterCriticalSection(_LogLock);
  try
    if {$WARNINGS OFF} DebugHook = 1 {$WARNINGS ON} then
      OutputDebugString(PChar(ALog))
    else
    try
      sLogFile := ChangeFileExt(ParamStr(0), '_' + FormatDateTime('YYYYMM', Date) + '.log');
      ForceDirectories(ExtractFilePath(sLogFile));
      AssignFile(f, sLogFile);
      try
        if FastFileExists(sLogFile) then
          Append(f)
        else
          Rewrite(f);

        Writeln(f, Format('【%s】%s', [FormatDateTime('yyyy-mm-dd hh:nn:ss', Now), ALog]));
      finally
        CloseFile(f);
      end;
    except
      on e: Exception do
      begin
        OutputDebugString(PChar('[_NativeTrace]'+e.Message));
      end;
    end;
  finally
    LeaveCriticalSection(_LogLock);
  end;
end;

procedure TraceFmt(const ALog: string; const Args: array of const);
begin
  Trace(Format(ALog, Args));
end;

procedure TraceError(const AMsg: string);
begin
  Trace('[error]'+AMsg);
end;

procedure TraceWarnning(const AMsg: string);
begin
  Trace('[warnning]'+AMsg);
end;

procedure TraceException(const AMsg: string);
begin
  Trace('[exception]'+AMsg);
end;

procedure Log(const ALog: string);
begin
  OutputDebugString(PChar(ALog));
end;

procedure LogFmt(const ALog: string; const Args: array of const);
begin
  Log(Format(ALog, Args));
end;

function GetNativeObjectJson(var Value: SCITER_VALUE): SciterString;
var
  pWStr: PWideChar;
  iNum: UINT;
  pType: TDomValueType;
  pUnits: UINT;
begin
  pUnits := 0;
  SAPI.ValueType(Value, pType, pUnits);
  if (pType = T_NULL) or (pType = T_UNDEFINED) then
  begin
    Result := '';
    Exit;
  end;
  SAPI.ValueToString(Value, CVT_JSON_LITERAL);
  SAPI.ValueStringData(Value, pWStr, iNum);
  Result := StringReplace(pWstr, #9, '', [rfReplaceAll]);
end;         

{ SciterValue to Variant conversion }
function S2V(var Value: SCITER_VALUE; var OleValue: OleVariant; vm: HVM; ReturnType: PPTypeInfo): UINT;
var
  tValue: tiscript_value;
begin
  tValue := 0;     
  Assert(SAPI.Sciter_S2T(vm, @Value, tValue));
//  if ni.is_function(tValue) or ni.is_native_function(tValue) then
//  begin
//    OleValue := ValueFactory.Create(@Value);
//    Result := HV_OK;
//  end
//  else
  Result := T2V(vm, tValue, OleValue, nil, ReturnType);
end;

{ Variant to SciterValue conversion }
function V2S(const SCITER_VALUE: OleVariant; var SciterValue: SCITER_VALUE; vm: HVM; ReturnType: PPTypeInfo): UINT;
var
  tValue: tiscript_value;
begin
  Assert(V2T(vm, SCITER_VALUE, tValue, ReturnType) = HV_OK);
  Assert(SAPI.Sciter_T2S(vm, tValue, @SciterValue, False));
  Result := HV_OK;
end;

function HTTPDecode(const AStr: SciterString): SciterString;
const
  sErrorDecodingURLText = 'Error decoding URL style (%%XX) encoded string at position %d';
  sInvalidURLEncodedChar = 'Invalid URL encoded character (%s) at position %d';
var
  Sp, Cp: PWideChar;
  S: string;
  sResult: UTF8String;
  Rp: PAnsiChar;
  L: Integer;
begin
  SetLength(sResult, (Length(AStr)+1)*3);
  Sp := PWideChar(AStr);
  Rp := PAnsiChar(sResult);
  Cp := Sp;
  try
    while Sp^ <> #0 do
    begin
      case Sp^ of
        '+': Rp^ := ' ';
        '%':
        begin
          // Look for an escaped % (%%) or %<hex> encoded character
          Inc(Sp);
          if Sp^ = '%' then
            Rp^ := '%'
          else
          begin
            Cp := Sp;
            Inc(Sp);
            if (Cp^ <> #0) and (Sp^ <> #0) then
            begin
              S := '$' + Char(Cp^) + Char(Sp^);
              Rp^ := AnsiChar(StrToInt(S));
            end
            else
              raise Exception.CreateFmt(sErrorDecodingURLText, [Cp - PWideChar(AStr)]);
          end;
        end;
      else
        if Word(Sp^) > 255 then
        begin
          L := WideCharToMultiByte(CP_UTF8, 0, Sp, 1, Rp, 4, nil, nil);
          Inc(Rp, L-1);
        end
        else
          Rp^ := AnsiChar(Sp^);
      end;
      Inc(Rp);
      Inc(Sp);
    end;
  except
    on E:EConvertError do
      raise EConvertError.CreateFmt(sInvalidURLEncodedChar,
        ['%' + Char(Cp^) + Char(Sp^), Cp - PWideChar(AStr)])
  end;
  SetLength(sResult, Rp - PAnsiChar(sResult));
  Result := {$IF CompilerVersion > 18.5}UTF8ToString{$ELSE}UTF8Decode{$IFEND}(sResult);
end;

function HTTPEncode(const AStr: SciterString): SciterString;
const
  NoConversion = ['A'..'Z','a'..'z','*','@','.','_','-',
                  '0'..'9','$','!','''','(',')'];
var
  Sp: PAnsiChar;
  Rp: PChar;
  sStr: UTF8String;
  sResult: string;
begin
  sStr := UTF8Encode(AStr);
  SetLength(sResult, Length(sStr) * 3);
  Sp := PAnsiChar(sStr);
  Rp := PChar(sResult);
  while Sp^ <> #0 do
  begin
    if Sp^ in NoConversion then
      Rp^ := Char(Sp^)
    else
//    if Sp^ = ' ' then
//      Rp^ := '+'
//    else
    begin
      FormatBuf(Rp{$IF CompilerVersion <= 18.5}^{$IFEND}, 3, '%%%.2x', 6, [Ord(Sp^)]);
      Inc(Rp, 2);
    end;
    Inc(Rp);
    Inc(Sp);
  end;
  SetLength(sResult, Rp - PChar(sResult));
  Result := sResult;
end;

function EncodeURI(const WS: SciterString): SciterString;
  function IsMultiByte(const Str: PWideChar; const Index: Cardinal): Boolean;
  begin
    Result := Word(Str[Index]) > 128;
  end;
var
  i, iLen: Integer;
  s1, sResult: SciterString;
  p: PWideChar;
begin
  iLen := Length(WS);
  p := PWideChar(WS);
  i := 0;
  while i < iLen do
  begin
    case IsMultiByte(p, i) of
      False:
      begin
        if s1 <> '' then
        begin
          sResult := sResult + HTTPEncode(s1);
          s1 := '';
        end;
        sResult := sResult + p[i];
        i := i + 1;
      end;
      True:
      begin
        s1 := s1 + p[i];
        i := i + 1;
      end;
    end;
  end;
  if s1 <> EmptyStr then
  begin
    sResult := sResult + HTTPEncode(s1);
    s1 := EmptyStr;
  end;
  Result := sResult;
end;

procedure _LPCWSTR2String(str: LPCWSTR; str_length: UINT; param: LPVOID); {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF}
var
  sResult: PSciterString;
begin
  sResult := PSciterString(param);
  sResult^ := str;
end;

procedure _LPCBYTE2AString(bytes: LPCBYTE; num_bytes: UINT; param: LPVOID); {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF}
var
  sResult: SciterTypes.PBytes;
begin
  sResult := SciterTypes.PBytes(param);
  SetLength(sResult^, num_bytes+1);
  CopyMemory(@sResult, bytes, num_bytes);
  sResult^[num_bytes] := 0;
end;

procedure _LPCSTR2String(str: LPCSTR; str_length: UINT; param: LPVOID); {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF}
var
  sResult: PSciterString;
begin
  sResult := PSciterString(param);
  sResult^ := {$IF CompilerVersion > 18.5}UTF8ToString{$ELSE}UTF8Decode{$IFEND}(str);
end;

{$IF CompilerVersion <= 18.5}
function CharInSet(const C: WideChar; const CharSet: TSysCharSet): Boolean;
begin
  Result := AnsiChar(C) in CharSet;
end;
{$IFEND}

function FastFileExists(const AFileName: WideString): Boolean;
var
  attrs: TWin32FileAttributeData;
begin
  Result := GetFileAttributesExW(PWideChar(AFileName), GetFileExInfoStandard, @attrs);
end;

function GetDPI: Cardinal;
var
  DC: HDC;
begin
  DC := GetDC(0);
  Result := GetDeviceCaps(DC, logpixelsx);
  ReleaseDC(0, DC);
end;

function DpToPx(const dp: Cardinal): Cardinal;
begin
  Result := Round(dp * GetDPI / 160);
end;

function PxToDp(const px: Cardinal): Cardinal;
begin
  Result := Round(px * 160 / GetDPI);
end;

{ ESciterNullPointerException }

constructor ESciterNullPointerException.Create;
begin
  inherited Create('The argument cannot be null.');
end;

{ ESciterCallException }

constructor ESciterCallException.Create(const MethodName: String);
begin
  inherited CreateFmt('Method "%s" call failed.', [MethodName]);
end;

var
  wSave8087CW: Word;
initialization
{$IFDEF WINDOWS}
{$WARNINGS OFF}
  wSave8087CW := Default8087CW;
  Set8087CW(wSave8087CW or $3F);
{$WARNINGS ON}
{$ENDIF}
  InitializeCriticalSection(_LogLock);

finalization
  DeleteCriticalSection(_LogLock);
{$IFDEF WINDOWS}
  Set8087CW(wSave8087CW);
{$ENDIF}

end.
