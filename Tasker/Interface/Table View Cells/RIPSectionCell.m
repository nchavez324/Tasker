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
  UIColor *unselectedBGColor = UIColor.whiteColor;
  UIColor *unselectedTextColor = UIColor.blackColor;
  UIColor *selectedBGColor = UIColor.lightGrayColor;
  UIColor *selectedTextColor = UIColor.whiteColor;
  if (@available(iOS 13.0, *)) {
    unselectedBGColor = UIColor.systemBackgroundColor;
    unselectedTextColor = UIColor.labelColor;
    selectedBGColor = UIColor.secondarySystemBackgroundColor;
    selectedTextColor = UIColor.labelColor;
  }
  
  self.titleField.textColor = selected ? selectedTextColor : unselectedTextColor;
  self.backgroundColor = selected ? selectedBGColor : unselectedBGColor;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self setEditingMode:editing];
}

- (void)setEditingMode:(BOOL)editing {
  UIColor *defaultColor = UIColor.blackColor;
  UIColor *editingColor = UIColor.darkGrayColor;
  if (@available(iOS 13.0, *)) {
    defaultColor = UIColor.labelColor;
    editingColor = UIColor.secondaryLabelColor;
  }
  if (editing) {
    self.titleField.textColor = editingColor;
    self.titleField.borderStyle = UITextBorderStyleRoundedRect;
    self.titleField.userInteractionEnabled = YES;
  } else {
    self.titleField.textColor = defaultColor;
    self.titleField.borderStyle = UITextBorderStyleNone;
    self.titleField.userInteractionEnabled = NO;
  }
}

@end
