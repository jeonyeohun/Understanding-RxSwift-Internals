//
//  AnonymousObservable.swift
//  SimpleReactiveSwift
//
//  Created by 전여훈 on 2022/01/21.
//

import Foundation

class AnonymousObservable<Element>: Producer<Element> {
    typealias SubscribeHandler = (AnyObserver<Element>) -> Disposable
    
    let subscribeHandler: SubscribeHandler
    
    /* 여행 3 */
    // 아까 만들었던 두 개의 정수를 next로 방출하고 completed를 방출하는 클로저가 생성자에 전달된다.
    // 그리고 생성자에서는 subscribeHandler에 클로저를 저장하고 끝이다.
    // 이름만 보고 유추해보면 그 클로저를 구독자가 발생하면 실행하는 것 같다.
    // 일단 create를 통해 알 수 있는 정보는 이게 다인 것 같다. 다시 main으로 돌아가자.
    init(_ subscribeHandler: @escaping SubscribeHandler) {
        self.subscribeHandler = subscribeHandler
    }
    
    /* 여행 10 */
    // run으로 왔다. 여기에 전달되는 인자는 observer와 cancelable이다.
    override func run<Observer: ObserverType>(
        _ observer: Observer,
        cancel: Cancelable
    ) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        // 가장 먼저 하는건 AnonymousObservableSink를 만드는 것이다. 이게 뭐람..
        // 들어가보자. Jump to definition.
        
        // 결국엔 AnonymousObservableSink 인스턴스를 만드는 것 외에는 따로 하는게 없고, 이 인스턴스는 생성자에서 자신의 부모 클래스인 Sink에게 observer와 cancel을 전달한다.
        let sink = AnonymousObservableSink(observer: observer, cancel: cancel)
        
        // subscription은 위에서 만든 AnonymousObservableSink의 run 메서드를 통해 만들어진다. 그리고 인자로는 self를 전달한다.
        // 여기서 self는 AnonymousObservable이다. self.asObservable().subscribe(observer) 여기서 asObservable()에서 반환된 그 녀석이 맞다.
        // sink.run으로 이동해보자. Jump to definition
        
        /* 여행 17 */
        // -- 이번 self는 또 다르다. { observer in self.subscribe(observer) } 여기에서 self와 같다. self.subscirbe로 producer가 불렸으니까 당연한 이야기다. run을 실행하자.
        let subscription = sink.run(self)
        
        return (sink: sink, subscription: subscription)
    }
}
