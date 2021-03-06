//
//  CustomButton.m
//  PokerTracker
//
//  Created by Rick Medved on 6/26/15.
//
//

#import "CustomButton.h"
#import "ObjectiveCScripts.h"

#define CORNER_RADIUS          7.0

@implementation CustomButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit
{
	[self assignMode:(int)self.tag];
}

-(void)assignMode:(int)mode {
	// 0 = yellow
	// 1 = green
	// 2 = light-gray
	// 3 = red
	// 4 = gray (disabled)
	self.mode=mode;
	[self newButtonLook:self.mode];
}

-(void)newButtonLook:(int)mode {
	int theme=0;
	[self setTitleShadowColor:nil forState:UIControlStateNormal];
	
	[self setBackgroundImage:nil forState:UIControlStateNormal];
	[self setBackgroundImage:[UIImage imageNamed:@"greenBar.png"]
					forState:UIControlStateHighlighted];
	
	if(theme==0) { // modern
		self.layer.cornerRadius = 7;
		self.layer.masksToBounds = NO;
		self.layer.shadowColor = [UIColor blackColor].CGColor;
		self.layer.shadowOffset = CGSizeMake(4, 4);
		self.layer.shadowRadius = 5;
		self.layer.shadowOpacity = 0.85;
		self.layer.borderWidth = 0;
	} else if (theme==1) { //flat
		self.layer.cornerRadius = 0;
		self.layer.masksToBounds = YES;
		self.layer.shadowOffset = CGSizeMake(0, 0);
		self.layer.shadowRadius = 0;
		self.layer.shadowOpacity = 0;
		self.layer.borderWidth = 0;
	} else { // outline
		self.layer.cornerRadius = 4;
		self.layer.masksToBounds = NO;
		self.layer.shadowOffset = CGSizeMake(2, 2);
		self.layer.shadowRadius = 5;
		self.layer.shadowOpacity = 1;
		self.layer.shadowColor = [UIColor whiteColor].CGColor;
		self.layer.borderColor = [UIColor blackColor].CGColor;
		self.layer.borderWidth = 1;
	}
	
	if(mode==0) { // white
		[self setTitleColor:[UIColor colorWithRed:0 green:0 blue:.5 alpha:1] forState:UIControlStateNormal];
		[self setBackgroundColor:[UIColor whiteColor]];
		
	}
	if(mode==1) { // blue
		self.layer.borderColor = [UIColor whiteColor].CGColor;
		self.layer.borderWidth = 1;
		[self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self setBackgroundColor:[ObjectiveCScripts lightColor]];
		//[UIColor colorWithRed:.2 green:.8 blue:.2 alpha:1]
	}
	if(mode==2) { // gray
		[self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[self setBackgroundColor:[UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1]];
		
	}
	if(mode==3) { // red
		[self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self setBackgroundColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:1]];
		
	}
	if(mode==4) { // dark gray
		[self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
//		self.titleLabel.shadowColor = [UIColor whiteColor];
//		self.titleLabel.shadowOffset = CGSizeMake(-1, -1);
		[self setTitleColor:[UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1] forState:UIControlStateNormal];
		[self setBackgroundColor:[UIColor colorWithRed:.7 green:.7 blue:.7 alpha:1]];
		self.layer.shadowOffset = CGSizeMake(0, 0);
	}
	if(mode==5) { // blue
		[self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self setBackgroundColor:[UIColor colorWithRed:0 green:.6 blue:1 alpha:1]];
		
	}
	
}

-(void)setEnabled:(BOOL)enabled {
	[super setEnabled:enabled];
	if(enabled) {
		[self newButtonLook:self.mode];
		self.alpha=1;
	} else {
		[self newButtonLook:4];
		self.alpha=.9;
	}
}

- (UIImage *)imageFromColor:(UIColor *)color
{
	static NSMutableDictionary *colorImageCache = nil;
	if (colorImageCache == nil) {
		colorImageCache = [[NSMutableDictionary alloc] initWithCapacity:5];
	}
	
	UIImage *img = [colorImageCache objectForKey:color];
	
	if (img == nil) {
		CGRect rect = CGRectMake(0, 0, 1, 1);
		UIGraphicsBeginImageContext(rect.size);
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetFillColorWithColor(context, [color CGColor]);
		CGContextFillRect(context, rect);
		img = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		[colorImageCache setObject:img forKey:color];
	}
	return img;
}

@end
