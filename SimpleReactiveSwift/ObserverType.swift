//
//  ObserverType.swift
//  SimpleReactiveSwift
//
//  Created by 전여훈 on 2022/01/21.
//

import Foundation

protocol ObserverType {
    associatedtype Element
    func on(_ event: Event<Element>)
}

extension ObserverType {
    /* 여행 20 */
    // onNext는 ObservableType에서 제공해주는 on(.next(element))의 축약형이었다..
    // 그럼 결국 AnyObserver의 on을 찾아가면된다.
    public func onNext(_ element: Element) {
        self.on(.next(element))
    }
    
    public func onCompleted() {
        self.on(.completed)
    }
    
    public func onError(_ error: Swift.Error) {
        self.on(.error(error))
    }
}
