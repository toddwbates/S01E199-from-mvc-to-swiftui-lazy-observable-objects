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
  var playing  = true
  var position : TimeInterval = 0
  
  func env() -> PlayerEnv {
    return {
      switch $0 {
      case .load:
        return Effect.sync {
          return .effectResult(.length( 100 ))
        }
      case let .position(newPostion):
        return Effect.sync {
          self.position = newPostion
          return .effectResult(.playing(position: self.position))
        }
      case .toggle:
        return Effect.sync {
          return .effectResult(.stopped(position: self.position))
        }
      }
    }
  }
  
  func testStartSnapshot()  {
    let store = Store(
      initialValue: PlayerView.State(name: "Peter", duration: 100, position: 50, buttonState: .start),
      reducer: playerViewReducer, environment: env())
    
    let view = PlayerView(store: store.view)
    let vc = UIHostingController(rootView: view)
    
    assertSnapshot(matching: vc, as: .image)
  }
  
  func testPauseSnapshot()  {
    let store = Store(
      initialValue: PlayerView.State(name: "Peter", duration: 100, position: 0, buttonState: .pause),
      reducer: playerViewReducer, environment: env())
    
    let view = PlayerView(store: store.view)
    let vc = UIHostingController(rootView: view)
    
    assertSnapshot(matching: vc, as: .image)
  }
  
  func testResumeSnapshot()  {
    let store = Store(
      initialValue: PlayerView.State(name: "Peter", duration: 100, position: 0, buttonState: .resume),
      reducer: playerViewReducer, environment: env())
    
    let view = PlayerView(store: store.view)
    let vc = UIHostingController(rootView: view)
    
    assertSnapshot(matching: vc, as: .image)
  }
  
}
