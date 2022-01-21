# Simple-RxSwift
💆🏻‍♂️ 만들면서 이해하는 알엑스

## Intro
익명 Observable, 익명 Observer만 존재하는 간단한 리액티브를 구현하는 저장소입니다.</br>
https://github.com/ReactiveX/RxSwift 코드를 최대한 따라가면서, 기본적인 기능을 제공하는 코드만 남겨 복잡한 코드를 간결하게 만들어 리액티브 프로그래밍의 원리를 이해하는데 집중합니다. 이해한 내용은 이곳과 블로그에 정리합니다!

## 제공하는 기능
- Observable 생성
- 이벤트는 next, error, completed 만 지원
- 생성한 Observable 구독
- 구독 취소

## 이해하고자 하는 객체들

### [AnonymousObservable](https://github.com/ReactiveX/RxSwift/blob/b4307ba0b6425c0ba4178e138799946c3da594f8/RxSwift/Observables/Create.swift#L64)

- AnonymousObservable은 create를 통해 새로운 Observable을 생성할 때 반환되는 인스턴스 입니다.
- AnonymousObservable은 생성자로 subscribeHandler를 받습니다. 이 핸들러는 AnonymousObservable 인스턴스에 대한 구독(subscribe)가 발생하면 실행됩니다.

  ```swift
   init(_ subscribeHandler: @escaping SubscribeHandler) {
        self.subscribeHandler = subscribeHandler
    }
  ```

- 따라서 create 메서드와 함께 전달하는 클로저가 subscribeHanlder에 저장됩니다.

  ```swift
  let observable = Observable<Int>.create { observer in // 이 trailing closure가 subscribeHanlder에 저장됨.
    observer.onNext(1)
    observer.onNext(2)
    observer.onCompleted()
    return Disposables.create()
  }
  ```
- AnonymousObservable은 Producer 클래스를 상속합니다. 따라서 subscribe가 발생하면 Producer의 subscribe가 호출되고, AnonymousObservable은 Producer의 run 메서드를 오버라이딩해 정의합니다. run 메서드는 sink와 subscription 인스턴스를 생성해 튜플로 반환합니다.

  ```swift
  override func run<Observer: ObserverType>(
        _ observer: Observer,
        cancel: Cancelable
    ) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = AnonymousObservableSink(observer: observer, cancel: cancel)
        let subscription = sink.run(self)
        
        return (sink: sink, subscription: subscription)
    }
  ```

### [AnonymousObservableSink](https://github.com/ReactiveX/RxSwift/blob/b4307ba0b6425c0ba4178e138799946c3da594f8/RxSwift/Observables/Create.swift#L25)

- AnonymousObservableSink는 AnonymousObservable로부터 이벤트를 받을 수 있게 하는 객체입니다. 
- 내부에 run 메서드를 구현하고 있고, 이 메서드의 인자로 전달되는 AnonymousObservable의 subscribeHandler를 실행시켜 이벤트를 받게됩니다.

  ```swift
  func run(_ parent: Parent) -> Disposable {
        return parent.subscribeHandler(AnyObserver(self))
    }
  ```
  
 - AnonymousObservableSink는 메서드는 ObservableType을 채택하고 있기 때문에 자체적인 on 메서드를 구현하고 있습니다. 이 on 메서드는 자신의 부모클래스인 Sink의 forwardOn 메서드를 호출하고 이를 통해 이벤트를 전달합니다.

    ```swift
     func on(_ event: Event<Element>) {
            switch event {
            case .next:
                self.forwardOn(event: event)
            case .error, .completed:
                self.forwardOn(event: event)
                self.dispose()
            }
     }
    ```

### [AnonymousObserver](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/Observers/AnonymousObserver.swift)
- AnonoymousObserver는 subscribe 내부에서 생성하게되는 Observer입니다.

  ```swift
  let observer = AnonymousObserver<Element> { event in
            switch event {
            case .next(let value):
                onNext?(value)
            case .error(let error):
                onError?(error)
                disposable.dispose() 
            case .completed:
                onCompleted?()
                disposable.dispose()
            }
        }
  ```

### [AnyObserver](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/AnyObserver.swift)

### [Cancelable](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/Cancelable.swift)

### [Disposables](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/Disposables/Disposables.swift)

### [Disposable](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/Disposable.swift)

### [Event](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/Event.swift)

### [Observable](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/Observable.swift)

### [ObservableConvertibleType](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/ObservableConvertibleType.swift)

### [ObservableType](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/ObservableType.swift)

### [ObserverType](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/ObserverType.swift)

### [Producer](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/Observables/Producer.swift)

### [Sink](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/Observables/Sink.swift)

### [SinkDisposer](https://github.com/ReactiveX/RxSwift/blob/b4307ba0b6425c0ba4178e138799946c3da594f8/RxSwift/Observables/Producer.swift#L39)

## 이해하고자 하는 동작들

### Observable.create를 하면 일어나는 일 

### observable.subscribe를 하면 일어나는 일
