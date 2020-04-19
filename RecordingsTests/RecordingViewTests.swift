//
//  RecordingViewTests.swift
//  RecordingsTests
//
//  Created by Todd Bates on 4/19/20.
//  Copyright © 2020 objc.io. All rights reserved.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import UnitTestHostApp

class RecordingViewTests: XCTestCase {
  var folder = Folder(name: "Root", uuid: UUID())
  
  func testSnapshot()  {
    let isPresented = Binding<Bool>(get: { true }, set: { _ in })
    let vc = UIHostingController(
      rootView: RecordingView(folder: folder, isPresented: isPresented))
    
    assertSnapshot(matching: vc, as: .image)
  }
  
  func testSave()  {
    var isPresented = true
    let view = RecordingView(folder: folder, isPresented: Binding<Bool>(get: { isPresented }, set: { isPresented = $0 }))
    
    view.save(name: "New Recording")
    XCTAssertEqual(folder.contents.first?.name, "New Recording")
    XCTAssertFalse(isPresented)
  }
  
  func testSaveNil()  {
    var isPresented = true
    let view = RecordingView(folder: folder, isPresented: Binding<Bool>(get: { isPresented }, set: { isPresented = $0 }))
    
    view.save(name: nil)
    XCTAssertEqual(folder.contents.count, 0)
    XCTAssertFalse(isPresented)
  }
  
  // dont know how to test State
  //  func testOnStop()  {
  //    let isPresented = Binding<Bool>(get: { true }, set: { _ in })
  //    let view = RecordingView(folder: folder, isPresented: isPresented)
  //
  //    view.onStop()
  //    XCTAssertTrue(view.isSaving)
  //  }
  
}
