//
//  MetricsContext.swift
//  Metrics
//
//  Created by Oleksandr Liashko on 3/5/19.
//  Copyright © 2019 Oleksandr Liashko. All rights reserved.
//

import Foundation
import UIKit

/**
 Metrics iOS SDK.
 
 Use the Metrics SDK to track and report events occured in your application.
 
 Developers using the Metrics SDK with their app are required to register for
 a credential, and to specify the credential (apiKey) in their application.
 Failure to do so results in blocked access to certain features and degradation
 in the quality of other services.
 
 To obtain these credentials, visit the developer portal at https://api.approver.io/dev
 and register for a license.
 
 - Note: Credentials are unique to your application's bundle identifier.
 Do not reuse credentials across multiple applications.
 
 Adding Credentials
 
 Ensure that you have provided the apiKey before using the Metrics SDK.
 For example, set them in your app delegate:
 
 ```
 func application(_ application: UIApplication,
 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    try? Metrics.shared.initialize(apiKey: "{YOUR_API_KEY}")
 }
 ```
 */
public final class Metrics : NSObject {
    
    // MARK: - Properties
    
    /// The shared singleton session object.
    @objc public static let shared = Metrics()
    
    /// Identifier for the current user.
    public var userId: String {
        return engine.deviceInfo.userId
    }
    
    /// Identifier for the current device.
    public var deviceId: String {
        return engine.deviceInfo.deviceId
    }
    
    /// Returns API key
    public var apiKey: String? {
        return engine.apiKey
    }
    
    /// Disables sending logged events to Metrics servers.
    /// - Tag: offlineMode
    public var offlineMode: Bool {
        get { return engine.sessionAttr.offlineMode != 0 }
        set { engine.sessionAttr.offlineMode = newValue ? 1 : 0 }
    }
    
    /// The number of events that will be uploaded in a single request. The default is 100 events.
    /// - Tag: eventUploadBatchSize
    public var eventUploadBatchSize : UInt {
        get { return engine.sessionAttr.batchSize }
        set { engine.sessionAttr.batchSize = newValue }
    }
    
    /// The maximum number of events that can be stored lcoally. The default is 1000 events.
    public var eventMaxCount : UInt {
        get { return engine.sessionAttr.maxStoreSizeCount }
        set { engine.sessionAttr.maxStoreSizeCount = newValue }
    }
    
    /// After a certain time, periodically, sending collected events to backend.
    /// - Tag: eventUploadPeriodSeconds
    public var eventUploadPeriodSeconds : UInt {
        get { return engine.sessionAttr.uploadPeriodSeconds }
        set { engine.sessionAttr.uploadPeriodSeconds = newValue }
    }
    
    // MARK: - Methods
    
    /**
     Immediately upload all unsent events regardless of [offlineMode](x-source-tag://offlineMode),
     [eventUploadBatchSize](x-source-tag://eventUploadBatchSize)
    */
    @objc public func uploadEvents() {
        engine.uploadEvents()
    }
    
    /**
     Initialize the mandatory Metrics SDK Credentials notably API key
     
     - Parameters:
        - apiKey Metrics SDK API key obtained from developer portal at https://api.approver.io/dev
     
     - Throws: `MetricsError.invalidAppKey`
    */
    @objc public func initialize(apiKey key: String) throws {
        try engine.initialize(apiKey: key)
    }
    
    
    /**
     Update or register dynamic views
     
     If no View has been registered for exact id yet then corresponding
     blanc view will be created on backend side and return instantly.
     If there is any problem with connection then preliminarilly
     stored views are used.
     
     - Parameters:
        - ids Dynamic views ids
    */
    @objc public func dynamicViews(ids: [String]) {
        engine.dynamicViews(ids: ids)
    }
    
    // MARK: - Internal
    private let engine = MetricsEngine.shared
    private override init() { }
}


public extension Metrics {
    
    // MARK: - Logging
    
    /**
     Log an event.
     
     Uploads are batched to occur every [eventUploadBatchSize](x-source-tag://eventUploadBatchSize)
     events or every [eventUploadPeriodSeconds](x-source-tag://eventUploadPeriodSeconds)
     seconds (whichever comes first), as well as on app close.
     
     - Parameters:
        - name The name of the event to be tracked
    */
    static func logEvent(_ name: String) {
        let eventType = EventType.manual
        let trackedEvent = EventFactory.event(name, eventType: eventType)
        
        log(eventType, eventInfo: trackedEvent)
    }
    
    /**
     Log an event.
     
     Uploads are batched to occur every [eventUploadBatchSize](x-source-tag://eventUploadBatchSize)
     events or every [eventUploadPeriodSeconds](x-source-tag://eventUploadPeriodSeconds)
     seconds (whichever comes first), as well as on app close.
     
     - Parameters:
        - name The name of the event to be tracked
        - attributes Arbitrary key:values attributes to be tracked
    */
    static func logEvent(_ name: String, attributes: [String : String]) {
        let eventType = EventType.manual
        let trackedEvent = EventFactory.event(name, attributes: attributes, eventType: eventType)
        
        log(eventType, eventInfo: trackedEvent)
    }
    
    
    /**
     Log an user info.
     
     An user info uploads immediately
     
     - Parameters:
        - attributes Exact key-value attributes to be recorded.
    */
    static func logUserInfo(_ attributes: [String : String]) {
        MetricsEngine.shared.uploadUserInfo(attributes)
    }
}


