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
    
    /* 여행 12 */
    // Sink 에는 두 개의 프로퍼티가 있다. observer와 cancel. 지금까지 계속 인자로 넘기던 그 친구들이다.
    // 잊었을까봐 다시 언급하면 observer는 이벤트 처리 클로저를 담은 eventHandler를 가지고 있는 AnonymousObserver 객체이고, cancel은 아직은 비어있는 sink와 subscription을 가진 SinkDisposer 객체이다.
    // 그럼 정리해보면 subscribe 가장 처음 호출하면서 만들었던 AnonymousObserver와 SinkDisposer 인스턴스이다.
    init(observer: Observer, cancel: Cancelable) {
        self.observer = observer
        self.cancel = cancel
    }
    
    /* 여행 16 */
    // forwardOn이 하는 일은 단순하다. 이벤트를 받아서, 등록된 옵저버에게 건네주면 끝이다.
    // 여기에 등록된 옵저버는 아까 계속 잊지말자고 했던 subscribe를 호출하면서 만들었던 AnonymousObserver, 즉, main에서 정의한 이벤트 처리 로직을 들고있는 인스턴스이다.
    // 
    func forwardOn(event: Event<Observer.Element>) {
        /* 여행 23 */
        // 최종적으로 Sink가 가지고 있던 observer의 on 메서드가 호출된다.
        // 지금 Sink가 가지고 있는 Observer의 타입은 AnonymousObserver이다. 따라서 AnonymousObserver의 on을 찾아가자.
        // 그런데 AnonymousObserver에는 on의 구현이 없다. 상위 클래스인 ObserverBase로 찾아가야한다.
        self.observer.on(event)
    }
    
    func dispose() {
        self.cancel.dispose()
    }
}
