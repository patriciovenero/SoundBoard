//
//  SoundViewController.swift
//  SoundBoard
//
//  Created by patricio venero on 31/10/23.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var contadorLabel: UILabel!
    
    @IBOutlet weak var volumeSlider: UISlider!
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio : AVAudioPlayer?
    var audioURL : URL?
    var recordingTimer: Timer?
    var elapsedTime: TimeInterval = 0.0
    var duracionEnSegundos = 0
    
    @IBAction func volumeChanged(_ sender: Any) {
        if let reproducirAudio = reproducirAudio {
            reproducirAudio.volume = (sender as AnyObject).value
            }
        
    }
    
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording {
                // Detener la grabación
                grabarAudio?.stop()
                // Detener el temporizador
                recordingTimer?.invalidate()
                recordingTimer = nil
                // Calcular la duración en segundos
                duracionEnSegundos = Int(elapsedTime)
                // Asignar la duración a la entidad Grabacion
                
                // Cambiar texto del botón grabar
                grabarButton.setTitle("GRABAR", for: .normal)
                reproducirButton.isEnabled = true
                agregarButton.isEnabled = true
            } else {
                // Empezar a grabar
                grabarAudio?.record()
                // Iniciar el temporizador
                recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                    self?.elapsedTime += 1
                    self?.updateTimeLabel()
                }
                // Cambiar el texto del botón grabar a detener
                grabarButton.setTitle("DETENER", for: .normal)
                reproducirButton.isEnabled = false
            }
    }
    @IBAction func reproducirTapped(_ sender: Any) {
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
            
        }catch{}
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio  = NSData(contentsOf: audioURL!)! as Data
        grabacion.tiempograbacion = Int32(duracionEnSegundos)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
        // Configurar el rango de valores del UISlider para el volumen
            volumeSlider.minimumValue = 0.0
            volumeSlider.maximumValue = 1.0
            volumeSlider.value = 1.0  // Puedes establecer un valor predeterminado, p. ej., el volumen máximo.
    }
    
    func configurarGrabacion(){
        do{
            //creando sesion de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            //creando direccion para el harchivo de audio
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath,"audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            //impresion de ruta donde se guardan los harchivos
            print("**********************")
            print(audioURL!)
            print("**********************")
            
            //crear opcion para el grabador de audio
            
            var settings: [String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            //crear el objeto de creacion de audio
            
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
        }catch let error as NSError{
            print(error)
        }
    }
    func updateTimeLabel() {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        contadorLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        recordingTimer?.invalidate()
        recordingTimer = nil
    }



}
