//
//  CameraViewOrigin.swift
//  CustomVideoRecorder
//
//  Created by kimhongpil on 2023/05/31.
//

import SwiftUI
import AVFoundation

/**
 * [Ref] https://www.youtube.com/watch?v=8hvaniprctk
 */
struct CameraViewOrigin: View {
    
    @StateObject var camera = CameraModelOrigin()
    
    var body: some View {
        ZStack {
            
            // Going to Be Camera preview...
            CameraPreviewOrigin(camera: camera)
                .ignoresSafeArea(.all, edges: .all)
            
            VStack {
                
                if camera.isTaken {
                    HStack {
                        Spacer()
                        
                        Button(action: camera.reTake, label: {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                        })
                        .padding(.trailing, 10)
                    }
                }
                
                Spacer()
                
                HStack {
                    
                    // if taken showing save and again take button...
                    
                    if camera.isTaken {
                        
                        Button(action: {
                            if !camera.isSaved {
                                camera.savePic()
                            }
                        }, label: {
                            Text(camera.isSaved ? "Saved" : "Save")
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Color.white)
                                .clipShape(Capsule())
                        })
                        .padding(.leading)
                        
                        Spacer()
                    }
                    else {
                        Button(action: camera.takePic, label: {
                            
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 65, height: 65)
                                
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 75, height: 75)
                            }
                        })
                    }
                }
                .frame(height: 75)
            }
        }
        .onAppear(perform: {
            camera.Check()
        })
    }
}

struct CameraViewOrigin_Previews: PreviewProvider {
    static var previews: some View {
        CameraViewOrigin()
    }
}


class CameraModelOrigin: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    
    @Published var isTaken = false
    
    @Published var session = AVCaptureSession()
    
    @Published var alert = false
    
    // since were going to read pic data...
    @Published var output = AVCapturePhotoOutput()
    
    // preview...
    @Published var preview: AVCaptureVideoPreviewLayer!
    
    // pic Data...
    @Published var isSaved = false
    @Published var picData = Data(count: 0)
    
    func Check() {
        
        // first checking camera has got permission...
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
            return
            
            // Setting Up Session
        case .notDetermined:
            // retusting for permission...
            AVCaptureDevice.requestAccess(for: .video) { (status) in
                
                if status {
                    self.setUp()
                }
            }
        case .denied:
            self.alert.toggle()
            return
        default:
            return
        }
    }
    
    func setUp() {
        
        // setting up camera...
        
        do {
            
            // setting configs...
            self.session.beginConfiguration()
            
            // change for your own...
            
            let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
            
            let input = try AVCaptureDeviceInput(device: device!)
            
            // checking and adding to session...
            
            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }
            
            // same for output...
            
            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }
            
            self.session.commitConfiguration()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    // take and retake functions...
    
    func takePic() {
        
        DispatchQueue.global(qos: .background).async {
            
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            self.session.stopRunning()
            
            DispatchQueue.main.async {
                
                withAnimation { self.isTaken.toggle() }
            }
        }
    }
    
    func reTake() {
        
        DispatchQueue.global(qos: .background).async {
            
            self.session.startRunning()
            
            DispatchQueue.main.async {
                withAnimation { self.isTaken.toggle() }
                // clearing...
                self.isSaved = false
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {

        if error != nil {
            return
        }

        print("pic taken...")
        
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        self.picData = imageData
    }
    
    func savePic() {
        let image = UIImage(data: self.picData)!
        
        // saving Image...
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        self.isSaved = true
        
        print("saved Successfully...")
    }
}

// setting view for preview...

struct CameraPreviewOrigin: UIViewRepresentable {
    
    @ObservedObject var camera: CameraModelOrigin
    
    func makeUIView(context: Context) -> some UIView {
        
        let view = UIView(frame: UIScreen.main.bounds)
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        
        // Your Own Properties...
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        
        // starting session
        camera.session.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        //
    }
}
