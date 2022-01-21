//
//  Producer.swift
//  SimpleReactiveSwift
//
//  Created by 전여훈 on 2022/01/21.
//

import Foundation

class Producer<Element>: Observable<Element> {
    /* 여행 8 */
    // 실제 RxSwift는 이것보다 더 복잡하다. 스레드를 선택하는 분기가 있어서 그렇다. 우리는 핵심만 보기로 했으니까 주요한 로직만 남기고 과감하게 지워주었다.
    override func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        /* 여행 16 */
        // -- 다시 Producer의 subscribe로 돌아왔다. 헷갈리지 않기 위해 다시 방문했을 때의 동작은 작대기를 붙여서 표현한다.
        
        // subscribe가 실행되면 하는 일을 확인해보자. 일단 인자로 전달된 observer 안에는 이벤트 별로 어떻게 처리할지 정의되어 있는 eventHandler가 등록되어 있다는 사실을 계속 기억하자.
        
        // 제일 먼저 하는 일은 SinkDisposer 인스턴스를 만드는 것이다.
        // 일단 모르겠으면 무조건 뭐다? Jump to definition.
        let disposer = SinkDisposer() // SinkDisposer가 뭔지 알았다. 그냥 안에 sink랑 subscription이라는 애들이 있는 것이다.
        
        // sink와 subscription은 여기에서 만든다. 이제는 run 메서드를 확인해보자.
        // 인자로 전달되는 객체는 eventHandler를 담은 observer와 방금 만든 비어있는 SinkDisposer 인스턴스이다.
        // run메서드는 AnonymousObservable에 정의되어 있다. Jump to definition.
        let sinkAndSubsription = self.run(observer, cancel: disposer)
        
        // -- 이번에도 똑같이 동작하지만 observer가 다르다. 이번 observer는 아까 생성했던 AnyObserver였다.
        // -- AnyObserver를 들고 run으로 들어가보자.

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
