//
//  HapticManager.swift
//  SoyBean
//
//  Created by 구태호 on 3/5/25.
//


import UIKit


public final class HapticManager {
    public static let shared = HapticManager()
    
    public let notificationGenerator = UINotificationFeedbackGenerator()
    public let selectionGenerator = UISelectionFeedbackGenerator()
    
    public enum HapticType {
        case impact(UIImpactFeedbackGenerator.FeedbackStyle)
        case notification(UINotificationFeedbackGenerator.FeedbackType)
        case selection
    }
    
    public func start(_ type: HapticType) {
        switch type {
        case .impact(let style):
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
            
        case .notification(let type):
            notificationGenerator.prepare()
            notificationGenerator.notificationOccurred(type)
            
        case .selection:
            selectionGenerator.prepare()
            selectionGenerator.selectionChanged()
        }
    }
    
    private init() {
        
    }
}
