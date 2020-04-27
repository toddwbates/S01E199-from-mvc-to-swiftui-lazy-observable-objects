//
//  FolderList.swift
//  Recordings
//
//  Created by Todd Bates on 4/19/20.
//  Copyright © 2020 objc.io. All rights reserved.
//

import SwiftUI
import CasePaths

struct FolderList: View {
  
  struct Item : Equatable {
    enum TypeMarker {
      case folder
      case recording
      
      var symbolName: String {
        switch self {
        case .folder:
          return "folder"
        case .recording:
          return "waveform"
        }
      }
      
    }
    
    var name: String
    let id: UUID
    let type : TypeMarker
  }
  
  struct State : Equatable {
    var name : String
    var uuid : UUID
    var items : [Item]
    var createRecording = false
    var createFolder = false
  }
  
  enum Action : Equatable  {
    case addFolder(String?)
    case onDelete(IndexSet)
    case onCreateFolder(Bool)
    case onCreateRecording(Bool)
  }
  
  typealias Env = (uuid: ()->UUID, deleteRecording: (UUID)->())
  static let reducer = Reducer<State, Action, Env> { state, action, env in
    switch action {
      
    case .addFolder(let name):
      if let name = name {
        state.items.append(.init(name: name, id: env.uuid() , type: .folder))
      }
    case .onDelete(let indices):
      indices.forEach() { env.deleteRecording(state.items[$0].id) }
      state.items.remove(atOffsets: indices)
    case .onCreateFolder(let value):
      state.createFolder = value
    case .onCreateRecording(let value):
      state.createRecording = value
    }
    
    return []
  }
  
  @ObservedObject var store: ViewStore<State, Action>
  var value : State { store.value }
  
  let itemBuilder : (Item)-> AnyView

  func presentRecordingView() -> some View {
    RecordingView(with: value.uuid, isPresented:  store.bind(\State.createRecording , /Action.onCreateRecording))
  }
  
  var body: some View {
    List {
      ForEach(value.items, id: \Item.id) { item in
        NavigationLink(destination: self.itemBuilder(item)) {
          HStack {
            Image(systemName: item.type.symbolName)
              .frame(width: 20, alignment: .leading)
            Text(item.name)
          }
        }
      }.onDelete(perform: store.curry(/Action.onDelete) )
    }
    .textAlert(isPresented: store.bind(\State.createFolder , /Action.onCreateFolder), title: "Create Folder", placeholder: "Name", callback: store.curry(/Action.addFolder))
    .navigationBarTitle("Recordings")
    .navigationBarItems(trailing: HStack {
      Button(action: store.curry(.onCreateFolder(true))
        , label: {
          Image(systemName: "folder.badge.plus")
      })
      Button(action: store.curry(.onCreateRecording(true)), label: {
        Image(systemName: "waveform.path.badge.plus")
      })
    })
      .sheet(isPresented: store.bind(\State.createRecording , /Action.onCreateRecording), content: presentRecordingView)
  }
}
