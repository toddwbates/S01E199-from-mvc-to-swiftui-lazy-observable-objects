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
import Combine
@testable import UnitTestHostApp

class PlayerViewTests: XCTestCase {
  
  var state = PlayerView.State(name: "Peter", duration: 0)
  
  func env() -> PlayerViewEnv {
    var isPlaying = false

    return (load: { return 100 },
            togglePlay: {
              isPlaying = !isPlaying
              return isPlaying },
            position: { _ in },
            unload: { })
  }
  
  func testPlaySnapshot()  {
    let store = Store(
      initialValue: state,
      reducer: playerViewReducer, environment: env())
    
    let view = PlayerView(store: store.view)
    let vc = UIHostingController(rootView: view)
    
    assertSnapshot(matching: vc, as: .image(on: .iPhone8))
  }
  
  func testPauseSnapshot()  {
    let store = Store(
      initialValue: state,
      reducer: playerViewReducer, environment: env())
    let view = PlayerView(store: store.view)
    store.view.send(.togglePlay)
    
    let vc = UIHostingController(rootView: view)
    
    assertSnapshot(matching: vc, as: .image(on: .iPhone8))
  }
  
  func testResumeSnapshot()  {
    let store = Store(
      initialValue: state,
      reducer: playerViewReducer, environment: env())
    let view = PlayerView(store: store.view)
    store.view.send(.setPostion(50))
    
    let vc = UIHostingController(rootView: view)
    
    assertSnapshot(matching: vc, as: .image(on: .iPhone8))
  }
  
  func testReducer() {
    assert(
      initialValue: PlayerView.State(name: "Peter", duration: 0),
      reducer: playerViewReducer,
      environment: env(),
      steps:
      Step(.send, .load) { $0.duration = 100 },
      Step(.send, .setName("New Name")) { $0.name = "New Name" },
      Step(.send, .togglePlay) { $0.isPlaying = true },
      Step(.send, .togglePlay) { $0.isPlaying = false },
      Step(.send, .setPostion(50)) { $0.position = 50  },
      Step(.send, .unload) { _ in  }
    )
  }
}
