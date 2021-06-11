//
//  WidgetsTools.swift
//  PetoiControllerSwift
//
//  Created by Orlando Chen on 2021/3/29.
//

import Foundation
import UIKit

class WidgetTools
{
    // 添加下划线
    static func underline(label: UILabel)
    {
        if let text = label.text {
            let attributedString =
                NSAttributedString(string: text,
                                   attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
            label.attributedText = attributedString
        }
    }
    
    // 设置不可用
    static func disable(button: UIButton) {
        button.isEnabled = false
        button.alpha = 0.4
    }
    
    // 设置可用
    static func enable(button: UIButton) {
        button.isEnabled = true
        button.alpha = 1.0
    }
    
    // 添加下划线
    static func underline(textfield: UITextField, color: UIColor)
    {
        let underLine = UIView.init(frame: CGRect.init(x: 0, y: textfield.height - 2, width: textfield.width, height: 2))
        underLine.backgroundColor = color
        textfield.addSubview(underLine)
        textfield.borderStyle = .none
    }
    
    // 设置圆角矩形
    static func roundCorner(button: UIButton)
    {
        button.layer.borderWidth = 1
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
    }
    
    // 设置圆角矩形
    static func roundCorner(textView: UITextView, boardColor: UIColor)
    {
        textView.layer.borderColor = ColorConverter.convert(color: boardColor)
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
    }
    
    // 调整透明度
    static func transparent(textView: UITextView, alpha: Float32)
    {
        textView.layer.backgroundColor = ColorConverter.convert(color: UIColor.clear)
    }
    
    // UI控件图层顺序调整
    static func bringSubviewToFront(parent: UIView, child: UIView) {
        parent.bringSubviewToFront(child)
    }
    
    // UI控件图层顺序调整
    static func sendSubviewToBack(parent: UIView, child: UIView) {
        parent.sendSubviewToBack(child)
    }
}
