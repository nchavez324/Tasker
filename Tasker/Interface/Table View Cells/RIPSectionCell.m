//
//  RIPSectionCell.m
//  Notepad
//
//  Created by Nick on 1/22/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "RIPCompletion.h"
#import "RIPCircleButton.h"
#import "RIPSectionCell.h"

@interface RIPSectionCell ()
@property (weak, nonatomic) IBOutlet RIPCircleButton *colorButton;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@end

@implementation RIPSectionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self initialize];
    }
    return self;
}

- (void)initialize {
    _titleField.text = NSLocalizedString(@"UNTITLED", @"Untitled");
    [self setEditingMode:NO];
    [self setSelectedMode:NO];
}

- (void)setTitle:(NSString *)title {
    _titleField.text = title;
}

- (NSString *)getTitle {
    return _titleField.text;
}

- (void)setColor:(UIColor *)color {
    [_colorButton setCompletion:1.0 animated:NO];
    [_colorButton setColor:color animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self setSelectedMode:selected];
    // Configure the view for the selected state
}

- (void)setSelectedMode:(BOOL)selected {
    UIColor *textColor = selected?[UIColor whiteColor]:[UIColor blackColor];
    UIColor *bgColor = selected?[UIColor lightGrayColor]:[UIColor whiteColor];
    _titleField.textColor = textColor;
    self.backgroundColor = bgColor;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self setEditingMode:editing];
}

- (void)setEditingMode:(BOOL)editing {
    if(editing){
        _titleField.textColor = [UIColor darkGrayColor];
        _titleField.borderStyle = UITextBorderStyleRoundedRect;
        _titleField.userInteractionEnabled = YES;
    }else{
        _titleField.textColor = [UIColor blackColor];
        _titleField.borderStyle = UITextBorderStyleNone;
        _titleField.userInteractionEnabled = NO;
    }
}

@end
