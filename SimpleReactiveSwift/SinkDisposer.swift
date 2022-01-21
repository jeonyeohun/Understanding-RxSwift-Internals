//
//  SinkDisposer.swift
//  SimpleReactiveSwift
//
//  Created by 전여훈 on 2022/01/21.
//

import Foundation

/* 여행 9 */
// SinkDisposer에 도착했다. 내부에 어떻게 되어있는지 확인해보자.
class SinkDisposer: Cancelable {
    // SinkDisposer는 두 개의 프로퍼티를 가지고 있다. sink와 subscription.
    private var sink: Disposable?
    private var subscription: Disposable?
    
    // 그리고 이 메서드가 실행되면 두 프로퍼티를 채워주고,
    func setSinkAndSubscription(sink: Disposable, subscription: Disposable) {
        self.sink = sink
        self.subscription = subscription
    }
    
    // dispose가 실행되면 sink와 subscription을 모두 dispose한다.
    // 일단 인스턴스를 만들기만 했으니까 다시 돌아가자. sink와 subscription이 내부에 있고 둘 다 Disposable 타입이라는 것을 기억하면 될 것 같다.
    func dispose() {
        self.sink?.dispose()
        self.subscription?.dispose()
        self.sink = nil
        self.subscription = nil
    }
}
