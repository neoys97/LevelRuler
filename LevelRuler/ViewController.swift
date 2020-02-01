//
//  ViewController.swift
//  LevelRuler
//
//  Created by Neo Yi Siang on 29/1/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    var bigCircle: CircleView!
    var smallCircle: CircleView!
    var degreeLabel: UILabel!
    var leftHorizonView: UIView!
    var rightHorizonView: UIView!
    var topHorizonView: UIView!
    var bottomHorizonView: UIView!
    
    var circleColor: UIColor = UIColor(red: 0/255, green: 128/255, blue: 128/255, alpha: 0.5)
    var completeColor: UIColor = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1)
    var defaultBgColor: UIColor = UIColor.black
    
    let motion = CMMotionManager()
    let feedbackGenerator = UINotificationFeedbackGenerator()
    
    var cartesianConverter = CartesianConverter(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    let windowSize = 30
    var acc_x_window: [Double] = []
    var acc_y_window: [Double] = []
    var acc_z_window: [Double] = []
    var middle_discrepency: Double = 10.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print ("Size: \(UIScreen.main.bounds.width) : \(UIScreen.main.bounds.height)")
        bigCircle = CircleView(size: 250, color: circleColor, completeColor: UIColor.white)
        smallCircle = CircleView(size: 230, color: circleColor, completeColor: completeColor)
        degreeLabel = {
            let label = UILabel()
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 100, weight: .bold)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "5º"
            return label
        }()
        
        leftHorizonView = createHorizonView()
        rightHorizonView = createHorizonView()
        topHorizonView = createHorizonView()
        bottomHorizonView = createHorizonView()
        
        self.view.backgroundColor = defaultBgColor
        self.view.addSubview(bigCircle)
        self.view.addSubview(smallCircle)
        self.view.addSubview(degreeLabel)
        self.view.addSubview(leftHorizonView)
        self.view.addSubview(rightHorizonView)
        self.view.addSubview(topHorizonView)
        self.view.addSubview(bottomHorizonView)

        degreeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        degreeLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        leftHorizonView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        leftHorizonView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        leftHorizonView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        leftHorizonView.heightAnchor.constraint(equalToConstant: 10).isActive = true

        rightHorizonView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        rightHorizonView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        rightHorizonView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        rightHorizonView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        topHorizonView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        topHorizonView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        topHorizonView.widthAnchor.constraint(equalToConstant: 10).isActive = true
        topHorizonView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        bottomHorizonView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        bottomHorizonView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        bottomHorizonView.widthAnchor.constraint(equalToConstant: 10).isActive = true
        bottomHorizonView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        leftHorizonView.isHidden = true
        rightHorizonView.isHidden = true
        topHorizonView.isHidden = true
        bottomHorizonView.isHidden = true
        
        startLevelMeasure()
    }
    
    func createHorizonView() -> UIView {
        let bar = UIView()
        bar.backgroundColor = UIColor.white
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }
    
    func startLevelMeasure() {
        if motion.isAccelerometerAvailable {
            motion.accelerometerUpdateInterval = 1 / 60
            motion.startAccelerometerUpdates(to: .main) { (data, error) in
                guard let data = data else { return }
                self.acc_x_window.append(data.acceleration.x)
                self.acc_y_window.append(data.acceleration.y)
                self.acc_z_window.append(data.acceleration.z)
                if self.acc_x_window.count > self.windowSize {
                    self.acc_x_window.remove(at: 0)
                }
                if self.acc_y_window.count > self.windowSize {
                    self.acc_y_window.remove(at: 0)
                }
                if self.acc_z_window.count > self.windowSize {
                    self.acc_z_window.remove(at: 0)
                }
                self.moveCircle()
                self.handleLabel()
            }
        }
    }
    
    func moveCircle () {
        let acc_x = acc_x_window.reduce(0, +) / Double(acc_x_window.count)
        let acc_y = acc_y_window.reduce(0, +) / Double(acc_y_window.count)
        let x = ((acc_x * 2).rounded(toPlaces: 5) * Double(cartesianConverter.halfHeight)).rounded(toPlaces: 0)
        let y = ((acc_y * 2).rounded(toPlaces: 5) * Double(cartesianConverter.halfHeight)).rounded(toPlaces: 0)
        
        if abs(x - 0) < middle_discrepency && abs(y - 0) < middle_discrepency {
            bigCircle.move(to: cartesianConverter.convertMiddleToTopLeft(CGPoint(x: 0, y: 0)), inMiddle: true)
            smallCircle.move(to: cartesianConverter.convertMiddleToTopLeft(CGPoint(x: 0, y: 0)), inMiddle: true)
            if self.view.backgroundColor != completeColor {
                feedbackGenerator.notificationOccurred(.success)
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                    self.view.backgroundColor = self.completeColor
                }, completion: nil)
            }
        }
        else {
            bigCircle.move(to: cartesianConverter.convertMiddleToTopLeft(CGPoint(x: x, y: y)))
            smallCircle.move(to: cartesianConverter.convertMiddleToTopLeft(CGPoint(x: -x, y: -y)))
            if self.view.backgroundColor != defaultBgColor {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                    self.view.backgroundColor = self.defaultBgColor
                }, completion: nil)
            }
        }
    }
    
    func handleLabel () {
        let acc_x = (acc_x_window.reduce(0, +) / Double(acc_x_window.count))
        let acc_y = (acc_y_window.reduce(0, +) / Double(acc_y_window.count))
        
        let degree = 90 * abs(acc_x) + 90 * abs(acc_y)
        
        var rotationAngle = atan(acc_x / (abs(acc_y) < 0.000001 ? 0.000001 : acc_y))
        rotationAngle = acc_y > 0 ? rotationAngle - Double.pi : rotationAngle
        
        let discrepency = 1 * middle_discrepency / Double(cartesianConverter.height)
        UIView.animate(withDuration: 0.1) {
            self.degreeLabel.text = String(Int(degree)) + "º"
            self.degreeLabel.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
            if abs(acc_x - 0) < discrepency {
                self.leftHorizonView.isHidden = false
                self.rightHorizonView.isHidden = false
            }
            else {
                self.leftHorizonView.isHidden = true
                self.rightHorizonView.isHidden = true
            }
            if abs(acc_y - 0) < discrepency {
                self.topHorizonView.isHidden = false
                self.bottomHorizonView.isHidden = false
            }
            else {
                self.topHorizonView.isHidden = true
                self.bottomHorizonView.isHidden = true
            }
        }
        
    }

}

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
