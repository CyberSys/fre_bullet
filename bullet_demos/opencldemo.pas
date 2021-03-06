unit OpenCLDemo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,glutstuff,gl,glu,glut,ctypes,dglOpenGL_tst
  {$IFDEF UNIX}
  ,MacOSAll,MacPas
  {$ENDIF}
  ;
{$MACRO ON}

{$IFDEF WINDOWS}
  {$DEFINE DYNLINK}
const
  OpenCLlib = 'OpenCL.dll';
  {$DEFINE extdecl := stdcall}
{$ELSE}
  //todo: LINUX
  {$IFDEF DARWIN}
  {$linkframework OpenCL}
  {$linkframework OpenGL}
  {$ENDIF}
  {$DEFINE extdecl := cdecl}
{$ENDIF}

 const
  CL_PLATFORM_NVIDIA  = $3001; // NVidia specific platform value

{* scalar types  *}

type
  intptr_t = PtrInt;

  cl_char     = cint8;
  cl_uchar    = cuint8;
  cl_short    = cint16;
  cl_ushort   = cuint16;
  cl_int      = cint32;
  cl_uint     = cuint32;
  cl_long     = cint64;
  cl_ulong    = cuint64;

  cl_half     = cuint16;
  cl_float    = cfloat;
  cl_double   = cdouble;

  Pcl_char     = ^cl_char;
  Pcl_uchar    = ^cl_uchar;
  Pcl_short    = ^cl_short;
  Pcl_ushort   = ^cl_ushort;
  Pcl_int      = ^cl_int;
  Pcl_uint     = ^cl_uint;
  Pcl_long     = ^cl_long;
  Pcl_ulong    = ^cl_ulong;

  Pcl_half     = ^cl_half;
  Pcl_float    = ^cl_float;
  Pcl_double   = ^cl_double;


const
  CL_CHAR_BIT         = 8;
  CL_SCHAR_MAX        = 127;
  CL_SCHAR_MIN        = (-127-1);
  CL_CHAR_MAX         = CL_SCHAR_MAX;
  CL_CHAR_MIN         = CL_SCHAR_MIN;
  CL_UCHAR_MAX        = 255;
  CL_SHRT_MAX         = 32767;
  CL_SHRT_MIN         = (-32767-1);
  CL_USHRT_MAX        = 65535;
  CL_INT_MAX          = 2147483647;
  CL_INT_MIN          = (-2147483647-1);
  CL_UINT_MAX         = $ffffffff;
  CL_LONG_MAX         = $7FFFFFFFFFFFFFFF;
  CL_LONG_MIN         = -$7FFFFFFFFFFFFFFF - 1;
  CL_ULONG_MAX        = $FFFFFFFFFFFFFFFF;

  CL_FLT_DIG          = 6;
  CL_FLT_MANT_DIG     = 24;
  CL_FLT_MAX_10_EXP   = +38;
  CL_FLT_MAX_EXP      = +128;
  CL_FLT_MIN_10_EXP   = -37;
  CL_FLT_MIN_EXP      = -125;
  CL_FLT_RADIX        = 2;
//  CL_FLT_MAX          = 0x1.fffffep127f;
//  CL_FLT_MIN          = 0x1.0p-126f;
//  CL_FLT_EPSILON      = 0x1.0p-23f;

  CL_DBL_DIG          = 15;
  CL_DBL_MANT_DIG     = 53;
  CL_DBL_MAX_10_EXP   = +308;
  CL_DBL_MAX_EXP      = +1024;
  CL_DBL_MIN_10_EXP   = -307;
  CL_DBL_MIN_EXP      = -1021;
  CL_DBL_RADIX        = 2;
// CL_DBL_MAX          0x1.fffffffffffffp1023
// CL_DBL_MIN          0x1.0p-1022
// CL_DBL_EPSILON      0x1.0p-52

{*
 * Vector types
 *
 *  Note:   OpenCL requires that all types be naturally aligned.
 *          This means that vector types must be naturally aligned.
 *          For example, a vector of four floats must be aligned to
 *          a 16 byte boundary (calculated as 4 * the natural 4-byte
 *          alignment of the float).  The alignment qualifiers here
 *          will only function properly if your compiler supports them
 *          and if you don't actively work to defeat them.  For example,
 *          in order for a cl_float4 to be 16 byte aligned in a struct,
 *          the start of the struct must itself be 16-byte aligned.
 *
 *          Maintaining proper alignment is the user's responsibility.
 *}
type
  cl_char2  = array [0..1] of cint8;
  cl_char4  = array [0..3] of cint8;
  cl_char8  = array [0..7] of cint8;
  cl_char16 = array [0..15] of cint8;

  cl_uchar2 = array [0..1] of cuint8;
  cl_uchar4 = array [0..3] of cuint8;
  cl_uchar8 = array [0..7] of cuint8;
  cl_uchar16 = array [0..15] of cuint8;

  cl_short2  = array [0..1] of cint16;
  cl_short4  = array [0..3] of cint16;
  cl_short8  = array [0..7] of cint16;
  cl_short16 = array [0..15] of cint16;

  cl_ushort2  = array [0..1] of cuint16;
  cl_ushort4  = array [0..3] of cuint16;
  cl_ushort8  = array [0..7] of cuint16;
  cl_ushort16 = array [0..15] of cuint16;

  cl_int2  = array [0..1] of cint32;
  cl_int4  = array [0..3] of cint32;
  cl_int8  = array [0..7] of cint32;
  cl_int16 = array [0..15] of cint32;

  cl_uint2  = array [0..1] of cuint32;
  cl_uint4  = array [0..3] of cuint32;
  cl_uint8  = array [0..7] of cuint32;
  cl_uint16 = array [0..15] of cuint32;

  cl_long2  = array [0..1] of cint64;
  cl_long4  = array [0..3] of cint64;
  cl_long8  = array [0..7] of cint64;
  cl_long16 = array [0..15] of cint64;

  cl_ulong2  = array [0..1] of cuint64;
  cl_ulong4  = array [0..3] of cuint64;
  cl_ulong8  = array [0..7] of cuint64;
  cl_ulong16 = array [0..15] of cuint64;

  cl_float2  = array [0..1] of cfloat;
  cl_float4  = array [0..3] of cfloat;
  cl_float8  = array [0..7] of cfloat;
  cl_float16 = array [0..15] of cfloat;

  cl_double2  = array [0..1] of cdouble;
  cl_double4  = array [0..3] of cdouble;
  cl_double8  = array [0..7] of cdouble;
  cl_double16 = array [0..15] of cdouble;

{* There are no vector types for half *}

// ****************************************************************************

{cl.h}

type
  _cl_platform_id   = record end;
  _cl_device_id     = record end;
  _cl_context       = record end;
  _cl_command_queue = record end;
  _cl_mem           = record end;
  _cl_program       = record end;
  _cl_kernel        = record end;
  _cl_event         = record end;
  _cl_sampler       = record end;

  cl_platform_id    = ^_cl_platform_id;
  cl_device_id      = ^_cl_device_id;
  cl_context        = ^_cl_context;
  cl_command_queue  = ^_cl_command_queue;
  cl_mem            = ^_cl_mem;
  cl_program        = ^_cl_program;
  cl_kernel         = ^_cl_kernel;
  cl_event          = ^_cl_event;
  cl_sampler        = ^_cl_sampler;

  Pcl_platform_id    = ^cl_platform_id;
  Pcl_device_id      = ^cl_device_id;
  Pcl_context        = ^cl_context;
  Pcl_command_queue  = ^cl_command_queue;
  Pcl_mem            = ^cl_mem;
  Pcl_program        = ^cl_program;
  Pcl_kernel         = ^cl_kernel;
  Pcl_event          = ^cl_event;
  Pcl_sampler        = ^cl_sampler;


  cl_bool = cl_uint; //  WARNING!  Unlike cl_ types in cl_platform.h, cl_bool is not guaranteed to be the same size as the bool in kernels.
  cl_bitfield                 = cl_ulong;
  cl_device_type              = cl_bitfield;
  cl_platform_info            = cl_uint;
  cl_device_info              = cl_uint;
  cl_device_address_info      = cl_bitfield;
  cl_device_fp_config         = cl_bitfield;
  cl_device_mem_cache_type    = cl_uint;
  cl_device_local_mem_type    = cl_uint;
  cl_device_exec_capabilities = cl_bitfield;
  cl_command_queue_properties = cl_bitfield;

  cl_context_properties   = intptr_t;
  cl_context_info         = cl_uint;
  cl_command_queue_info   = cl_uint;
  cl_channel_order        = cl_uint;
  cl_channel_type         = cl_uint;
  cl_mem_flags            = cl_bitfield;
  cl_mem_object_type      = cl_uint;
  cl_mem_info             = cl_uint;
  cl_image_info           = cl_uint;
  cl_addressing_mode      = cl_uint;
  cl_filter_mode          = cl_uint;
  cl_sampler_info         = cl_uint;
  cl_map_flags            = cl_bitfield;
  cl_program_info         = cl_uint;
  cl_program_build_info   = cl_uint;
  cl_build_status         = cl_int;
  cl_kernel_info            = cl_uint;
  cl_kernel_work_group_info = cl_uint;
  cl_event_info             = cl_uint;
  cl_command_type           = cl_uint;
  cl_profiling_info         = cl_uint;

  _cl_image_format = packed record
    image_channel_order     : cl_channel_order;
    image_channel_data_type : cl_channel_type;
  end;
  cl_image_format = _cl_image_format;

  Pcl_context_properties  = ^cl_context_properties;
  Pcl_image_format        = ^cl_image_format;

const
// Error Codes
  CL_SUCCESS                                  = 0;
  CL_DEVICE_NOT_FOUND                         = -1;
  CL_DEVICE_NOT_AVAILABLE                     = -2;
  CL_DEVICE_COMPILER_NOT_AVAILABLE            = -3;
  CL_MEM_OBJECT_ALLOCATION_FAILURE            = -4;
  CL_OUT_OF_RESOURCES                         = -5;
  CL_OUT_OF_HOST_MEMORY                       = -6;
  CL_PROFILING_INFO_NOT_AVAILABLE             = -7;
  CL_MEM_COPY_OVERLAP                         = -8;
  CL_IMAGE_FORMAT_MISMATCH                    = -9;
  CL_IMAGE_FORMAT_NOT_SUPPORTED               = -10;
  CL_BUILD_PROGRAM_FAILURE                    = -11;
  CL_MAP_FAILURE                              = -12;

  CL_INVALID_VALUE                            = -30;
  CL_INVALID_DEVICE_TYPE                      = -31;
  CL_INVALID_PLATFORM                         = -32;
  CL_INVALID_DEVICE                           = -33;
  CL_INVALID_CONTEXT                          = -34;
  CL_INVALID_QUEUE_PROPERTIES                 = -35;
  CL_INVALID_COMMAND_QUEUE                    = -36;
  CL_INVALID_HOST_PTR                         = -37;
  CL_INVALID_MEM_OBJECT                       = -38;
  CL_INVALID_IMAGE_FORMAT_DESCRIPTOR          = -39;
  CL_INVALID_IMAGE_SIZE                       = -40;
  CL_INVALID_SAMPLER                          = -41;
  CL_INVALID_BINARY                           = -42;
  CL_INVALID_BUILD_OPTIONS                    = -43;
  CL_INVALID_PROGRAM                          = -44;
  CL_INVALID_PROGRAM_EXECUTABLE               = -45;
  CL_INVALID_KERNEL_NAME                      = -46;
  CL_INVALID_KERNEL_DEFINITION                = -47;
  CL_INVALID_KERNEL                           = -48;
  CL_INVALID_ARG_INDEX                        = -49;
  CL_INVALID_ARG_VALUE                        = -50;
  CL_INVALID_ARG_SIZE                         = -51;
  CL_INVALID_KERNEL_ARGS                      = -52;
  CL_INVALID_WORK_DIMENSION                   = -53;
  CL_INVALID_WORK_GROUP_SIZE                  = -54;
  CL_INVALID_WORK_ITEM_SIZE                   = -55;
  CL_INVALID_GLOBAL_OFFSET                    = -56;
  CL_INVALID_EVENT_WAIT_LIST                  = -57;
  CL_INVALID_EVENT                            = -58;
  CL_INVALID_OPERATION                        = -59;
  CL_INVALID_GL_OBJECT                        = -60;
  CL_INVALID_BUFFER_SIZE                      = -61;
  CL_INVALID_MIP_LEVEL                        = -62;

// OpenCL Version
  CL_VERSION_1_0                              = 1;

// cl_bool
  CL_FALSE                                    = 0;
  CL_TRUE                                     = 1;

// cl_platform_info
  CL_PLATFORM_PROFILE                         = $0900;
  CL_PLATFORM_VERSION                         = $0901;
  CL_PLATFORM_NAME                            = $0902;
  CL_PLATFORM_VENDOR                          = $0903;
  CL_PLATFORM_EXTENSIONS                      = $0904;


// cl_device_type - bitfield
  CL_DEVICE_TYPE_DEFAULT                      = (1 shl 0);
  CL_DEVICE_TYPE_CPU                          = (1 shl 1);
  CL_DEVICE_TYPE_GPU                          = (1 shl 2);
  CL_DEVICE_TYPE_ACCELERATOR                  = (1 shl 3);
  CL_DEVICE_TYPE_ALL                          = $FFFFFFFF;

// cl_device_info
  CL_DEVICE_TYPE_INFO                         = $1000; // CL_DEVICE_TYPE
  CL_DEVICE_VENDOR_ID                         = $1001;
  CL_DEVICE_MAX_COMPUTE_UNITS                 = $1002;
  CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS          = $1003;
  CL_DEVICE_MAX_WORK_GROUP_SIZE               = $1004;
  CL_DEVICE_MAX_WORK_ITEM_SIZES               = $1005;
  CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR       = $1006;
  CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT      = $1007;
  CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT        = $1008;
  CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG       = $1009;
  CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT      = $100A;
  CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE     = $100B;
  CL_DEVICE_MAX_CLOCK_FREQUENCY               = $100C;
  CL_DEVICE_ADDRESS_BITS                      = $100D;
  CL_DEVICE_MAX_READ_IMAGE_ARGS               = $100E;
  CL_DEVICE_MAX_WRITE_IMAGE_ARGS              = $100F;
  CL_DEVICE_MAX_MEM_ALLOC_SIZE                = $1010;
  CL_DEVICE_IMAGE2D_MAX_WIDTH                 = $1011;
  CL_DEVICE_IMAGE2D_MAX_HEIGHT                = $1012;
  CL_DEVICE_IMAGE3D_MAX_WIDTH                 = $1013;
  CL_DEVICE_IMAGE3D_MAX_HEIGHT                = $1014;
  CL_DEVICE_IMAGE3D_MAX_DEPTH                 = $1015;
  CL_DEVICE_IMAGE_SUPPORT                     = $1016;
  CL_DEVICE_MAX_PARAMETER_SIZE                = $1017;
  CL_DEVICE_MAX_SAMPLERS                      = $1018;
  CL_DEVICE_MEM_BASE_ADDR_ALIGN               = $1019;
  CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE          = $101A;
  CL_DEVICE_SINGLE_FP_CONFIG                  = $101B;
  CL_DEVICE_GLOBAL_MEM_CACHE_TYPE             = $101C;
  CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE         = $101D;
  CL_DEVICE_GLOBAL_MEM_CACHE_SIZE             = $101E;
  CL_DEVICE_GLOBAL_MEM_SIZE                   = $101F;
  CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE          = $1020;
  CL_DEVICE_MAX_CONSTANT_ARGS                 = $1021;
  CL_DEVICE_LOCAL_MEM_TYPE_INFO               = $1022; // CL_DEVICE_LOCAL_MEM_TYPE
  CL_DEVICE_LOCAL_MEM_SIZE                    = $1023;
  CL_DEVICE_ERROR_CORRECTION_SUPPORT          = $1024;
  CL_DEVICE_PROFILING_TIMER_RESOLUTION        = $1025;
  CL_DEVICE_ENDIAN_LITTLE                     = $1026;
  CL_DEVICE_AVAILABLE                         = $1027;
  CL_DEVICE_COMPILER_AVAILABLE                = $1028;
  CL_DEVICE_EXECUTION_CAPABILITIES            = $1029;
  CL_DEVICE_QUEUE_PROPERTIES                  = $102A;
  CL_DEVICE_NAME                              = $102B;
  CL_DEVICE_VENDOR                            = $102C;
  CL_DRIVER_VERSION                           = $102D;
  CL_DEVICE_PROFILE                           = $102E;
  CL_DEVICE_VERSION                           = $102F;
  CL_DEVICE_EXTENSIONS                        = $1030;
  CL_DEVICE_PLATFORM                          = $1031;

  CL_GL_CONTEXT_KHR                           = $2008;
  CL_CONTEXT_PROPERTY_USE_CGL_SHAREGROUP_APPLE= $10000000;
// cl_device_address_info - bitfield
  CL_DEVICE_ADDRESS_32_BITS                   = (1 shl 0);
  CL_DEVICE_ADDRESS_64_BITS                   = (1 shl 1);

// cl_device_fp_config - bitfield
  CL_FP_DENORM                                = (1 shl 0);
  CL_FP_INF_NAN                               = (1 shl 1);
  CL_FP_ROUND_TO_NEAREST                      = (1 shl 2);
  CL_FP_ROUND_TO_ZERO                         = (1 shl 3);
  CL_FP_ROUND_TO_INF                          = (1 shl 4);
  CL_FP_FMA                                   = (1 shl 5);

// cl_device_mem_cache_type
  CL_NONE                                     = $0;
  CL_READ_ONLY_CACHE                          = $1;
  CL_READ_WRITE_CACHE                         = $2;

// cl_device_local_mem_type
  CL_LOCAL                                    = $1;
  CL_GLOBAL                                   = $2;

// cl_device_exec_capabilities - bitfield
  CL_EXEC_KERNEL                              = (1 shl 0);
  CL_EXEC_NATIVE_KERNEL                       = (1 shl 1);

// cl_command_queue_properties - bitfield
  CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE      = (1 shl 0);
  CL_QUEUE_PROFILING_ENABLE                   = (1 shl 1);

// cl_context_info
  CL_CONTEXT_REFERENCE_COUNT                  = $1080;
  CL_CONTEXT_NUM_DEVICES                      = $1081;
  CL_CONTEXT_DEVICES                          = $1082;
  CL_CONTEXT_PROPERTIES_INFO                  = $1083; // CL_CONTEXT_PROPERTIES
  CL_CONTEXT_PLATFORM_INFO                    = $1084; // CL_CONTEXT_PLATFORM

// cl_command_queue_info
  CL_QUEUE_CONTEXT                            = $1090;
  CL_QUEUE_DEVICE                             = $1091;
  CL_QUEUE_REFERENCE_COUNT                    = $1092;
  CL_QUEUE_PROPERTIES                         = $1093;

// cl_mem_flags - bitfield
  CL_MEM_READ_WRITE                           = (1 shl 0);
  CL_MEM_WRITE_ONLY                           = (1 shl 1);
  CL_MEM_READ_ONLY                            = (1 shl 2);
  CL_MEM_USE_HOST_PTR                         = (1 shl 3);
  CL_MEM_ALLOC_HOST_PTR                       = (1 shl 4);
  CL_MEM_COPY_HOST_PTR                        = (1 shl 5);

// cl_channel_order
  CL_R                                        = $10B0;
  CL_A                                        = $10B1;
  CL_RG                                       = $10B2;
  CL_RA                                       = $10B3;
  CL_RGB                                      = $10B4;
  CL_RGBA                                     = $10B5;
  CL_BGRA                                     = $10B6;
  CL_ARGB                                     = $10B7;
  CL_INTENSITY                                = $10B8;
  CL_LUMINANCE                                = $10B9;

// cl_channel_type
  CL_SNORM_INT8                               = $10D0;
  CL_SNORM_INT16                              = $10D1;
  CL_UNORM_INT8                               = $10D2;
  CL_UNORM_INT16                              = $10D3;
  CL_UNORM_SHORT_565                          = $10D4;
  CL_UNORM_SHORT_555                          = $10D5;
  CL_UNORM_INT_101010                         = $10D6;
  CL_SIGNED_INT8                              = $10D7;
  CL_SIGNED_INT16                             = $10D8;
  CL_SIGNED_INT32                             = $10D9;
  CL_UNSIGNED_INT8                            = $10DA;
  CL_UNSIGNED_INT16                           = $10DB;
  CL_UNSIGNED_INT32                           = $10DC;
  CL_HALF_FLOAT                               = $10DD;
  CL_FLOAT_TYPE                               = $10DE; // CL_FLOAT

// cl_mem_object_type
  CL_MEM_OBJECT_BUFFER                        = $10F0;
  CL_MEM_OBJECT_IMAGE2D                       = $10F1;
  CL_MEM_OBJECT_IMAGE3D                       = $10F2;

// cl_mem_info
  CL_MEM_TYPE                                 = $1100;
  CL_MEM_FLAGS_INFO                           = $1101; // CL_MEM_FLAGS
  CL_MEM_SIZE                                 = $1102;
  CL_MEM_HOST_PTR                             = $1103;
  CL_MEM_MAP_COUNT                            = $1104;
  CL_MEM_REFERENCE_COUNT                      = $1105;
  CL_MEM_CONTEXT                              = $1106;

// cl_image_info
  CL_IMAGE_FORMAT_INFO                        = $1110; // CL_IMAGE_FORMAT
  CL_IMAGE_ELEMENT_SIZE                       = $1111;
  CL_IMAGE_ROW_PITCH                          = $1112;
  CL_IMAGE_SLICE_PITCH                        = $1113;
  CL_IMAGE_WIDTH                              = $1114;
  CL_IMAGE_HEIGHT                             = $1115;
  CL_IMAGE_DEPTH                              = $1116;

// cl_addressing_mode
  CL_ADDRESS_NONE                             = $1130;
  CL_ADDRESS_CLAMP_TO_EDGE                    = $1131;
  CL_ADDRESS_CLAMP                            = $1132;
  CL_ADDRESS_REPEAT                           = $1133;

// cl_filter_mode
  CL_FILTER_NEAREST                           = $1140;
  CL_FILTER_LINEAR                            = $1141;

// cl_sampler_info
  CL_SAMPLER_REFERENCE_COUNT                  = $1150;
  CL_SAMPLER_CONTEXT                          = $1151;
  CL_SAMPLER_NORMALIZED_COORDS                = $1152;
  CL_SAMPLER_ADDRESSING_MODE                  = $1153;
  CL_SAMPLER_FILTER_MODE                      = $1154;

// cl_map_flags - bitfield
  CL_MAP_READ                                 = (1 shl 0);
  CL_MAP_WRITE                                = (1 shl 1);

// cl_program_info
  CL_PROGRAM_REFERENCE_COUNT                  = $1160;
  CL_PROGRAM_CONTEXT                          = $1161;
  CL_PROGRAM_NUM_DEVICES                      = $1162;
  CL_PROGRAM_DEVICES                          = $1163;
  CL_PROGRAM_SOURCE                           = $1164;
  CL_PROGRAM_BINARY_SIZES                     = $1165;
  CL_PROGRAM_BINARIES                         = $1166;

// cl_program_build_info
  CL_PROGRAM_BUILD_STATUS                     = $1181;
  CL_PROGRAM_BUILD_OPTIONS                    = $1182;
  CL_PROGRAM_BUILD_LOG                        = $1183;

// cl_build_status
  CL_BUILD_SUCCESS                            = 0;
  CL_BUILD_NONE                               = -1;
  CL_BUILD_ERROR                              = -2;
  CL_BUILD_IN_PROGRESS                        = -3;

// cl_kernel_info
  CL_KERNEL_FUNCTION_NAME                     = $1190;
  CL_KERNEL_NUM_ARGS                          = $1191;
  CL_KERNEL_REFERENCE_COUNT                   = $1192;
  CL_KERNEL_CONTEXT                           = $1193;
  CL_KERNEL_PROGRAM                           = $1194;

// cl_kernel_work_group_info
  CL_KERNEL_WORK_GROUP_SIZE                   = $11B0;
  CL_KERNEL_COMPILE_WORK_GROUP_SIZE           = $11B1;
  CL_KERNEL_LOCAL_MEM_SIZE                    = $11B2;

// cl_event_info
  CL_EVENT_COMMAND_QUEUE                      = $11D0;
  CL_EVENT_COMMAND_TYPE                       = $11D1;
  CL_EVENT_REFERENCE_COUNT                    = $11D2;
  CL_EVENT_COMMAND_EXECUTION_STATUS           = $11D3;

// cl_command_type
  CL_COMMAND_NDRANGE_KERNEL                   = $11F0;
  CL_COMMAND_TASK                             = $11F1;
  CL_COMMAND_NATIVE_KERNEL                    = $11F2;
  CL_COMMAND_READ_BUFFER                      = $11F3;
  CL_COMMAND_WRITE_BUFFER                     = $11F4;
  CL_COMMAND_COPY_BUFFER                      = $11F5;
  CL_COMMAND_READ_IMAGE                       = $11F6;
  CL_COMMAND_WRITE_IMAGE                      = $11F7;
  CL_COMMAND_COPY_IMAGE                       = $11F8;
  CL_COMMAND_COPY_IMAGE_TO_BUFFER             = $11F9;
  CL_COMMAND_COPY_BUFFER_TO_IMAGE             = $11FA;
  CL_COMMAND_MAP_BUFFER                       = $11FB;
  CL_COMMAND_MAP_IMAGE                        = $11FC;
  CL_COMMAND_UNMAP_MEM_OBJECT                 = $11FD;
  CL_COMMAND_MARKER                           = $11FE;
  CL_COMMAND_WAIT_FOR_EVENTS                  = $11FF;
  CL_COMMAND_BARRIER                          = $1200;
  CL_COMMAND_ACQUIRE_GL_OBJECTS               = $1201;
  CL_COMMAND_RELEASE_GL_OBJECTS               = $1202;

// command execution status
  CL_COMPLETE                                 = $0;
  CL_RUNNING                                  = $1;
  CL_SUBMITTED                                = $2;
  CL_QUEUED                                   = $3;

// cl_profiling_info
  CL_PROFILING_COMMAND_QUEUED                 = $1280;
  CL_PROFILING_COMMAND_SUBMIT                 = $1281;
  CL_PROFILING_COMMAND_START                  = $1282;
  CL_PROFILING_COMMAND_END                    = $1283;

// ****************************************************************************

  // Platform APIs
function clGetPlatformIDs(
  num_entries   : cl_uint;
  platforms     : Pcl_platform_id;
  num_platforms : Pcl_uint
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clGetPlatformIDs';

function clGetPlatformInfo(
  _platform    : cl_platform_id;
  param_name   : cl_platform_info;
  value_size   : csize_t;
  value        : Pointer;
  var size_ret : csize_t
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clGetPlatformInfo';

  //  Device APIs
function clGetDeviceIDs(
  _platform       : cl_platform_id;
  device_type     : cl_device_type;
  num_entries     : cl_uint;
  devices         : Pcl_device_id;
  num_devices     : pcl_uint
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clGetDeviceIDs';

function clGetDeviceInfo(
  device       : cl_device_id;
  param_name   : cl_device_info;
  value_size   : csize_t;
  value        : Pointer;
  var size_ret : csize_t
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clGetDeviceInfo';

  //  Context APIs
type
  TContextNotify = procedure (name: Pchar; data: Pointer; size: csize_t; data2: Pointer); extdecl;


function clCreateContext(
  properties      : Pcl_context_properties;
  num_devices     : cl_uint;
  devices         : Pcl_device_id;
  notify          : TContextNotify;
  user_data       : Pointer;
  var errcode_ret : cl_int
  ): cl_context; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clCreateContext';

function clCreateContextFromType(
  properties      : Pcl_context_properties;
  device_type     : cl_device_type;
  notify          : TContextNotify;
  user_data       : Pointer;
  var errcode_ret : cl_int
  ): cl_context; extdecl;
  external name 'clCreateContextFromType';

function clRetainContext(context: cl_context): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clRetainContext';

function clReleaseContext(context: cl_context): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clReleaseContext';

function clGetContextInfo(
  context       : cl_context;
  param_name    : cl_context_info;
  value_size    : csize_t;
  value         : Pointer;
  var size_ret  : csize_t
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clGetContextInfo';

  //  Command Queue APIs
function clCreateCommandQueue(
  context    : cl_context;
  device     : cl_device_id;
  properties : cl_command_queue_properties;
  errcode_ret: cl_int
  ): cl_command_queue; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clCreateCommandQueue';

function clRetainCommandQueue(command_queue : cl_command_queue): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clRetainCommandQueue';

function clReleaseCommandQueue(command_queue : cl_command_queue): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clReleaseCommandQueue';

function clGetCommandQueueInfo(
  command_queue: cl_command_queue;
  param_name   : cl_command_queue_info;
  value_size   : csize_t;
  value        : Pointer;
  var size_ret : csize_t
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clGetCommandQueueInfo';

function clSetCommandQueueProperty(
  command_queue       : cl_command_queue;
  properties          : cl_command_queue_properties;
  enable              : cl_bool;
  var old_properties  : cl_command_queue_properties
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clSetCommandQueueProperty';

  //  Memory Object APIs
function clCreateBuffer(
  context          : cl_context;
  flags            : cl_mem_flags;
  size             : csize_t;
  host_ptr         : Pointer;
  var errcode_ret  : cl_int
  ): cl_mem; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clCreateBuffer';

function clCreateImage2D(
  context         : cl_context;
  flags   	      : cl_mem_flags;
  image_format    : Pcl_image_format;
  image_width     : csize_t;
  image_height    : csize_t;
  image_row_pitch : csize_t;
  host_ptr        : Pointer;
  var errcode_ret : cl_int
  ): cl_mem; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clCreateImage2D';

function clCreateImage3D(
  context 			    : cl_context;
  flags 			      : cl_mem_flags;
  image_format      : Pcl_image_format;
  image_width 	    : csize_t;
  image_height      : csize_t;
  image_depth 	    : csize_t;
  image_row_pitch 	: csize_t;
  image_slice_pitch : csize_t;
  host_ptr 		      : Pointer;
  var errcode_ret		: cl_int
  ): cl_mem; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clCreateImage3D';

function clRetainMemObject(memobj: cl_mem): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clRetainMemObject';

function clReleaseMemObject(memobj: cl_mem): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clReleaseMemObject';

function clGetSupportedImageFormats(
  context		    	: cl_context;
  flags 			    : cl_mem_flags;
  image_type 		  : cl_mem_object_type;
  num_entries 		: cl_uint;
  image_formats   : Pcl_image_format;
  var num_formats : cl_uint
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clGetSupportedImageFormats';

function clGetMemObjectInfo(
  memobj      	: cl_mem;
  param_name    : cl_mem_info;
  value_size    : csize_t;
  value     	  : Pointer;
  var size_ret  : csize_t
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clGetMemObjectInfo';

function clGetImageInfo(
  image         : cl_mem;
  param_name    : cl_image_info;
  value_size    : csize_t;
  value         : Pointer;
  var size_ret  : csize_t
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clGetImageInfo';

  //  Sampler APIs
function clCreateSampler(
  context         : cl_context;
  is_norm_coords  : cl_bool;
  addr_mode       : cl_addressing_mode;
  filter_mode     : cl_filter_mode;
  var errcode_ret : cl_int
  ): cl_sampler; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clCreateSampler';

function clRetainSampler(sampler: cl_sampler): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clRetainSampler';

function clReleaseSampler(sampler: cl_sampler): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clReleaseSampler';

function clGetSamplerInfo(
  sampler      : cl_sampler;
  param_name   : cl_sampler_info;
  value_size   : csize_t;
  value        : Pointer;
  var size_ret : csize_t
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clGetSamplerInfo';

  //  Program Object APIs
function clCreateProgramWithSource(
  context         : cl_context;
  count           : cl_uint;
  strings         : PPChar;
  lengths         : Pcsize_t;
  var errcode_ret : cl_int
  ): cl_program; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clCreateProgramWithSource';

//type
//  PPByte = ^PByte;

function clCreateProgramWithBinary(
  context     : cl_context;
  num_devices : cl_uint;
  device_list : Pcl_device_id;
  lengths     : Pcsize_t;
  binaries    : PPByte;
  var binary_status: cl_int;
  var errcode_ret: cl_int
  ): cl_program; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clCreateProgramWithBinary';

function clRetainProgram(_program: cl_program): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clRetainProgram';

function clReleaseProgram(_program: cl_program): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clReleaseProgram';

type
  TProgramNotify = procedure (_program: cl_program; user_data: Pointer); extdecl;

//extern   cl_int

function clBuildProgram(
  _program     : cl_program;
  num_devices  : cl_uint;
  device_list  : Pcl_device_id;
  options      : PChar;
  notify       : TProgramNotify;
  user_data    : Pointer
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clBuildProgram';

function clUnloadCompiler: cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clUnloadCompiler';

function clGetProgramInfo(
  _program      : cl_program;
  param_name    : cl_program_info;
  value_size    : csize_t;
  value         : Pointer;
  var size_ret  : csize_t
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clGetProgramInfo';

function clGetProgramBuildInfo(
  _program      : cl_program;
  device        : cl_device_id;
  param_name    : cl_program_build_info;
  value_size    : csize_t;
  value         : Pointer;
  var size_ret  : csize_t
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clGetProgramBuildInfo';

  //  Kernel Object APIs
function clCreateKernel(
  _program        : cl_program;
  kernel_name     : PChar;
  var errcode_ret : cl_int
  ): cl_kernel; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clCreateKernel';

function clCreateKernelsInProgram(
  _program      : cl_program;
  num_kernels   : cl_uint;
  kernels       : Pcl_kernel;
  var num_ret   : cl_uint
  ): cl_int; extdecl; external name 'clCreateKernelsInProgram';

function clRetainKernel(kernel: cl_kernel): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clRetainKernel';

function clReleaseKernel(kernel: cl_kernel): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clReleaseKernel';

function clSetKernelArg(
  kernel    : cl_kernel;
  arg_index : cl_uint;
  arg_size  : csize_t;
  arg_value : Pointer
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clSetKernelArg';

function clGetKernelInfo(
  kernel        : cl_kernel;
  param_name    : cl_kernel_info;
  value_size    : csize_t;
  value         : Pointer;
  var size_ret  : csize_t
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clGetKernelInfo';

function clGetKernelWorkGroupInfo(
  kernel        : cl_kernel;
  device        : cl_device_id;
  param_name    : cl_kernel_work_group_info;
  value_size    : csize_t;
  value         : Pointer;
  size_ret      : pcsize_t
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clGetKernelWorkGroupInfo';

  //  Event Object APIs
function clWaitForEvents(
  num_events  : cl_uint;
  event_list  : cl_event
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clWaitForEvents';

function clGetEventInfo(
  event         : cl_event;
  param_name    : cl_event_info;
  value_size    : csize_t;
  value         : Pointer;
  var size_ret  : csize_t
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clGetEventInfo';

function clRetainEvent(event: cl_event): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clRetainEvent';

function clReleaseEvent(event: cl_event): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clReleaseEvent';

  //  Profiling APIs
function clGetEventProfilingInfo(
  event         : cl_event;
  param_name    : cl_profiling_info;
  value_size    : csize_t;
  value         : Pointer;
  var size_ret  : csize_t
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clGetEventProfilingInfo';

  //  Flush and Finish APIs
function clFlush(command_queue: cl_command_queue): cl_int; extdecl;
  external  {$ifdef DYNLINK}opencllib{$endif} name 'clFlush';

function clFinish(command_queue: cl_command_queue): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clFinish';

  //  Enqueued Commands APIs
function clEnqueueReadBuffer(
  command_queue : cl_command_queue;
  buffer        : cl_mem;
  blocking_read : cl_bool;
  offset        : csize_t;
  cb            : csize_t;
  ptr           : Pointer;
  num_events    : cl_uint;
  events_list   : Pcl_event;
  event         : Pcl_event
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clEnqueueReadBuffer';

function clEnqueueWriteBuffer(
  command_queue   : cl_command_queue;
  buffer          : cl_mem;
  blocking_write  : cl_bool;
  offset          : csize_t;
  cb              : csize_t;
  ptr             : Pointer;
  num_events      : cl_uint;
  events_list     : Pcl_event;
  event           : Pcl_event
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clEnqueueWriteBuffer';

function clEnqueueCopyBuffer(
  command_queue : cl_command_queue;
  src_buffer    : cl_mem;
  dst_buffer    : cl_mem;
  src_offset    : csize_t;
  dst_offset    : csize_t;
  cb            : csize_t;
  num_events    : cl_uint;
  events_list   : Pcl_event;
  event         : Pcl_event
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clEnqueueCopyBuffer';

function clEnqueueReadImage(
  command_queue : cl_command_queue;
  image         : cl_mem;
  blocking_read : cl_bool;
  origin        : Pcsize_t;
  region        : Pcsize_t;
  row_pitch     : csize_t;
  slice_pitch   : csize_t;
  ptr           : Pointer;
  num_events    : cl_uint;
  events_list   : Pcl_event;
  event         : Pcl_event
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clEnqueueReadImage';

function clEnqueueWriteImage(
  command_queue   : cl_command_queue;
  image           : cl_mem;
  blocking_write  : cl_bool;
  origin          : Pcsize_t;
  region          : Pcsize_t;
  row_pitch       : csize_t;
  slice_pitch     : csize_t;
  ptr             : Pointer;
  num_events      : cl_uint;
  events_list     : Pcl_event;
  event           : Pcl_event
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clEnqueueWriteImage';

function clEnqueueCopyImage(
  command_queue : cl_command_queue;
  src_image     : cl_mem;
  dst_image     : cl_mem;
  src_origin    : Pcsize_t;
  dst_origin    : Pcsize_t;
  region        : Pcsize_t;
  num_events    : cl_uint;
  events_list   : Pcl_event;
  event         : Pcl_event
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clEnqueueCopyImage';

function clEnqueueCopyImageToBuffer(
  command_queue : cl_command_queue;
  src_image     : cl_mem;
  dst_buffre    : cl_mem;
  src_origin    : Pcsize_t;
  region        : Pcsize_t;
  dst_offset    : csize_t;
  num_events    : cl_uint;
  events_list   : Pcl_event;
  event         : Pcl_event
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clEnqueueCopyImageToBuffer';

function clEnqueueCopyBufferToImage(
  command_queue : cl_command_queue;
  src_buffer    : cl_mem;
  dst_image     : cl_mem;
  src_offset    : csize_t;
  dst_origin    : Pcsize_t;
  region        : Pcsize_t;
  num_events    : cl_uint;
  events_list   : Pcl_event;
  event         : Pcl_event
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clEnqueueCopyBufferToImage';

function clEnqueueMapBuffer(
  command_queue   : cl_command_queue;
  buffer          : cl_mem;
  blocking_map    : cl_bool;
  map_flags       : cl_map_flags;
  offset          : csize_t;
  cb              : csize_t;
  num_events      : cl_uint;
  events_list     : Pcl_event;
  event           : Pcl_event;
  var errcode_ret : cl_int
  ): Pointer; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clEnqueueMapBuffer';

function clEnqueueMapImage(
  command_queue   : cl_command_queue;
  image           : cl_mem;
  blocking_map    : cl_bool;
  map_flags       : cl_map_flags;
  origin          : Pcsize_t;
  region          : Pcsize_t;
  row_pitch       : csize_t;
  slice_pitch     : csize_t;
  num_events      : cl_uint;
  events_list     : Pcl_event;
  event           : Pcl_event;
  var errcode_ret : cl_int
  ): Pointer; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clEnqueueMapImage';

function clEnqueueUnmapMemObject(
  command_queue : cl_command_queue;
  memobj        : cl_mem;
  mapped_ptr    : Pointer;
  num_events    : cl_uint;
  events_list   : Pcl_event;
  event         : Pcl_event
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clEnqueueUnmapMemObject';

function clEnqueueNDRangeKernel(
  command_queue : cl_command_queue;
  kernel        : cl_kernel;
  work_dim      : cl_uint;
  global_offset,
  global_size,
  local_size    : Pcsize_t;
  num_events    : cl_uint;
  events_list   : Pcl_event;
  event         : Pcl_event
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clEnqueueNDRangeKernel';

function clEnqueueTask(
  command_queue : cl_command_queue;
  kernel        : cl_kernel;
  num_events    : cl_uint;
  events_list   : Pcl_event;
  event         : Pcl_event
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clEnqueueTask';

type
  TEnqueueUserProc = procedure (userdata: Pointer); extdecl;

function clEnqueueNativeKernel(
  command_queue   : cl_command_queue;
  user_func       : TEnqueueUserProc;
  args            : Pointer;
  cb_args         : csize_t;
  num_mem_objects : cl_uint;
  mem_list        : Pcl_mem;
  args_mem_loc    : PPointer;
  num_events      : cl_uint;
  event_wait_list : Pcl_event;
  event           : Pcl_event
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clEnqueueNativeKernel';

function clEnqueueMarker(command_queue: cl_command_queue; event: Pcl_event
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clEnqueueMarker';

function clEnqueueWaitForEvents(command_queue: cl_command_queue;
  num_events: cl_uint; event_list: Pcl_event
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clEnqueueWaitForEvents';

function clEnqueueBarrier(command_queue: cl_command_queue
  ): cl_int; extdecl;
  external {$ifdef DYNLINK}opencllib{$endif} name 'clEnqueueBarrier';



var
     fcmdQueue  : cl_command_queue;
     fcontext   : cl_context;
     fkernel    : cl_kernel;
     fprogram   : cl_program;
     fmemA,fmemB,fmemC: cl_mem;

type

    { btOpenCLDemo }

    btOpenCLDemo=class(btGlutDemoApplication)
      procedure initOpenCL;
      procedure myinit; override;
      procedure cleanupOpenCL;
      procedure clientMoveAndDisplay; override;
      procedure displayCallback; override;
      procedure initPhysics; override;
      destructor destroy; override;
    end;

    // NOTE:  Make sure that appropriate GL header file is included separately

   type
     cl_gl_object_type   = cl_uint;
     cl_gl_texture_info  = cl_uint;
     cl_gl_platform_info = cl_uint;

   const
   // cl_gl_object_type
     CL_GL_OBJECT_BUFFER       = $2000;
     CL_GL_OBJECT_TEXTURE2D    = $2001;
     CL_GL_OBJECT_TEXTURE3D    = $2002;
     CL_GL_OBJECT_RENDERBUFFER = $2003;

     // cl_gl_texture_info
     CL_GL_TEXTURE_TARGET      = $2004;
     CL_GL_MIPMAP_LEVEL        = $2005;

   function clCreateFromGLBuffer(context: cl_context; falgs: cl_mem_flags;  bufobj: GLuint; var errcode_ret: cl_int): cl_mem; cdecl; external name 'clCreateFromGLBuffer';
   function clCreateFromGLTexture2D(context: cl_context;flags: cl_mem_flags; target: GLenum; miplevel: GLint;texture: GLuint; var errcode_ret: cl_int): cl_mem; cdecl; external name 'clCreateFromGLTexture2D';
   function clCreateFromGLTexture3D(context: cl_context; flags: cl_mem_flags;target: GLenum; miplevel: GLint; texture: GLuint; var errorcode: cl_int): cl_mem; cdecl; external name 'clCreateFromGLTexture3D';
   function clCreateFromGLRenderbuffer(context: cl_context;flags: cl_mem_flags; renderbuffer: GLuint; var errcode: cl_int): cl_mem; cdecl; external name 'clCreateFromGLRenderbuffer';
   function clGetGLObjectInfo(memobj: cl_mem; gl_object_type: cl_gl_object_type;object_name: GLuint): cl_int; cdecl; external name 'clGetGLObjectInfo';
   function clGetGLTextureInfo(memobj: cl_mem; param_name: cl_gl_texture_info;value_size: csize_t; value: Pointer; var size_ret: pcsize_t): cl_int; cdecl; external name 'clGetGLTextureInfo';
   function clEnqueueAcquireGLObjects(command_queue: cl_command_queue;num_objects: cl_uint; mem_objects: Pcl_mem;num_events: cl_uint; events_list : Pcl_event; event: Pcl_event): cl_int; cdecl; external name 'clEnqueueAcquireGLObjects';
   function clEnqueueReleaseGLObjects(command_queue: cl_command_queue;num_objects: cl_uint; mem_objects: Pcl_mem;num_events: cl_uint; events_list : Pcl_event; event: Pcl_event): cl_int; cdecl; external name 'clEnqueueReleaseGLObjects';


implementation

{ btOpenCLDemo }

{$IFDEF MSWINDOWS}
procedure btOpenCLDemo.initOpenCL;
begin
  abort;
end;
{$ENDIF}
{$IFDEF UNIX}
procedure btOpenCLDemo.initOpenCL;
var
  err: cl_int;
//  num_platforms: cl_uint;
  platforms: cl_platform_id;
  devices: cl_device_id;
  a,b,c: array[0..2] of Single;
  program_source: String;
  i: Integer;
  work_size,local_size: csize_t;
  properties: array[0..2] of cl_context_properties;
  bufferId: GLuint;
  fcglContext: CGLContextObj;
  fcglSharedGroup: CGLShareGroup;
begin
  writeln('Init dglOpengl');
  InitOpenGL;
  ReadExtensions;
  writeln('Init dglOpengl DONE');
  err:=clGetPlatformIDs(1, @platforms, nil);
writeln('clGetPlatformIDs ',err);
  err:=clGetDeviceIDs(platforms,CL_DEVICE_TYPE_GPU, 1, @devices, nil);
writeln('clGetDeviceIDs ',err);
//  fcontext:=clCreateContext(nil, 1, @devices, nil, nil, err);
//writeln('clCreateContext ',err);
//   properties[0]:=CL_CONTEXT_PLATFORM_INFO; properties[1]:=cl_context_properties(platforms);
   fcglContext :=CGLGetCurrentContext;
   fcglSharedGroup := CGLGetShareGroup(fcglContext);

   {$HINTS OFF}
   properties[0]:=CL_CONTEXT_PROPERTY_USE_CGL_SHAREGROUP_APPLE;
   properties[1]:=cl_context_properties(fcglSharedGroup);
   properties[2]:=0;
   {$HINTS ON}

//  fcontext:=clCreateContextFromType(@properties, CL_DEVICE_TYPE_GPU, nil, nil, err);
  fcontext:=clCreateContext(@properties, 0, Pointer(0), nil, nil, err);
writeln('clCreateContextFromType ',err);
  glGenBuffers(1,@bufferId);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,bufferId);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER,sizeof(Single)*3,nil,GL_STATIC_DRAW);
writeln('glGenBuffers');
  fmemC:=clCreateFromGLBuffer(fcontext, CL_MEM_READ_WRITE, bufferId, err);
writeln('clCreateFromGLBuffer ',err);

  fcmdQueue:=clCreateCommandQueue(fcontext, devices, 0, err);
writeln('clCreateCommandQueue ',err);

  program_source:='__kernel void sum(__global const float *a,__global const float *b, __global int *answer){int xid = get_global_id(0); answer[xid] = a[xid] * b[xid];}';
  fprogram:=clCreateProgramWithSource(fcontext,1, @program_source, nil, err);
writeln('clCreateProgramWithSource ',err);
  err:=clBuildProgram(fprogram, 0, nil, nil, nil, nil);
writeln('clBuildProgram ',err);
  fkernel:=clCreateKernel(fprogram, 'sum', err);
writeln('clCreateKernel ',err);

  fmemA:=clCreateBuffer(fcontext, CL_MEM_READ_ONLY, SizeOf(Single)*3, nil, err);
writeln('clCreateBuffer ',err);
  fmemB:=clCreateBuffer(fcontext, CL_MEM_READ_ONLY, SizeOf(Single)*3, nil, err);
writeln('clCreateBuffer ',err);
//  fmemC:=clCreateBuffer(fcontext, CL_MEM_WRITE_ONLY, SizeOf(Single)*3, nil, err);
//writeln('clCreateBuffer ',err);
  a[0]:=1; a[1]:=2; a[2]:=3;
  b[0]:=4; b[1]:=5; b[2]:=6;
  err:=clEnqueueWriteBuffer(fcmdQueue, fmemA, CL_TRUE, 0, SizeOf(Single)*3, @a, 0,nil,nil);
writeln('clEnqueueWriteBuffer ',err);
  err:=clEnqueueWriteBuffer(fcmdQueue, fmemB, CL_TRUE, 0, SizeOf(Single)*3, @b, 0,nil,nil);
writeln('clEnqueueReadBuffer ',err);
  err:=clFinish(fcmdQueue);
writeln('clFinish ',err);
  err:=clSetKernelArg(fkernel, 0, SizeOf(cl_mem), @fmemA);
writeln('clSetKernelArg ',err);
  err:=clSetKernelArg(fkernel, 1, SizeOf(cl_mem), @fmemB);
writeln('clSetKernelArg ',err);
  err:=clSetKernelArg(fkernel, 2, SizeOf(cl_mem), @fmemC);
writeln('clSetKernelArg ',err);
  work_size:=Length(a);
  local_size:=1;
  err:=clEnqueueNDRangeKernel(fcmdQueue, fkernel, 1, nil, @work_size, @local_size, 0, nil, nil);
writeln('clEnqueueNDRangeKernel ',err);
  err:=clFinish(fcmdQueue);
writeln('clFinish ',err);
  err:=clEnqueueReadBuffer(fcmdQueue, fmemC, CL_TRUE, 0, SizeOf(Single)*3, @c, 0, nil, nil);
writeln('clEnqueueReadBuffer ',err);
  err:=clFinish(fcmdQueue);
  glFlush;
writeln('clFinish ',err);
  for i := 0 to Length(c) - 1 do begin
    writeln(i,' ',c[i]:2:6);
  end;
end;
{$ENDIF}

procedure btOpenCLDemo.myinit;
begin
  inherited myinit;
  initOpenCL;
end;

procedure btOpenCLDemo.cleanupOpenCL;
begin
  clReleaseMemObject(fmemA);
  clReleaseMemObject(fmemB);
  clReleaseMemObject(fmemC);
  clReleaseKernel(fkernel);
  clReleaseProgram(fprogram);
  clReleaseCommandQueue(fcmdQueue);
  clReleaseContext(fcontext);
end;

procedure btOpenCLDemo.clientMoveAndDisplay;
begin
  displayCallback;
end;

procedure btOpenCLDemo.displayCallback;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glDisable(GL_LIGHTING);

  glFlush();
  glutSwapBuffers();
end;

procedure btOpenCLDemo.initPhysics;
begin
end;

destructor btOpenCLDemo.destroy;
begin
  cleanupOpenCL;
  inherited destroy;
end;

end.

