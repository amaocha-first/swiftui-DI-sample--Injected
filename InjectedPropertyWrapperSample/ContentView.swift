//
//  ContentView.swift
//  InjectedPropertyWrapperSample
//
//  Created by shota-nishizawa on 2022/12/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var feature = Feature()
    var body: some View {
        Text(feature.data)
            .onAppear {
                feature.performDataRequest()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - Application Layer
@MainActor
final class Feature: ObservableObject {
    @Published private(set) var data: String = ""
    @Injected(\.networkProvider) var networkProvider

    func performDataRequest() {
        data = networkProvider.requestData()
    }
}

private struct NetworkProviderKey: InjectionKey {
    static var currentValue: NetworkProviding = NetworkProvider()
}

extension InjectedValues {
    var networkProvider: NetworkProviding {
        get { Self[NetworkProviderKey.self] }
        set { Self[NetworkProviderKey.self] = newValue }
    }

    var hoge: NetworkProviding {
        get { Self[NetworkProviderKey.self] }
        set { Self[NetworkProviderKey.self] = newValue }
    }
}

// MARK: - Repository Layer (Protocol)
protocol NetworkProviding {
    func requestData() -> String
}

// MARK: - Repository Layer (Implementation)
struct NetworkProvider: NetworkProviding {
    func requestData() -> String {
        print("Data requested using the `NetworkProvider`")
        return "raw data"
    }
}

// MARK: - Injection Layer
@propertyWrapper
struct Injected<T> {
    private let keyPath: WritableKeyPath<InjectedValues, T>
    var wrappedValue: T {
        get { InjectedValues[keyPath] }
        set { InjectedValues[keyPath] = newValue }
    }

    init(_ keyPath: WritableKeyPath<InjectedValues, T>) {
        self.keyPath = keyPath
    }
}

public protocol InjectionKey {

    /// The associated type representing the type of the dependency injection key's value.
    associatedtype Value

    /// The default value for the dependency injection key.
    static var currentValue: Self.Value { get set }
}


/// Provides access to injected dependencies.
struct InjectedValues {

    /// This is only used as an accessor to the computed properties within extensions of `InjectedValues`.
    private static var current = InjectedValues()

    /// A static subscript for updating the `currentValue` of `InjectionKey` instances.
    static subscript<K>(key: K.Type) -> K.Value where K : InjectionKey {
        get { key.currentValue }
        set { key.currentValue = newValue }
    }

    /// A static subscript accessor for updating and references dependencies directly.
    static subscript<T>(_ keyPath: WritableKeyPath<InjectedValues, T>) -> T {
        get { current[keyPath: keyPath] }
        set { current[keyPath: keyPath] = newValue }
    }
}
