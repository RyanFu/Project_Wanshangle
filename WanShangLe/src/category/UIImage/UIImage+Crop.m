// UIImage+Resize.m
// Created by Trevor Harmon on 8/5/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.

#import "UIImage+Crop.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImage (Crop)

// Returns a copy of this image that is cropped to the given bounds.
// The bounds will be adjusted using CGRectIntegral.
// This method ignores the image's imageOrientation setting.
- (UIImage *)croppedImage:(CGRect)bounds {
    
    CGRect frame = bounds;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){
        float  scale = [[UIScreen mainScreen] scale];
        frame = CGRectMake(bounds.origin.x*scale, 
                                  bounds.origin.y*scale,
                                  bounds.size.width*scale, 
                                  bounds.size.height*scale);
    }
        
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], frame);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}
@end

@implementation UIView (ReturnImage)

- (UIImage *)imageWithView:(UIView *)view
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, 0, 0.0); //Retina support
    else  
        UIGraphicsBeginImageContext(view.bounds.size);

    //CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1/[[UIScreen mainScreen] scale], 1/[[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage*)mergeBackgroundImage:(UIImage*)bgImg 
                          bgSize:(CGSize)bgsize
                         QRImage:(UIImage*)qrImg 
                          qrSize:(CGRect)qrSize
                       logoImage:(UIImage*)logoImg 
                        logoSize:(CGSize)logoSize

{    
    //Capture image context ref
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        //UIGraphicsBeginImageContextWithOptions(CGSize size, BOOL opaque, CGFloat scale)
        UIGraphicsBeginImageContextWithOptions(bgsize, NO, 2.0); //Retina support
    else
        UIGraphicsBeginImageContext(bgsize);
    [bgImg drawInRect:CGRectMake(0, 0, bgsize.width, bgsize.height) blendMode:kCGBlendModeDarken alpha:1];
    [qrImg drawInRect:qrSize blendMode:kCGBlendModeDarken alpha:1];
    [logoImg drawInRect:CGRectMake((bgsize.width-logoSize.width)/2.0f, (bgsize.height-logoSize.height)/2.0f, logoSize.width, logoSize.height)];
    
    //[imgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
}

- (UIImage *)mergeBackgroundImage:(UIImage *)backgroundImg withFrontImage:(UIImage *)frontImg
{
    // get width and height as integers, since we'll be using them as
    // array subscripts, etc, and this'll save a whole lot of casting
    CGSize size = backgroundImg.size;
    int width = size.width;
    int height = size.height;
    
    // Create a suitable RGB+alpha bitmap context in BGRA colour space
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *bkMemoryPool = (unsigned char *)calloc(width*height*4, 1);
    unsigned char *frontMemoryPool = (unsigned char *)calloc(width*height*4, 1);
    
    CGContextRef bkContext = CGBitmapContextCreate(bkMemoryPool, width, height, 8, width * 4, colourSpace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
    CGContextRef frontContext = CGBitmapContextCreate(frontMemoryPool, width, height, 8, width * 4, colourSpace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colourSpace);
    
    // draw the current image to the newly created context
    CGContextDrawImage(bkContext, CGRectMake(0, 0, width, height), [backgroundImg CGImage]);
    CGContextDrawImage(frontContext, CGRectMake(0, 0, width, height), [frontImg CGImage]);
    
    // run through every pixel, a scan line at a time...
    for(int y = 0; y < height; y++)
    {
        // get a pointer to the start of this scan line
        unsigned char *bkLinePointer = &bkMemoryPool[y * width * 4];
        unsigned char *frontLinePointer = &frontMemoryPool[y * width * 4];
        
        // step through the pixels one by one...
        for(int x = 0; x < width; x++)
        {
            // get RGB values. We're dealing with premultiplied alpha
            // here, so we need to divide by the alpha channel (if it
            // isn't zero, of course) to get uninflected RGB. We
            // multiply by 255 to keep precision while still using
            // integers
            int r = 1;
            int g = 1;
            int b = 1;
            if(bkLinePointer[3])
            {
                r = frontLinePointer[0]* 255 / bkLinePointer[3];
                g = frontLinePointer[1]* 255 / bkLinePointer[3];
                b = frontLinePointer[2]* 255 / bkLinePointer[3];
            }
            
            // multiply by alpha again, divide by 255 to undo the
            // scaling before, store the new values and advance
            // the pointer we're reading pixel data from
            bkLinePointer[0] = r* bkLinePointer[3] / 255;
            bkLinePointer[1] = g* bkLinePointer[3] / 255;
            bkLinePointer[2] = b* bkLinePointer[3] / 255;
            bkLinePointer += 4;
            frontLinePointer +=4;
        }
    }
    
    // get a CG image from the context, wrap that into a
    // UIImage
    CGImageRef cgImage = CGBitmapContextCreateImage(bkContext);
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    
    // clean up
    CGImageRelease(cgImage);
    CGContextRelease(bkContext);
    CGContextRelease(frontContext);
    free(bkMemoryPool);
    free(frontMemoryPool);
    
    // and return
    return returnImage;
}

@end
