//
//  NSColor+WebColor.h
//  MNColorPicker
//

#import <UIKit/UIKit.h>


@interface UIColor (ColorSpaces) 

#pragma mark -
#pragma mark Web String

- (NSString *)mn_webColorString;
+ (UIColor *)mn_colorFromWebColorString: (NSString *)colorString;

#pragma mark -
#pragma mark String

- (NSString *)mn_stringFromColor;
+ (UIColor *)mn_colorFromString: (NSString *)colorString;

#pragma mark -
#pragma mark Propery List

+ (UIColor *)mn_colorFromPropertyRepresentation:(id)colorObject;
- (id)mn_propertyRepresentation ;

#pragma mark -
#pragma mark RGB


- (BOOL)mn_canProvideRGBColor;
- (CGColorSpaceModel)mn_colorSpaceModel;
- (CGFloat)mn_redComponent;
- (CGFloat)mn_greenComponent;
- (CGFloat)mn_blueComponent;
- (CGFloat)mn_alphaComponent;
- (CGFloat)mn_whiteComponent;


#pragma mark -
#pragma mark HSB

- (CGFloat)mn_hueComponent;
- (CGFloat)mn_saturationComponent;
- (CGFloat)mn_brightnessComponent;
	

#pragma mark - Texture

- (UIColor *)mn_colorWithTexture;


#pragma mark - Derived Colors

- (UIColor *)mn_darkenedColor;
- (UIColor *)mn_lightenedColor;


@end
