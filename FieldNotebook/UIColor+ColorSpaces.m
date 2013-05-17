//
//  NSColor+WebColor.m
//  MNColorPicker
//

#import "UIColor+ColorSpaces.h"


@implementation UIColor (ColorSpaces)


#pragma mark -
#pragma mark WebColor 


- (NSString *)mn_webColorString {
	
	if (![self mn_canProvideRGBColor]) return nil;
	
	return [NSString stringWithFormat:@"#%02X%02X%02X", ((NSUInteger)([self mn_redComponent] * 255)), 
			((NSUInteger)([self mn_greenComponent] * 255)), ((NSUInteger)([self mn_blueComponent] * 255))];
	
}

+ (UIColor *)mn_colorFromWebColorString: (NSString *)colorString {

	NSUInteger length = [colorString length];
	if (length > 0) {
		// remove prefixed #
		colorString = [colorString stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"#"]];
		length = [colorString length];
		
		// calculate substring ranges of each color
		// FFF or FFFFFF
		NSRange redRange, blueRange, greenRange;
		if (length == 3) {
			redRange = NSMakeRange(0, 1);
			greenRange = NSMakeRange(1, 1);
			blueRange = NSMakeRange(2, 1);
		} else if (length == 6) {
			redRange = NSMakeRange(0, 2);
			greenRange = NSMakeRange(2, 2);
			blueRange = NSMakeRange(4, 2);
		} else {
			return nil;
		}

		// extract colors
		NSUInteger redComponent, greenComponent, blueComponent; 
		BOOL valid = YES;
		NSScanner *scanner = [NSScanner scannerWithString:[colorString substringWithRange:redRange]];
		valid = [scanner scanHexInt:&redComponent];
		
		scanner = [NSScanner scannerWithString:[colorString substringWithRange:greenRange]];
		valid = ([scanner scanHexInt:&greenComponent] && valid);

		scanner = [NSScanner scannerWithString:[colorString substringWithRange:blueRange]];
		valid = ([scanner scanHexInt:&blueComponent] && valid);

		if (valid) {
			return [UIColor colorWithRed:redComponent/255.0 green:greenComponent/255.0 blue:blueComponent/255.0 alpha:1.0f];
		}
	}
	
	return nil;
}


#pragma mark -
#pragma mark String

- (NSString *)mn_stringFromColor {
	NSAssert ([self mn_canProvideRGBColor], @"Must be a RGB color to use -red, -green, -blue");
	
	NSString *result;
	switch ([self mn_colorSpaceModel]) {
		case kCGColorSpaceModelRGB:
			result = [NSString stringWithFormat:@"{%0.3f, %0.3f, %0.3f, %0.3f}", [self mn_redComponent], [self mn_greenComponent], [self mn_blueComponent], [self mn_alphaComponent]];
			break;
		case kCGColorSpaceModelMonochrome:
			result = [NSString stringWithFormat:@"{%0.3f, %0.3f}", [self mn_whiteComponent], [self mn_alphaComponent]];
			break;
		default:
			result = nil;
	}
	return result;
}

+ (UIColor *)mn_colorFromString: (NSString *)colorString {
	NSScanner *scanner = [NSScanner scannerWithString:colorString];
	if (![scanner scanString:@"{" intoString:NULL]) return nil;
	const NSUInteger kMaxComponents = 4;
	CGFloat c[kMaxComponents];
	NSUInteger i = 0;
	if (![scanner scanFloat:&c[i++]]) return nil;
	while (1) {
		if ([scanner scanString:@"}" intoString:NULL]) break;
		if (i >= kMaxComponents) return nil;
		if ([scanner scanString:@"," intoString:NULL]) {
			if (![scanner scanFloat:&c[i++]]) return nil;
		} else {
			// either we're at the end of there's an unexpected character here
			// both cases are error conditions
			return nil;
		}
	}
	if (![scanner isAtEnd]) return nil;
	UIColor *color;
	switch (i) {
		case 2: // monochrome
			color = [UIColor colorWithWhite:c[0] alpha:c[1]];
			break;
		case 4: // RGB
			color = [UIColor colorWithRed:c[0] green:c[1] blue:c[2] alpha:c[3]];
			break;
		default:
			color = nil;
	}
	return color;
}




#pragma mark -
#pragma mark Propery List

+ (UIColor *)mn_colorFromPropertyRepresentation:(id)colorObject
{
	UIColor *color = nil;
	if ([colorObject isKindOfClass:[NSString class]]) {
		color = [UIColor mn_colorFromString:colorObject];
		if (!color) {
			color = [UIColor mn_colorFromWebColorString:colorObject];
		}
	} else if ([colorObject isKindOfClass:[NSData class]]) {
		color = [NSKeyedUnarchiver unarchiveObjectWithData:colorObject];
	} else if ([colorObject isKindOfClass:[UIColor class]]){
		color = colorObject;
	}
	return color;
}

- (id)mn_propertyRepresentation 
{
	NSString *colorString = [self mn_stringFromColor];
	if (colorString) return colorString;
	
	return nil;
}


#pragma mark -
#pragma mark RGB

// The RGB code is based on:
// http://arstechnica.com/apple/guides/2009/02/iphone-development-accessing-uicolor-components.ars

- (BOOL)mn_canProvideRGBColor {
	return (([self mn_colorSpaceModel] == kCGColorSpaceModelRGB) || ([self mn_colorSpaceModel] == kCGColorSpaceModelMonochrome));
}

- (CGColorSpaceModel)mn_colorSpaceModel {
	return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

- (CGFloat)mn_redComponent {
	NSAssert ([self mn_canProvideRGBColor], @"Must be a RGB color to use -red, -green, -blue");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	return c[0];
}

- (CGFloat)mn_greenComponent {
	NSAssert ([self mn_canProvideRGBColor], @"Must be a RGB color to use -red, -green, -blue");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	if ([self mn_colorSpaceModel] == kCGColorSpaceModelMonochrome) return c[0];
	return c[1];
}

- (CGFloat)mn_blueComponent {
	NSAssert ([self mn_canProvideRGBColor], @"Must be a RGB color to use -red, -green, -blue");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	if ([self mn_colorSpaceModel] == kCGColorSpaceModelMonochrome) return c[0];
	return c[2];
}

- (CGFloat)mn_alphaComponent {
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	return c[CGColorGetNumberOfComponents(self.CGColor)-1];
}

- (CGFloat)mn_whiteComponent {
	NSAssert([self mn_colorSpaceModel] == kCGColorSpaceModelMonochrome, @"Must be a Monochrome color to use -white");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	return c[0];
}

#pragma mark -
#pragma mark HSV

// conversion: http://en.wikipedia.org/wiki/HSL_and_HSV
// calculates HSV values

- (CGFloat)mn_hueComponent {
	if (![self mn_canProvideRGBColor]) return 0;
	CGFloat r = [self mn_redComponent];
	CGFloat g = [self mn_greenComponent];
	CGFloat b = [self mn_blueComponent];
	
	CGFloat min = MIN(MIN(r,g),b);
	CGFloat max = MAX(MAX(r,g),b);
	
	CGFloat hue = 0;
	if (max==min) {
		hue = 0;
	} else if (max == r) {
		hue = fmod((60 * (g-b)/(max-min) + 360), 360);
	} else if (max == g) {
		hue = (60 * (b-r)/(max-min) + 120);
	} else if (max == b) {
		hue = (60 * (r-g)/(max-min) + 240);
	}
	return hue / 360;
}


- (CGFloat)mn_saturationComponent {
	if (![self mn_canProvideRGBColor]) return 0;
	CGFloat r = [self mn_redComponent];
	CGFloat g = [self mn_greenComponent];
	CGFloat b = [self mn_blueComponent];
	
	CGFloat min = MIN(MIN(r,g),b);
	CGFloat max = MAX(MAX(r,g),b);
	
	if (max==0) {
		return 0;
	} else {
		return (max-min)/(max);
	}
}

- (CGFloat)mn_brightnessComponent {
	if (![self mn_canProvideRGBColor]) return 0;
	CGFloat r = [self mn_redComponent];
	CGFloat g = [self mn_greenComponent];
	CGFloat b = [self mn_blueComponent];
	
	CGFloat max = MAX(MAX(r,g),b);
	
	return max;
}


#pragma mark - Texture

- (UIColor *)mn_colorWithTexture
{
    CGSize imageSize = CGSizeMake(250, 250);
    CGRect drawRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    
    UIGraphicsBeginImageContext(imageSize);
    
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.CGColor);
    CGContextFillRect(context, drawRect);
    
    // blend noise on top
    CGContextSetBlendMode(context, kCGBlendModeOverlay);
    CGImageRef cgImage = [UIImage imageNamed:@"noiseTexture.png"].CGImage;
    CGContextDrawImage(context, drawRect, cgImage);
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    UIImage *textureImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();


    UIColor *texturedColor = [UIColor colorWithPatternImage:textureImage];
    return texturedColor;
}


#pragma mark - Derived Colors

- (UIColor *)mn_darkenedColor
{
    CGFloat delta = 0.1f;
    if (![self mn_canProvideRGBColor]) return self;
    
    CGFloat redComponent = MAX([self mn_redComponent]-delta,0);
    CGFloat greenComponent = MAX([self mn_greenComponent]-delta,0);
    CGFloat blueComponent = MAX([self mn_blueComponent]-delta,0);
    CGFloat alphaComponent = [self mn_alphaComponent];	

    UIColor *darkenedColor = [UIColor colorWithRed:redComponent green:greenComponent blue:blueComponent alpha:alphaComponent];
    return darkenedColor;
}

- (UIColor *)mn_lightenedColor
{
    CGFloat delta = 0.1f;
    if (![self mn_canProvideRGBColor]) return self;
    
    CGFloat redComponent = MIN([self mn_redComponent]+delta,0);
    CGFloat greenComponent = MIN([self mn_greenComponent]+delta,0);
    CGFloat blueComponent = MIN([self mn_blueComponent]+delta,0);
    CGFloat alphaComponent = [self mn_alphaComponent];	
    
    UIColor *lightenedColor = [UIColor colorWithRed:redComponent green:greenComponent blue:blueComponent alpha:alphaComponent];
    return lightenedColor;
}


@end
