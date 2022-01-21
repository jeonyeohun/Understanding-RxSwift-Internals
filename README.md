# Simple-RxSwift
💆🏻‍♂️ 만들면서 이해하는 알엑스

## Intro
익명 Observable, 익명 Observer만 존재하는 간단한 리액티브를 구현하는 저장소입니다.</br>
https://github.com/ReactiveX/RxSwift 코드를 최대한 따라가면서, 기본적인 기능을 제공하는 코드만 남겨 복잡한 코드를 간결하게 만들어 리액티브 프로그래밍의 원리를 이해하는데 집중합니다. 이해한 내용은 이곳에 정리합니다!

## 제공하는 기능
- Observable 생성
- 이벤트는 next, error, completed 만 지원
- 생성한 Observable 구독
- 구독 취소

## 이해하고자 하는 객체들

### [AnonymousObservable](https://github.com/ReactiveX/RxSwift/blob/b4307ba0b6425c0ba4178e138799946c3da594f8/RxSwift/Observables/Create.swift#L64)

### [AnonymousObservableSink](https://github.com/ReactiveX/RxSwift/blob/b4307ba0b6425c0ba4178e138799946c3da594f8/RxSwift/Observables/Create.swift#L25)

### [AnonymousObserver](https://github.com/ReactiveX/RxSwift/blob/main/RxSwift/Observers/AnonymousObserver.swift)

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
