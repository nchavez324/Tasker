//
//  RIPNoteCell.m
//  Notepad
//
//  Created by Nick on 1/23/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "RIPCircleButton.h"
#import "RIPNoteCell.h"

@interface RIPNoteCell ()
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet RIPCircleButton *colorButton;
@end

@implementation RIPNoteCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    _titleField.text = NSLocalizedString(@"UNTITLED", @"Untitled");
    
    [self setSelectedMode:NO];
    [self setEditingMode:NO];
}

- (void)setCompletion:(float)completion animated:(BOOL)animated {
    [_colorButton setCompletion:completion animated:animated];
}

- (void)setTitle:(NSString *)title {
    _titleField.text = title;
}

- (void)setColor:(UIColor *)color animated:(BOOL)animated {
    [_colorButton setColor:color animated:animated];
}

- (NSString *)getTitle {
    return _titleField.text;
}

- (float)getCompletion {
    return [_colorButton getCompletion];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self setSelectedMode:selected];
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
        _titleField.borderStyle = UITextBorderStyleRoundedRect;
        _titleField.userInteractionEnabled = YES;
    }else{
        _titleField.borderStyle = UITextBorderStyleNone;
        _titleField.userInteractionEnabled = NO;
    }
}

@end
