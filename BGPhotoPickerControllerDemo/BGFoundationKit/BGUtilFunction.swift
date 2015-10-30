//
//  BGFoundationFunction.swift
//  BGFoundationKitDemo
//
//  Created by user on 15/10/15.
//  Copyright © 2015年 BG. All rights reserved.
//

import UIKit

// MARK: - color
func RGB(r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ alpha: CGFloat = 1.0) -> UIColor{
    let color = UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: alpha)
    return color
}