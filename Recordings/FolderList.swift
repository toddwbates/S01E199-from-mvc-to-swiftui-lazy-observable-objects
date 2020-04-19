//
//  FolderList.swift
//  Recordings
//
//  Created by Todd Bates on 4/19/20.
//  Copyright © 2020 objc.io. All rights reserved.
//

import SwiftUI

struct FolderList: View {
  @ObservedObject var folder: Folder
  let itemBuilder : (Item)-> AnyView
  
  // TODO: how do I make @State testable?
  @State var presentsNewRecording = false
  // TODO: how do I make @State testable?
  @State var createFolder = false
  
  func onDelete(_ indices: IndexSet) {
    let items = indices.map { folder.contents[$0] }
    for item in items {
      folder.remove(item)
    }
  }
  
  func onCallback(_ name: String?) {
    guard let n = name else { return }
    folder.add(Folder(name: n, uuid: UUID()))
  }
  
  func onCreateFolder() {
    createFolder = true
  }
  
  func onCreateRecording() {
    presentsNewRecording = true
  }
  
  func presentRecordingView() -> some View {
    RecordingView(folder: self.folder, isPresented: self.$presentsNewRecording)
  }
  
  var body: some View {
    List {
      ForEach(folder.contents) { item in
        NavigationLink(destination: self.itemBuilder(item)) {
          HStack {
            Image(systemName: item.symbolName)
              .frame(width: 20, alignment: .leading)
            Text(item.name)
          }
        }
      }.onDelete(perform: onDelete )
    }
    .textAlert(isPresented: $createFolder, title: "Create Folder", placeholder: "Name", callback: onCallback)
    .navigationBarTitle("Recordings")
    .navigationBarItems(trailing: HStack {
      Button(action: onCreateFolder
        , label: {
          Image(systemName: "folder.badge.plus")
      })
      Button(action: onCreateRecording, label: {
        Image(systemName: "waveform.path.badge.plus")
      })
    })
      .sheet(isPresented: $presentsNewRecording, content: presentRecordingView)
  }
}
