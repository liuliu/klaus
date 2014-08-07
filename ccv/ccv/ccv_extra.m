/**********************************************************
 * C-based/Cached/Core Computer Vision Library
 * Liu Liu, 2010-02-01
 **********************************************************/

#import "ccv_extra.h"

#import <sqlite3.h>
#import <UIKit/UIKit.h>

void ccv_convnet_read_extra(ccv_convnet_t* convnet, const char* filename, NSDictionary *layers)
{
  sqlite3* db = 0;
  if (SQLITE_OK == sqlite3_open(filename, &db))
  {
    sqlite3_stmt* layer_quant_stmt = 0;
    const char layer_quant_qs[] =
    "SELECT layer, quant FROM layer_quant;";
    if (SQLITE_OK == sqlite3_prepare_v2(db, layer_quant_qs, sizeof(layer_quant_qs), &layer_quant_stmt, 0))
    {
      while (sqlite3_step(layer_quant_stmt) == SQLITE_ROW)
      {
        ccv_convnet_layer_t* layer = convnet->layers + sqlite3_column_int(layer_quant_stmt, 0);
        int qnum = sqlite3_column_bytes(layer_quant_stmt, 1) / sizeof(uint16_t);
        // if weights available, load weights
        UIImage *weights = layers[@(sqlite3_column_int(layer_quant_stmt, 0))];
        CGImageRef weightImage = weights.CGImage;
        int width = CGImageGetWidth(weightImage);
        int height = CGImageGetHeight(weightImage);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        CGContextRef context = CGBitmapContextCreate(0, width, height, 8, width, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaNone);
        CGColorSpaceRelease(colorSpace);
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), weightImage);
        uint8_t *data = (uint8_t *)CGBitmapContextGetData(context);
        const void* q = sqlite3_column_blob(layer_quant_stmt, 1);
        float f[256];
        ccv_half_precision_to_float((uint16_t*)q, f, qnum);
        int j, k;
        for (j = 0; j < height; j++)
          for (k = 0; k < width; k++)
            layer->w[j * width + k] = f[data[j * width + k]];
        CGContextRelease(context);
      }
      sqlite3_finalize(layer_quant_stmt);
    }
  }
  sqlite3_close(db);
}