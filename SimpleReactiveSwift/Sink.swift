//
//  Sink.swift
//  SimpleReactiveSwift
//
//  Created by 전여훈 on 2022/01/21.
//

import Foundation

class Sink<Observer: ObserverType>: Disposable {
    fileprivate let observer: Observer
    fileprivate let cancel: Cancelable
    
    init(observer: Observer, cancel: Cancelable) {
        self.observer = observer
        self.cancel = cancel
    }
    
    func fowardOn(event: Event<Observer.Element>) {
        self.observer.on(event)
    }
    
    func dispose() {
        self.cancel.dispose()
    }
}
