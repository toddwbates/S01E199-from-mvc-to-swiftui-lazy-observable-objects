//
//  ContentView.swift
//  Recordings
//
//  Created by Florian Kugler on 20-03-2020.
//  Copyright © 2020 objc.io. All rights reserved.
//

import SwiftUI
import CasePaths

func ??<A: View, B: View>(lhs: A?, rhs: B) -> some View {
  Group {
    if lhs != nil {
      lhs!
    } else {
      rhs
    }
  }
}

//extension Item {
//    var destination: some View {
//        Group {
//            if self is Folder {
//                FolderList(folder: self as! Folder)
//            } else {
//                PlayerView(recording: self as! Recording) ?? Text("Something went wrong.")
//            }
//        }
//    }
//}

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
  enum Action {
    case playerView(PlayerView.Action)
    case player(Player.Action)
  }
  
  let store = RecordingStore.shared
  static var stores = [UUID:(Store<PlayerView.State, Action>,(Player, Cancellable)?)
    ]()
  
  static var folderStores = [UUID:Store<FolderList.State, FolderList.Action>]()
  
  func folderStore(for folder:Folder) -> ViewStore<FolderList.State, FolderList.Action> {
    if let store = ContentView.folderStores[folder.id] {
      return store.view(removeDuplicates: ==)
    }
    
    let store = Store(initialValue: .init(with: folder),
                      reducer: FolderList.reducer.logging(),
                      environment: ({ UUID() }, {
                        if let item = folder.item(atUUIDPath: [folder.uuid, $0]) {
                          folder.remove(item)
                        } }))
    ContentView.folderStores[folder.uuid] = store
    return store.view(removeDuplicates: ==)
  }
  
  func playerStore(for recording:Recording) -> ViewStore<PlayerView.State, PlayerView.Action> {
    
    if let store = ContentView.stores[recording.uuid] {
      return store.0.view.scope(value: { $0 }, action: { .playerView($0) })
    }
    
    let env : PlayerViewEnv = ({ self.loadPlayer(for: recording) },
                               { self.togglePlay(for: recording) },
                               { self.player(for: recording)?.time = $0 },
                               { self.unloadPlayer(for: recording) })
    
    let reducer = Reducer<PlayerView.State, Action, Void>.combine(
      playerViewReducer.pullback(value: \PlayerView.State.self,
                                 action: /Action.playerView,
                                 environment: { env }),
      Player.reducer.pullback(value: \.player.self,
                              action: /Action.player,
                              environment: {})
    )
    
    let state = PlayerView.State(name: recording.name, duration: 100, isPlaying: false)
    let store = Store(initialValue: state, reducer: reducer.logging(), environment: ())
    
    ContentView.stores[recording.uuid] = (store, nil)
    return store.view.scope(value: {
      $0
    }, action: { .playerView($0) })
  }
  
  func loadPlayer(for recording:Recording)->TimeInterval {
    guard var storage = ContentView.stores[recording.uuid],
      let url = recording.fileURL,
      let player = Player(url: url)
      else { return 0 }
    
    let store = storage.0
    
    let cancelPlayer = player.$didChange.sink(receiveValue: {
      store.view.send(.player(.update(player.state)))
    })
    
    storage.1 = (player, cancelPlayer)
    ContentView.stores[recording.uuid] = storage
    
    return player.duration
  }
  
  func player(for recording:Recording) -> Player? {
    return ContentView.stores[recording.uuid]?.1?.0
  }
  
  func togglePlay(for recording: Recording) -> Bool {
    player(for: recording)?.togglePlay()
    return player(for: recording)?.isPlaying ?? false
  }
  
  func unloadPlayer(for recording:Recording) {
    guard var store = ContentView.stores[recording.uuid] else { return }
    
    store.1 = nil
    ContentView.stores[recording.uuid] = store
  }
  
  func itemBuilder(root:Folder)-> (FolderList.Item)->AnyView {
    return {
      let item = root.item(atUUIDPath: [root.uuid, $0.id])
      return AnyView(
        item.map({ $0 } ).map { item in
          Group {
            (item as? Folder).map { FolderList(store: self.folderStore(for: $0),
                                               itemBuilder: self.itemBuilder(root:$0)) }
            (item as? Recording).map {  PlayerView(store: self.playerStore(for: $0)) }
          }
        }
      )
      
    }
  }
  
  var body: some View {
    NavigationView {
      FolderList(store: self.folderStore(for: store.rootFolder),
                 itemBuilder: self.itemBuilder(root:store.rootFolder))
    }
  }
}

extension PlayerView.State {
  var player: Player.State {
    get { .init(isPlaying: isPlaying, position:position) }
    set {
      isPlaying = newValue.isPlaying
      position = newValue.position
    }
  }
}

extension FolderList.State {
  init(with folder: Folder) {
    name = folder.name
    uuid = folder.uuid
    items = folder.contents.map {
      FolderList.Item(name: $0.name, id: $0.uuid, type: $0 is Folder ? .folder : .recording)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
