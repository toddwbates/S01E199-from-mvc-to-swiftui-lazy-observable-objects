//
//  ContentView.swift
//  Recordings
//
//  Created by Florian Kugler on 20-03-2020.
//  Copyright © 2020 objc.io. All rights reserved.
//

import SwiftUI

func ??<A: View, B: View>(lhs: A?, rhs: B) -> some View {
    Group {
        if lhs != nil {
            lhs!
        } else {
            rhs
        }
    }
}

extension Item {
    var destination: some View {
        Group {
            if self is Folder {
                FolderList(folder: self as! Folder)
            } else {
                PlayerView(recording: self as! Recording) ?? Text("Something went wrong.")
            }
        }
    }
}

import Combine

@dynamicMemberLookup
final class Lazy<O: ObservableObject>: ObservableObject {
    var objectWillChange: O.ObjectWillChangePublisher {
        value.objectWillChange
    }
    var value: O {
        get {
            buildValueIfNeeded()
            return _value!
        }
    }

    private var _value: O? = nil
    private let build: () -> O
    
    init(_ build: @escaping () -> O) {
        self.build = build
    }
    
    func buildValueIfNeeded() {
        guard _value == nil else { return }
        _value = build()
    }
    
    subscript<Prop>(dynamicMember kp: ReferenceWritableKeyPath<O, Prop>) -> Prop {
        get {
            value[keyPath: kp]
        }
        set {
            value[keyPath: kp] = newValue
        }
    }
    
    subscript<Prop>(dynamicMember kp: KeyPath<O, Prop>) -> Prop {
        value[keyPath: kp]
    }
}

extension Item {
    var symbolName: String {
        self is Folder ? "folder" : "waveform"
    }
}

struct AlertWrapper<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let title: String
    let placeholder: String
    let callback: (String?) -> ()
    let content: Content
    
    init(isPresented: Binding<Bool>, title: String, placeholder: String, callback: @escaping (String?) -> (), content: Content) {
        self._isPresented = isPresented
        self.title = title
        self.placeholder = placeholder
        self.callback = callback
        self.content = content
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<AlertWrapper>) -> UIHostingController<Content> {
        UIHostingController(rootView: content)
    }
    
    func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: UIViewControllerRepresentableContext<AlertWrapper>) {
        uiViewController.rootView = content
        if isPresented && uiViewController.presentedViewController == nil {
            let vc = modalTextAlert(title: title, placeholder: placeholder, callback: { result in
                self.isPresented = false
                self.callback(result)
            })
            uiViewController.present(vc, animated: true)
        }
    }
}

extension View {
    func textAlert(isPresented: Binding<Bool>, title: String, placeholder: String = "", callback: @escaping (String?) -> ()) -> some View {
        AlertWrapper(isPresented: isPresented, title: title, placeholder: placeholder, callback: callback, content: self)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 5).fill(Color.orange))
            
    }
}

struct ContentView: View {
    let store = Store.shared
    var body: some View {
        NavigationView {
            FolderList(folder: store.rootFolder)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
