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

class FolderListTests: XCTestCase {
  var folder: Folder  = {
    let folder = Folder(name: "Root", uuid: UUID())
    folder.add(Folder(name: "first", uuid: UUID()))
    folder.add(Recording(name: "second", uuid: UUID()))
    return folder
  }()
  
  let itemBuilder : (Item)-> AnyView = { _ in AnyView( Text("next") )}
  func testSnapshot() throws {
    let vc = UIHostingController(rootView: NavigationView(content: { FolderList(folder: folder, itemBuilder: itemBuilder) }))
    
    assertSnapshot(matching: vc, as: .image)
  }
  
  func testOnDelete() throws {
    let list = FolderList(folder: folder, itemBuilder: itemBuilder)
    
    list.onDelete(IndexSet(arrayLiteral: 0))
    XCTAssertEqual(folder.contents.count, 1)
  }
  
  func testOnCallback() {
    let list = FolderList(folder: folder, itemBuilder: itemBuilder)
    
    list.onCallback("Peter")
    XCTAssertEqual(folder.contents.count, 3)
  }
  
  func testOnCallbackWithNil() {
    let list = FolderList(folder: folder, itemBuilder: itemBuilder)
    
    list.onCallback(nil)
    XCTAssertEqual(folder.contents.count, 2)
  }

//  // TODO: how do I make this testable
//  func testOnCreateFolder() {
//    let list = FolderList(folder: folder)
//
//    list.onCreateFolder()
//    XCTAssertTrue(list.createFolder)
//  }
//
//  // TODO: how do I make this testable
//  func testOnPresentsNewRecording() {
//    let list = FolderList(folder: folder)
//
//    list.onCreateRecording()
//    XCTAssertTrue(list.presentsNewRecording)
//  }
  
  func testPresentRecordingView() {
    let list = FolderList(folder: folder, itemBuilder: itemBuilder)
    
    let vc = UIHostingController(rootView: NavigationView(content: { list.presentRecordingView() }))
    
    assertSnapshot(matching: vc, as: .image)
  }
  
}
