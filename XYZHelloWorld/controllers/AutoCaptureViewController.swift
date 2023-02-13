//
//  AutoCaptureViewController.swift
//
//  Created by Admin on 25/01/23.
//

import UIKit
import DotFaceLite

class AutoCaptureViewController: UIViewController, FaceServiceListener, FaceAutoCaptureViewControllerDelegate {

    private let service = SDKService()
    
    var reqId: String?
    
    var delegate: AutoCaptureViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        service.delegate = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let reqId = reqId {
            service.setup(reqId: reqId, timeout: 20)
        }
        //
        
    }
    
    /*
    func viewRound(){
        // Let's say that you have an outlet to the image view called imageView
        // Create the white view
        let whiteView = UIView(frame: imageView.bounds)
        let maskLayer = CAShapeLayer() //create the mask layer

        // Set the radius to 1/3 of the screen width
        let radius : CGFloat = imageView.bounds.width/3

        // Create a path with the rectangle in it.
        let path = UIBezierPath(rect: imageView.bounds)
        // Put a circle path in the middle
        path.addArcWithCenter(imageView.center, radius: radius, startAngle: 0.0, endAngle: CGFloat(2*M_PI), clockwise: true)

        // Give the mask layer the path you just draw
        maskLayer.path = path.CGPath
        // Fill rule set to exclude intersected paths
        maskLayer.fillRule = kCAFillRuleEvenOdd

        // By now the mask is a rectangle with a circle cut out of it. Set the mask to the view and clip.
        whiteView.layer.mask = maskLayer
        whiteView.clipsToBounds = true

        whiteView.alpha = 0.8
        whiteView.backgroundColor = UIColor.whiteColor()

        //If you are in a VC add to the VC's view (over the image)
        view.addSubview(whiteView) 
    }
     */
    
    // ui component
    private func openCameraController() {
        let viewController = FaceAutoCaptureViewController.create(configuration: .init(), style: .init(
            instructionTextColor: UIColor.white,
            instructionCandidateSelectionTextColor: UIColor.white,
            instructionBackgroundColor: UIColor(hexString: "#000000", alpha: CGFloat(0.30)),
            instructionCandidateSelectionBackgroundColor: UIColor(hexString: "#000000", alpha: CGFloat(0.30)),
            placeholderColor: UIColor.white, // corner
            placeholderCandidateSelectionColor: UIColor(hexString: "#47CC69"), // corner when selection
            overlayColor: UIColor(hexString: "#1463FD", alpha: CGFloat(0.25))
        ))
        viewController.delegate = self
        viewController.view.tag = 100
        // Do any additional setup after loading the view.
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.didMove(toParent: self)
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        viewController.start()
    }
    
    func faceAutoCaptureViewController(_ viewController: DotFaceLite.FaceAutoCaptureViewController, captured result: DotFaceLite.FaceAutoCaptureResult) {
        if let viewWithTag = self.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
            setupResult(CGImageFactory.create(bgraRawImage: result.bgraRawImage))
        } else {
            print("No!")
        }
    }
    
    // result
    private func setupImage(_ image: CGImage) -> UIImageView {
        let imageFace = UIImage(cgImage: image).flipHorizontally()
        let imageView = UIImageView(image: imageFace)
        imageView.frame = self.view.bounds
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    /**
     add image view and layout result
     */
    private func setupResult(_ image: CGImage){
        let guide = self.view.safeAreaLayoutGuide
        //
        let imageView = setupImage(image)
        self.view.addSubview(imageView)
        // progress bar
        if #available(iOS 13.0, *) {
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(spinner)
            spinner.startAnimating()
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 250).isActive = true

        } else {
            // Fallback on earlier versions
        }

        // Do any additional setup after loading the view.
        
        let sampleMask = UIView()
        sampleMask.frame = self.view.bounds
        sampleMask.backgroundColor = UIColor(hexString: "#1463FD", alpha: CGFloat(0.25)) // UIColor.black.withAlphaComponent(0.6)
        sampleMask.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(sampleMask)
        
        // create circle
        let maskLayer = CALayer()
        maskLayer.frame = self.view.bounds
        let circleLayer = CAShapeLayer()
        //assume the circle's radius is 150
        circleLayer.frame = CGRect(x:0 , y:0,width: sampleMask.bounds.size.width, height: sampleMask.frame.size.height)
        let finalPath = UIBezierPath(roundedRect: CGRect(x:0 , y:0, width: sampleMask.bounds.size.width, height: sampleMask.frame.size.height), cornerRadius: 0)
        let circlePath = UIBezierPath(ovalIn: CGRect(x:sampleMask.center.x - 150, y:sampleMask.center.y - 220, width: 300, height: 300))
        finalPath.append(circlePath.reversing())
        circleLayer.path = finalPath.cgPath
        circleLayer.borderColor = UIColor.white.withAlphaComponent(1).cgColor
        circleLayer.borderWidth = 1
        maskLayer.addSublayer(circleLayer)
        sampleMask.layer.mask = maskLayer
        // add constraint
        sampleMask.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        sampleMask.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        sampleMask.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        sampleMask.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        // add constraint
        imageView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
//        imageView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
//        imageView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 15).isActive = true
        imageView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -15).isActive = true
        // verify to liveness api
        if let image = imageView.image {
            service.verify(image: image)
        }
    }
    
    func onAuthSuccess(_ reqId: String) {
        openCameraController()
    }
    
    func onAuthFailed(_ code: Int, _ message: String) {
        delegate?.onCaptureError(code, message)
    }
    
    func onVerifySuccess(_ verify: BaseResponse<VerifyResponse>) {
        delegate?.onCaptureFinish(result: verify.result?.result)
    }
    
    func onVerifyFailed(_ code: Int, _ message: String) {
        delegate?.onCaptureError(code, message)
    }
    
}

protocol AutoCaptureViewControllerDelegate {
    
    func onCaptureFinish(result: Bool?)
    
    func onCaptureError(_ code:Int, _ message: String)
}
