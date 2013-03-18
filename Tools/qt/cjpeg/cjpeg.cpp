/* 
 * (c) 2013 Dan Lee, Alex Kushlyev, Steve McGill, Yida Zhang
 * ddlee@seas.upenn.edu, smcgill3@seas.upenn.edu
 * University of Pennsylvania
 * */

#ifdef __cplusplus
extern "C"
{
#endif
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#ifdef __cplusplus
}
#endif

#include <stdint.h>
#include <stdlib.h>
#include <vector>
#include <string>
#include <jpeglib.h>
#include <setjmp.h>
#include <stdio.h>

#define MT_NAME "cjpeg_mt"

typedef struct {
  JSAMPLE *row;
  JSAMPROW row_pointer[1];  
} structJPEG;

std::vector<unsigned char> destBuf;

static structJPEG * lua_checkcjpeg(lua_State *L, int narg) {
  void *ud = luaL_checkudata(L, narg, MT_NAME);
  luaL_argcheck(L, *(structJPEG **)ud != NULL, narg, "invalid jpeg");
  return (structJPEG *)ud;
}

static void error_exit_compress(j_common_ptr cinfo)
{
  (*cinfo->err->output_message) (cinfo);
  jpeg_destroy_compress((j_compress_ptr) cinfo);
}

void init_destination(j_compress_ptr cinfo) {
  const unsigned int size = 65536; //UDP friendly size
//  const unsigned int size = 2*65536;
  destBuf.resize(size);
  cinfo->dest->next_output_byte = &(destBuf[0]);
  cinfo->dest->free_in_buffer = size;
}

boolean empty_output_buffer(j_compress_ptr cinfo)
{
  fprintf(stdout,"Error buffer too small!\n");

  unsigned int size = destBuf.size();
  destBuf.resize(2*size);
  cinfo->dest->next_output_byte = &(destBuf[size]);
  cinfo->dest->free_in_buffer = size;

  return TRUE;
}

void term_destination(j_compress_ptr cinfo) {
  /*
     cinfo->dest->next_output_byte = destBuf;
     cinfo->dest->free_in_buffer = destBufSize;
     */
  int len = destBuf.size() - (cinfo->dest->free_in_buffer);
  while (len % 2 != 0)
    destBuf[len++] = 0xFF;

  destBuf.resize(len);
}

int CompressData(const uint8_t* prRGB, int width, int height, int ch) {

  //fprintf(stdout,"compressing %dx%d\n",width, height);

  int quality = 90;
  struct jpeg_compress_struct cinfo;
  struct jpeg_error_mgr jerr;
  cinfo.err = jpeg_std_error(&jerr);
  jerr.error_exit = error_exit_compress;

  jpeg_create_compress(&cinfo);
  if (cinfo.dest == NULL) {
    cinfo.dest = (struct jpeg_destination_mgr *)
      (*cinfo.mem->alloc_small) ((j_common_ptr) &cinfo, JPOOL_PERMANENT,
          sizeof(struct jpeg_destination_mgr));
  }
  cinfo.dest->init_destination = init_destination;
  cinfo.dest->empty_output_buffer = empty_output_buffer;
  cinfo.dest->term_destination = term_destination;

  cinfo.image_width = width;
  cinfo.image_height = height;
  cinfo.input_components = 3;
  cinfo.in_color_space = JCS_RGB;
  if(ch==1){
    cinfo.input_components = 1;
    cinfo.in_color_space = JCS_GRAYSCALE;
  }
  jpeg_set_defaults(&cinfo);
  jpeg_set_quality(&cinfo, quality, TRUE);
  cinfo.write_JFIF_header = true;//false;
  cinfo.dct_method = JDCT_IFAST;
  //cinfo.dct_method = JDCT_FASTEST; // TurboJPEG

  jpeg_start_compress(&cinfo, TRUE);

  /*
  JSAMPROW row_pointer;
  while (cinfo.next_scanline < cinfo.image_height) {
    row_pointer = (JSAMPROW) &prRGB[cinfo.next_scanline*width*3];
    jpeg_write_scanlines(&cinfo, &row_pointer, 1);
    fprintf(stdout,"RGB: %d,%d,%d\t",
        row_pointer[0],row_pointer[1],row_pointer[2]);
    fprintf(stdout,"RGB: %d,%d,%d\n",
        row_pointer[3],row_pointer[4],row_pointer[5]);
  }
  */
  JSAMPLE row[ch*width];
  JSAMPROW row_pointer[1];
  *row_pointer = row;
  while (cinfo.next_scanline < cinfo.image_height) {
    //fprintf(stdout,"cinfo.next_scanline = %d\n", cinfo.next_scanline);
    const uint8_t *p = prRGB + ch*width*cinfo.next_scanline;
    int irow = 0;
    for (int i = 0; i < width; i++) {
      if( ch==3 ){
        row[irow++] = *(p+i*ch);
        row[irow++] = *(p+i*ch+1);
        row[irow++] = *(p+i*ch+2);
      } else if( ch==4) {
        row[irow++] = *(p+i*ch+2);
        row[irow++] = *(p+i*ch+1);
        row[irow++] = *(p+i*ch);
      } else {
        row[irow++] = *(p+i);
      }
      //irow++;
  /*
      fprintf(stdout,"RGB: %d,%d,%d\t",
        row[0],row[1],row[2]);
    fprintf(stdout,"RGB: %d,%d,%d\n",
        row[3],row[4],row[5]);
    */
    }
    jpeg_write_scanlines(&cinfo, row_pointer, 1);
  }

  jpeg_finish_compress(&cinfo);
  jpeg_destroy_compress(&cinfo);

  unsigned int destBufSize = destBuf.size();
 /* 
  plhs[0] = mxCreateNumericMatrix(1, destBufSize, mxUINT8_CLASS, mxREAL);
  memcpy(mxGetData(plhs[0]), &(destBuf[0]), destBufSize);
*/
  return destBufSize;		
}

static int lua_cjpeg_compress(lua_State *L) {
  uint8_t * dataSrc = (uint8_t *) lua_touserdata(L, 1);
  int width = luaL_checkint(L, 2);
  int height = luaL_checkint(L, 3);
  int byte_sized = luaL_optint(L, 4, 3);
  int lenPacked = CompressData( dataSrc, width, height, byte_sized );

  if (lenPacked > 0)
    lua_pushlstring(L, (const char *)&(destBuf[0]), lenPacked);
  else
    return luaL_error(L, "Compress Error");

  return 1;
}

struct mem_jpeg_source_mgr : public jpeg_source_mgr
{
  bool buffer_filled;
  char dummy_buffer[ 2 ];

  mem_jpeg_source_mgr( char* data, unsigned int length );
};

struct mem_error_mgr : public jpeg_error_mgr 
{
  jmp_buf setjmp_buffer;
};

static void mem_error_exit( j_common_ptr cinfo )
{
  mem_error_mgr* err = (mem_error_mgr*) cinfo->err;
  longjmp( err->setjmp_buffer, 1 );
}

static void jpeg_init_source( j_decompress_ptr cinfo )
{
}

static boolean jpeg_fill_input_buffer( j_decompress_ptr cinfo )
{
  mem_jpeg_source_mgr* src = (mem_jpeg_source_mgr*)cinfo->src;
  if( src->buffer_filled ) 
  {
    // Insert a fake EOI marker - as per jpeglib recommendation
    src->next_input_byte = (const JOCTET*) src->dummy_buffer;
    src->bytes_in_buffer = 2;
  } 
  else 
  {
    src->buffer_filled = true;
  }
  return true;
}

static void jpeg_skip_input_data( j_decompress_ptr cinfo, long num_bytes )
{
  mem_jpeg_source_mgr* src = (mem_jpeg_source_mgr*)cinfo->src;

  if (num_bytes > 0) 
  {
    while( num_bytes > (long) src->bytes_in_buffer ) 
    {
      num_bytes -= (long) src->bytes_in_buffer;
      jpeg_fill_input_buffer(cinfo);
    }
    src->next_input_byte += (size_t) num_bytes;
    src->bytes_in_buffer -= (size_t) num_bytes;
  }
}

static void jpeg_term_source (j_decompress_ptr cinfo)
{
  /* no work necessary here */
}

mem_jpeg_source_mgr::mem_jpeg_source_mgr( char* data, unsigned int length )
: buffer_filled( false )
{
  dummy_buffer[ 0 ] = (JOCTET) 0xFF;
  dummy_buffer[ 1 ] = (JOCTET) JPEG_EOI;
  next_input_byte = (const JOCTET*) data;
  bytes_in_buffer = length;
  init_source = jpeg_init_source;
  fill_input_buffer = jpeg_fill_input_buffer;
  skip_input_data = jpeg_skip_input_data;
  resync_to_restart = jpeg_resync_to_restart;
  term_source = jpeg_term_source;
}

static int lua_cjpeg_uncompress(lua_State *L) {
  char* file_str = (char*)luaL_checkstring(L, 1);
  int size = lua_tointeger(L, 2);

  structJPEG *ud = (structJPEG *)lua_newuserdata(L, sizeof(structJPEG));
  
  struct jpeg_decompress_struct cinfo;
  struct mem_error_mgr jerr;

  jpeg_create_decompress(&cinfo);
  mem_jpeg_source_mgr mjsm( (char*) file_str, size );
  cinfo.src = &mjsm;

  cinfo.err = jpeg_std_error(&jerr);
  jerr.error_exit = mem_error_exit;

  if (!setjmp(jerr.setjmp_buffer)) {
    jpeg_read_header( &cinfo, TRUE );

	  unsigned char * raw_image = (unsigned char*)malloc( cinfo.image_width*cinfo.image_height*cinfo.num_components );

    printf("%d %d %d\n", cinfo.image_width, cinfo.image_height, cinfo.num_components);
    jpeg_start_decompress( &cinfo );

    unsigned char* buffer = raw_image;
    unsigned int dstStep = cinfo.output_width*cinfo.num_components;

    while (cinfo.output_scanline < cinfo.output_height) 
    {
      jpeg_read_scanlines(&cinfo, (JSAMPARRAY) &buffer, 1);
      buffer += dstStep;
    }

    jpeg_finish_decompress(&cinfo);
    jpeg_destroy_decompress(&cinfo);
  }

  return 1;
}

static int lua_cjpeg_index(lua_State *L) {
  structJPEG *p = lua_checkcjpeg(L, 1);
  if ((lua_type(L, 2) == LUA_TNUMBER) && lua_tointeger(L, 2)) {
    // Numeric index:
//    return lua_cjpeg_getValue(L);
  }

  // Get index through metatable:
  if (!lua_getmetatable(L, 1)) {lua_pop(L, 1); return 0;} // push metatable
  lua_pushvalue(L, 2); // copy key
  lua_rawget(L, -2); // get metatable function
  lua_remove(L, -2); // delete metatable
  return 1;
}

static const struct luaL_reg cjpeg_Methods [] {
  {NULL, NULL}
};

static const struct luaL_reg cjpeg_Functions [] = {
  {"compress", lua_cjpeg_compress},
  {"uncompress", lua_cjpeg_uncompress},
  {NULL, NULL}
};

#ifdef __cplusplus
extern "C"
#endif
int luaopen_cjpeg (lua_State *L) {
  luaL_newmetatable(L, MT_NAME);

  // Implement index method:
  lua_pushstring(L, "__index");
  lua_pushcfunction(L, lua_cjpeg_index);
  lua_settable(L, -3);

  luaL_register(L, NULL, cjpeg_Methods);
  luaL_register(L, "cjpeg", cjpeg_Functions);

  luaL_register(L, NULL, cjpeg_Methods);
  luaL_register(L, "cjpeg", cjpeg_Functions);
  return 1;
}
