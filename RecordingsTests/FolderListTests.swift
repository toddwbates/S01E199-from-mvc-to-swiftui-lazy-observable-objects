//
//  FolderListTests.swift
//  FolderListTests
//
//  Created by Todd Bates on 4/19/20.
//  Copyright © 2020 objc.io. All rights reserved.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import UnitTestHostApp

func testUUID(_ index: Int)->UUID {
  return UUID(uuidString: "0F58D654-8600-4630-BCFF-EECD30F602C\(index)")!
}

class FolderListTests: XCTestCase {
  let folder = FolderList.State(name: "Root",
                                uuid: testUUID(0),
                                items: [
                                  .init(name: "first",
                                        id: testUUID(1),
                                        type: .folder),
                                  .init(name: "second",
                                        id: testUUID(2),
                                        type: .recording),
                                  .init(name: "third",
                                        id: testUUID(3),
                                        type: .recording),
                                  .init(name: "fourth",
                                        id: testUUID(4),
                                        type: .folder)
  ])
  
  let env : FolderList.Env = ({ return testUUID(4) }, { _ in })
  
  var store  : Store<FolderList.State, FolderList.Action>{ Store(
    initialValue: folder,
    reducer: FolderList.reducer, environment: env)
  }
  
  let itemBuilder : (FolderList.Item)-> AnyView = { _ in AnyView( Text("next") )}
  func testSnapshot() throws {
    let vc = UIHostingController(rootView: NavigationView(content: { FolderList(store: store.view, itemBuilder: itemBuilder) }))
    
    assertSnapshot(matching: vc, as: .image)
  }
  
  func testOnDelete() throws {
    assert(
      initialValue: folder,
      reducer: FolderList.reducer,
      environment: env,
      steps:
      Step(.send, .onDelete([1,3]), { $0.items = [
        .init(name: "first",
              id: testUUID(1),
              type: .folder),
        .init(name: "third",
              id: testUUID(3),
              type: .recording)
        ] })
    )
  }
  
  func testAddFolder() {
    let newFolder = FolderList.Item(name: "New Folder", id: env.0(),type: .folder)
    
    assert(
      initialValue: folder,
      reducer: FolderList.reducer,
      environment: env,
      steps:
      Step(.send, .addFolder("New Folder"), { $0.items.append(newFolder) }),
      Step(.send, .addFolder(nil),{ _ in })
    )
    
  }
  
  func testOnCreateFolder() {
    assert(
      initialValue: folder,
      reducer: FolderList.reducer,
      environment: env,
      steps:
      Step(.send, .onCreateFolder(true), { $0.createFolder = true }),
      Step(.send, .onCreateFolder(false), { $0.createFolder = false })
    )
    
  }
  
  func testOnCreateRecording() {
    assert(
      initialValue: folder,
      reducer: FolderList.reducer,
      environment: env,
      steps:
      Step(.send, .onCreateRecording(true), { $0.createRecording = true }),
      Step(.send, .onCreateRecording(false), { $0.createRecording = false })
    )
    
  }
  
  func testPresentRecordingView() {
    let list = FolderList(store: store.view, itemBuilder: itemBuilder)
    
    let vc = UIHostingController(rootView: NavigationView(content: { list.presentRecordingView() }))
    
    assertSnapshot(matching: vc, as: .image)
  }
  
}
