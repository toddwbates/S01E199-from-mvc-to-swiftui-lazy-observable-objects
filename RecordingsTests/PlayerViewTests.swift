//
//  PlayerViewTests.swift
//  RecordingsTests
//
//  Created by Todd Bates on 4/19/20.
//  Copyright © 2020 objc.io. All rights reserved.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import UnitTestHostApp

class PlayerViewTests: XCTestCase {
  
  func testStartSnapshot()  {
    let store = Store(
      initialValue: PlayerView.State(name: "Peter", duration: 100, position: 50, playState: .start),
      reducer: playerViewReducer, environment: ())

    let view = PlayerView(store: store.view)
    let vc = UIHostingController(rootView: view)

    assertSnapshot(matching: vc, as: .image)
  }
  
  func testPauseSnapshot()  {
    let store = Store(
      initialValue: PlayerView.State(name: "Peter", duration: 100, position: 0, playState: .pause),
      reducer: playerViewReducer, environment: ())

    let view = PlayerView(store: store.view)
    let vc = UIHostingController(rootView: view)

    assertSnapshot(matching: vc, as: .image)
  }
  
  func testResumeSnapshot()  {
    let store = Store(
      initialValue: PlayerView.State(name: "Peter", duration: 100, position: 0, playState: .resume),
      reducer: playerViewReducer, environment: ())

    let view = PlayerView(store: store.view)
    let vc = UIHostingController(rootView: view)

    assertSnapshot(matching: vc, as: .image)
  }
  
}
