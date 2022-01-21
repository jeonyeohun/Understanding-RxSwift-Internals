//
//  main.swift
//  SimpleReactiveSwift
//
//  Created by 전여훈 on 2022/01/21.
//

import Foundation

/* 여행 1 */
// create에 들어가는 클로저의 타입은 (AnyObserver<Int>) -> Disposable) -> Observable<Int>.
// observer 혹은 emitter로 써오던 파라미터가 결국 AnyObserver였음을 알 수 있다. AnyObserver에 onNext나 onComplete 같은 이벤트를 방출해주는 것
// create의 반환 타입은 Observable. 즉, create는 말 그대로 observable을 만드는 메서드이고, 만들 때 내부에 방출할 이벤트를 전달해준다.
// 전달되는 클로저의 반환타입은 disposable이다. 그래서 Disposables.create를 호출해준다. create에 클로저가 전달되면 dispose가 호출되었을 때 그 클로저를 실행한다.
// 그럼 create 메서드를 더 자세히 보자. Observable.create가 있는 곳으로 이동하자. create에 우클릭하고 jump to definition 고고
let observable = Observable<Int>.create { observer in
    
    /* 여행 19 */
    // 클로저에 왔다. 이곳에 전달된 observer는 AnyObserver였다. onNext를 찾아가자.
    observer.onNext(1)
    observer.onNext(2)
    observer.onCompleted()
    return Disposables.create()
}

/* */


/* 여행 1 ~ 3 정리 */
// 지금까지의 여행을 통해 알 수 있는건 두 가지 였다.
// 1. create로 만드는건 Observable 타입이고, 메서드 호출 시 전달되는 클로저의 인자는 AnyObserver이다.
// 2. create의 구현은 ObservableType에 정의되어 있다. 여기서 하는 일은 AnonymousObservable을 만들어 반환하는 것이다. 이때 인자로 전달했던 클로저가 subscribeHandler로 등록된다.


/* 여행 4 */
// 이제 subscribe를 하면 어떤 일이 일어나는지 보자.
// subscribe 메서드 호출의 인자로 네 개의 클로저를 전달했다.
// 그럼 subscribe 메서드의 구현으로 이동해보자. Jump to definition.
let disposable = observable.subscribe(
    /* 여행 28 */
    // 도착했다! data에 이벤트의 값이 전달되고, 클로저에 따라 값을 출력한다.
    onNext: { data in print(data) },
    onError: { error in print(error) },
    onCompleted: { print("completed") },
    onDisposed: { print("dispose done") }
)
