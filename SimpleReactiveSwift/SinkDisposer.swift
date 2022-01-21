//
//  SinkDisposer.swift
//  SimpleReactiveSwift
//
//  Created by 전여훈 on 2022/01/21.
//

import Foundation

class SinkDisposer: Cancelable {
    private var sink: Disposable?
    private var subscription: Disposable?
    
    func setSinkAndSubscription(sink: Disposable, subscription: Disposable) {
        self.sink = sink
        self.subscription = subscription
    }
    
    func dispose() {
        self.sink?.dispose()
        self.subscription?.dispose()
        self.sink = nil
        self.subscription = nil
    }
}
