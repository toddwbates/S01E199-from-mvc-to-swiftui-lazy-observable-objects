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
  var state = PlayerView.State(name: "Peter", duration: 0)
  
  func env() -> PlayerEnv {
    return {
      switch $0 {
      case .load:
        return Effect.sync {
          return .effectResult(.duration( 100 ))
        }
      case let .position(newPostion):
        return Effect.sync {
          self.state.position = newPostion
          return .effectResult(.position(newPostion))
        }
      case .toggle:
        return Effect.sync {
          self.state.isPlaying = !self.state.isPlaying
          return .effectResult(.isPlaying(self.state.isPlaying))
        }
      case .unload:
        return Effect.fireAndForget { }
      }
    }
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
      Step(.send, .load) { _ in },
      Step(.receive, .effectResult(.duration(100))) { $0.duration = 100 },
      Step(.receive, .effectResult(.position(0))) { _ in  },
      Step(.send, .setName("New Name")) { $0.name = "New Name" },
      Step(.send, .togglePlay) { _ in },
      Step(.receive, .effectResult(.isPlaying(true))) {
        $0.isPlaying = true
      },
      Step(.send, .togglePlay) { _ in self.state.position = 20},
      Step(.receive, .effectResult(.isPlaying(false))) {
        $0.isPlaying = false
      },
      Step(.send, .setPostion(50)) { _ in  },
      Step(.receive, .effectResult(.position(50))) {
        $0.position = 50
      },
      Step(.send, .unload) { _ in  }
    )
  }
}
