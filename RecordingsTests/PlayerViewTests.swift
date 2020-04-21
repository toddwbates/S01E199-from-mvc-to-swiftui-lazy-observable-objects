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
  var playing  = false
  var position : TimeInterval = 0
  
  func env() -> PlayerEnv {
    return {
      switch $0 {
      case .load:
        return Effect.sync {
          return .effectResult(.duration( 100 ))
        }
      case let .position(newPostion):
        return Effect.sync {
          self.position = newPostion
          if self.playing {
            return .effectResult(.playing(time: self.position))
          }
          else {
            return .effectResult(.stopped(time: self.position))
          }
        }
      case .toggle:
        return Effect.sync {
          self.playing = !self.playing
          if self.playing {
            return .effectResult(.playing(time: self.position))
          }
          else {
            return .effectResult(.stopped(time: self.position))
          }
        }
      case .unload:
        return Effect.fireAndForget { }
      }
    }
  }
  
  func testStartSnapshot()  {
    let store = Store(
      initialValue: PlayerView.State(name: "Peter", duration: 0, position: 50, buttonState: .start),
      reducer: playerViewReducer, environment: env())
    
    let view = PlayerView(store: store.view)
    let vc = UIHostingController(rootView: view)
    
    assertSnapshot(matching: vc, as: .image(on: .iPhone8))
  }
  
  func testPauseSnapshot()  {
    let store = Store(
      initialValue: PlayerView.State(name: "Peter", duration: 0, position: 0, buttonState: .pause),
      reducer: playerViewReducer, environment: env())
    
    let view = PlayerView(store: store.view)
    let vc = UIHostingController(rootView: view)
    
    assertSnapshot(matching: vc, as: .image(on: .iPhone8))
  }
  
  func testResumeSnapshot()  {
    let store = Store(
      initialValue: PlayerView.State(name: "Peter", duration: 0, position: 0, buttonState: .resume),
      reducer: playerViewReducer, environment: env())
    
    let view = PlayerView(store: store.view)
    let vc = UIHostingController(rootView: view)
    
    assertSnapshot(matching: vc, as: .image(on: .iPhone8))
  }
  
  func testReducer() {
    assert(
      initialValue: PlayerView.State(name: "Peter", duration: 0, position: 50, buttonState: .resume),
      reducer: playerViewReducer,
      environment: env(),
      steps:
      Step(.send, .load) { _ in },
      Step(.receive, .effectResult(.duration(100))) { $0.duration = 100 },
      Step(.receive, .effectResult(.stopped(time: 50))) { _ in },
      Step(.send, .setName("New Name")) { $0.name = "New Name" },
      Step(.send, .togglePlay) { _ in },
      Step(.receive, .effectResult(.playing(time: 50))) {
        $0.buttonState = .pause
      },
      Step(.send, .togglePlay) { _ in self.position = 20},
      Step(.receive, .effectResult(.stopped(time: 20))) {
        $0.buttonState = .resume
        $0.position = 20
      },
      Step(.send, .togglePlay) { _ in },
      Step(.receive, .effectResult(.playing(time: 20))) {
        $0.buttonState = .pause
      },
      Step(.send, .togglePlay) { _ in self.position = 0 },
      Step(.receive, .effectResult(.stopped(time: 0))) {
        $0.buttonState = .start
        $0.position = 0
      },
      Step(.send, .setPostion(50)) { _ in  },
      Step(.receive, .effectResult(.stopped(time: 50))) {
        $0.buttonState = .resume
        $0.position = 50
      },
      Step(.send, .unload) { _ in  }
    )
  }
}
