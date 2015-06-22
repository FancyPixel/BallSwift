//
//  ViewController.swift
//  BallSwift
//
//  Created by Andrea Mazzini on 18/06/15.
//  Copyright © 2015 Fancy Pixel. All rights reserved.
//

import UIKit

/*
A UIView with a round body
*/
class Ellipse: UIView {
  override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
    return .Ellipse
  }
}

/*
A UIImageView with a round body
*/
class Ball: UIImageView {
  override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
    return .Ellipse
  }
}

class ViewController: UIViewController {
  var animator: UIDynamicAnimator?
  var board: UIView!
  var leftHoop: UIView!
  var rightHoop: UIView!
  var hoop: UIView!
  let hoopPosition = CGPoint(x: 240, y: 300)

  let floor: UIView = {
    let floor = UIView()
    floor.backgroundColor = .clearColor()
    return floor
    }()

  let ball: Ball = {
    let ball = Ball(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
    ball.image = UIImage(named: "ball")
    return ball
    }()

  override func viewDidLoad() {
    super.viewDidLoad()

    animator = UIDynamicAnimator(referenceView: self.view)

    floor.frame = CGRect(x: 0, y: view.frame.size.height - 60, width: view.frame.size.width, height: 60)
    ball.center = CGPoint(x: 40, y: view.frame.size.height - 100)

    buildViews()
    setupBehaviors()

    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "shoot"))
  }

  /*
  Build the hoop, setup the world appearance
  */
  func buildViews() {
    board = UIView(frame: CGRect(x: hoopPosition.x, y: hoopPosition.y, width: 100, height: 100))
    board.backgroundColor = .whiteColor()
    board.layer.borderColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1).CGColor
    board.layer.borderWidth = 2

    board.addSubview({
      let v = UIView(frame: CGRect(x: 30, y: 43, width: 40, height: 40))
      v.backgroundColor = .clearColor()
      v.layer.borderColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1).CGColor
      v.layer.borderWidth = 5
      return v
      }())

    leftHoop = Ellipse(frame: CGRect(x: hoopPosition.x + 20, y: hoopPosition.y + 80, width: 10, height: 6))
    leftHoop.backgroundColor = .clearColor()
    leftHoop.layer.cornerRadius = 3

    rightHoop = Ellipse(frame: CGRect(x: hoopPosition.x + 70, y: hoopPosition.y + 80, width: 10, height: 6))
    rightHoop.backgroundColor = .clearColor()
    rightHoop.layer.cornerRadius = 3

    hoop = UIView(frame: CGRect(x: hoopPosition.x + 20, y: hoopPosition.y + 80, width: 60, height: 6))
    hoop.backgroundColor = UIColor(red: 177.0/255.0, green: 25.0/255.0, blue: 25.0/255.0, alpha: 1)
    hoop.layer.cornerRadius = 3

    [board, leftHoop, rightHoop, floor, ball, hoop].map({self.view.addSubview($0)})
  }

  /*
  Setup the behaviors for the world's objects
  */
  func setupBehaviors() {
    animator?.removeAllBehaviors()

    let bolts = [
      CGPoint(x: hoopPosition.x + 25, y: hoopPosition.y + 85),
      CGPoint(x: hoopPosition.x + 75, y: hoopPosition.y + 85),
      CGPoint(x: hoopPosition.x + 25, y: hoopPosition.y + 85),
      CGPoint(x: hoopPosition.x + 75, y: hoopPosition.y + 85)]

    // Build the board
    zip([hoop, hoop, leftHoop, rightHoop], bolts).map({
      (item, offset) in
      animator?.addBehavior(UIAttachmentBehavior.pinAttachmentWithItem(item, attachedToItem: board, attachmentAnchor: offset))
    })

    // Hang the hoop
    animator?.addBehavior({
      let attachment = UIAttachmentBehavior(item: board, attachedToAnchor: CGPoint(x: hoopPosition.x, y: hoopPosition.y))
      attachment.length = 2
      attachment.damping = 5
      return attachment
      }())

    // Set the density of the hoop, and fix its angle
    animator?.addBehavior({
      let behavior = UIDynamicItemBehavior(items: [leftHoop, rightHoop])
      behavior.density = 10
      behavior.allowsRotation = false
      return behavior
      }())

    // Block the board rotation
    animator?.addBehavior({
      let behavior = UIDynamicItemBehavior(items: [board])
      behavior.allowsRotation = false
      return behavior
      }())

    // Set the elasticity and density of the ball
    animator?.addBehavior({
      let behavior = UIDynamicItemBehavior(items: [ball])
      behavior.elasticity = 1
      behavior.density = 3
      behavior.action = {
        if !CGRectIntersectsRect(self.ball.frame, self.view.frame) {
          self.setupBehaviors()
          self.ball.center = CGPoint(x: 40, y: self.view.frame.size.height - 100)
        }
      }
      return behavior
      }())

    // Anchor the floor
    animator?.addBehavior({
      let behavior = UIDynamicItemBehavior(items: [floor])
      behavior.anchored = true
      return behavior
      }())

    animator?.addBehavior(UICollisionBehavior(items: [leftHoop, rightHoop, floor, ball]))

    // Gravity is working against me
    // This throws a warning when the ball resets, even if all the behaviors were removed from the animator
    animator?.addBehavior(UIGravityBehavior(items: [ball]))
  }

  /*
  Applies the force to the ball
  */
  func shoot() {
    animator?.addBehavior(pushForPosition(CGPointZero))
  }

  /*
  Build the force to apply to the ball
  */
  func pushForPosition(position: CGPoint) -> UIPushBehavior {
    // Apply an instantaneous push to the ball
    let push = UIPushBehavior(items: [ball], mode: .Instantaneous)

    // This game is rigged, we can add user controls by using the `position` param
    push.angle = -1.35
    push.magnitude = 1.56
    return push
  }
}
