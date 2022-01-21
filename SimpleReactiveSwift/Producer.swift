//
//  Producer.swift
//  SimpleReactiveSwift
//
//  Created by 전여훈 on 2022/01/21.
//

import Foundation

class Producer<Element>: Observable<Element> {
    override func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        let disposer = SinkDisposer()
        let sinkAndSubsription = self.run(observer, cancel: disposer)
        
        disposer.setSinkAndSubscription(sink: sinkAndSubsription.sink, subscription: sinkAndSubsription.subscription)
        return disposer
    }
    
    func run<Observer: ObserverType>(
        _ observer: Observer,
        cancel: Cancelable
    ) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        fatalError()
    }
}
