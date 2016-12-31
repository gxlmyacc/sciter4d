{*******************************************************************************
 标题:     TiscriptTypes.pas
 描述:     Tiscript类型定义单元
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit TiscriptTypes;

interface

uses
  Windows, SciterTypes;

type
  // pinned tiscript_value, val here will survive GC.
  tiscript_pvalue = record
   val: tiscript_value;
   vm:  HVM;
   d1:  Pointer;
   d2:  Pointer;
  end;
  Ptiscript_pvalue = ^tiscript_pvalue;

  // native method implementation
  tiscript_method = function (vm: HVM): tiscript_value; cdecl;
  ptiscript_method = ^tiscript_method;

  // Each function call has at least two parameters:
  //    arg[0] -> 'this' - object or namespace object for 'static' functions.
  //    arg[1] -> 'super' - usually you will just args::skip it.
  //    arg[2..argc] -> params defined in script
  tiscript_tagged_method = function (vm: HVM; self: tiscript_value; tag: Pointer): tiscript_value; cdecl;

  { TIScript method definition }
  tiscript_method_def = record
    dispatch: Pointer;         // a.k.a. VTBL
    name:     PAnsiChar;
    handler:  Pointer;         // can be either tiscript_method or tiscript_tagged_method if tag is not 0
    tag:      Pointer;
    payload:  tiscript_value;  // must be zero
  end;
  Ptiscript_method_def = ^tiscript_method_def;

  tiscript_method_rec = record
    vm:  HVM;
    Handler: Pointer;  //tiscript_native_method;
    tag: Pointer;
    def: tiscript_method_def;
  end;
  Ptiscript_method_rec = ^tiscript_method_rec;

  tiscript_method_def_array = array[0..0] of tiscript_method_def;
  ptiscript_method_def_array = ^tiscript_method_def_array;

  // [] accessors implementation
  tiscript_get_item = function (c: HVM; obj, key: tiscript_value): tiscript_value; cdecl;
  tiscript_set_item = procedure (c: HVM; obj, key, tiscript_value: tiscript_value); cdecl;

  // getter/setter implementation
  tiscript_get_prop = function (c: HVM; obj: tiscript_value): tiscript_value; cdecl;
  tiscript_set_prop = procedure (c: HVM; obj, tiscript_value: tiscript_value); cdecl;

  tiscript_tagged_get_prop = function(c: HVM; this: tiscript_value; tag: Pointer): tiscript_value; cdecl;
  tiscript_tagged_set_prop = procedure(c: HVM; this: tiscript_value; value: tiscript_value; tag: Pointer); cdecl;

  // iterator function used in for(var el in collection)
  tiscript_iterator = function (c: HVM; index: ptiscript_value; obj: tiscript_value): tiscript_value; cdecl;
  ptiscript_iterator = ^tiscript_iterator;
  
  // callbacks for enums below
  // true - continue enumeartion
  tiscript_object_enum = function (c: HVM; key, tiscript_value: tiscript_value; tag: Pointer): Boolean; cdecl;

  // destructor of native objects
  tiscript_finalizer = procedure (c: HVM; obj: tiscript_value); cdecl;

  // GC notifier for native objects
  tiscript_on_gc_copy = procedure (instance_data: Pointer; new_self: tiscript_value); cdecl;

  // callback used for
  tiscript_callback = procedure (c: HVM; prm: Pointer); cdecl;

  { TIScript property definition }
  tiscript_prop_def = record
    dispatch: Pointer; // a.k.a. VTBL
    name:     PAnsiChar;
    getter:   tiscript_get_prop;
    setter:   tiscript_set_prop;
    tag:      Pointer;
  end;
  Ptiscript_prop_def = ^tiscript_prop_def;

const
  TISCRIPT_CONST_INT    = 0;
  TISCRIPT_CONST_FLOAT  = 1;
  TISCRIPT_CONST_STRING = 2;

type
  _Val = record
    case Integer of
      0: (i: Integer);
      1: (f: double);
      2: (str: PWideChar);
  end;

  tiscript_const_def = record
    name: PAnsiChar;
    var_: _Val;
    type_: UINT;
  end;
  Ptiscript_const_def = ^tiscript_const_def;

  { TOScript class definition }
  tiscript_class_def = record
    name:       PAnsiChar;            // having this name
    methods:    Ptiscript_method_def; // with these methods
    props:      Ptiscript_prop_def;   // with these properties
    consts:     Ptiscript_const_def;  // with these constants (if any)
    get_item:   tiscript_get_item;    // var v = obj[idx]
    set_item:   tiscript_set_item;    // obj[idx] = v
    finalizer:  tiscript_finalizer;   // destructor of native objects
    iterator:   tiscript_iterator;    // for(var el in collecton) handler
    on_gc_copy: tiscript_on_gc_copy;  // called by GC to notify that 'self' is moved to new location
    prototype:  tiscript_value;       // superclass, prototype for the class (or 0)

    // added by da-baranov to simplify memory management
    methodsc:   UINT; // including null-terminated record
    propsc:     UINT; // including null-terminated record
  end;
  ptiscript_class_def = ^tiscript_class_def;

  TTiscriptMethodType = (Method, NonIndexedProperty, IndexedProperty);

type
  Ptiscript_stream = ^tiscript_stream;
  
  tiscript_stream_input  = function (tag: Ptiscript_stream; pv: PInteger): Boolean; cdecl;
  tiscript_stream_output = function (tag: Ptiscript_stream; v: Integer): Boolean; cdecl;
  tiscript_stream_name   = function (tag: Ptiscript_stream): PWideChar; cdecl;
  tiscript_stream_close  = procedure (tag: Ptiscript_stream); cdecl;

  tiscript_stream_vtbl = record // stream instance
    input:    tiscript_stream_input;
    output:   tiscript_stream_output;
    get_name: tiscript_stream_name;
    close:    tiscript_stream_close;
  end;
  Ptiscript_stream_vtbl = ^tiscript_stream_vtbl;

  tiscript_stream = record
    vtbl: Ptiscript_stream_vtbl;
    tag:  Pointer;
  end;

implementation

end.
