//
//  ViewController.swift
//  StarbucksAnimation
//
//  Created by 黄启明 on 2017/4/18.
//  Copyright © 2017年 黄启明. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    @IBOutlet weak var lid: UIImageView!//杯盖
    @IBOutlet weak var cup: UIImageView!//杯子
    @IBOutlet weak var restartButton: UIButton!//动画重新开始按钮
    
    let starNum = 10//星星数量
    
    var animator: UIDynamicAnimator?
    
    var gravity = UIGravityBehavior()
    
    var dynamicItems = [UIView]()
    
    var timer: Timer?
    
    lazy var motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func stopAnimation() {
        timer?.invalidate()
        animator?.removeAllBehaviors()
        for item in dynamicItems {
            item.removeFromSuperview()
        }
        dynamicItems.removeAll()
        motionManager.stopDeviceMotionUpdates()
    }

    @IBAction func restart(_ sender: Any) {
        stopAnimation()
        //杯盖旋转
        lid.layer.anchorPoint = CGPoint(x: 0, y: 1)
//        lid.layer.position = CGPoint(x: lid.frame.origin.x - lid.frame.size.width / 2 , y: lid.frame.origin.y + 66)
        lid.layer.position = CGPoint(x: view.center.x - lid.frame.size.width / 2, y: view.center.y + lid.frame.size.height / 2)
        UIView.animate(withDuration: 0.5) {
            self.lid.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/4))
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true, block: { (timer) in
            self.createAnimation()
        })
        
    }

    func createAnimation() {
        restartButton.isHidden = true
        guard dynamicItems.count < starNum else {
            restartButton.isHidden = false
            timer?.invalidate()
            
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: { (motion, err) in
                let rotation = atan2((motion?.gravity.x)!, (motion?.gravity.y)!) - Double.pi / 2
                guard abs(rotation) > 0.7 else {
                    return
                }
                self.gravity.setAngle(CGFloat(rotation), magnitude: 0.1)
            })
            
            
            //盖子合上动画
            UIView.animate(withDuration: 0.5, animations: { 
                self.lid.transform = CGAffineTransform.identity
            }, completion: { (finished) in
                self.lid.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                self.lid.layer.position = self.view.center
            })
            return
        }
        
        dynamicItems.append(createStar())
        animator = UIDynamicAnimator(referenceView: cup)
        gravity = UIGravityBehavior(items: dynamicItems)
        gravity.magnitude = 0.8
        
        let collisionTop = UICollisionBehavior(items: dynamicItems)
        let collisionLeft = UICollisionBehavior(items: dynamicItems)
        let collisionBottom = UICollisionBehavior(items: dynamicItems)
        let collisionRight = UICollisionBehavior(items: dynamicItems)
        
        let pLeftTop = CGPoint(x: 6, y: 0)
        let pRightTop = CGPoint(x: 116, y: 0)
        let pLeftBottom = CGPoint(x: 22, y: 163)
        let pRightBottom = CGPoint(x: 100, y: 163)
        
        collisionTop.addBoundary(withIdentifier: "boundaryTop" as NSCopying, from: pLeftTop, to: pRightTop)
        collisionLeft.addBoundary(withIdentifier: "boundaryLeft" as NSCopying, from: pLeftTop, to: pLeftBottom)
        collisionRight.addBoundary(withIdentifier: "boundaryRight" as NSCopying, from: pRightBottom, to: pRightTop)
        collisionBottom.addBoundary(withIdentifier: "boundaryBottom" as NSCopying, from: pLeftBottom, to: pRightBottom)
    
        let behavior = UIDynamicItemBehavior(items: dynamicItems)
        behavior.elasticity = 0.4
        
        animator?.addBehavior(gravity)
        animator?.addBehavior(collisionTop)
        animator?.addBehavior(collisionLeft)
        animator?.addBehavior(collisionRight)
        animator?.addBehavior(collisionBottom)
        animator?.addBehavior(behavior)
        
    }
    
    //生成星星
    func createStar() -> UIView {
        let star = Star(image: UIImage(named: "star"))
        let x = CGFloat(arc4random_uniform(75) + 7)
        star.frame = CGRect(x: x, y: 0, width: 24, height: 24)
        cup.addSubview(star)
        return star
    }
    
}

class Star: UIImageView {
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }
}
