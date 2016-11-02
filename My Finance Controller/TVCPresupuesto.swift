//
//  TVCPresupuesto.swift
//  My Finance Controller
//
//  Created by Américo Cantillo on 5/07/16.
//  Copyright © 2016 Américo Cantillo Gutiérrez. All rights reserved.
//

import UIKit
import CoreData

class TVCPresupuesto: UIViewController, UITextFieldDelegate  {
    
    @IBOutlet weak var txtvSections: UITextView!
    
    @IBOutlet weak var stpUmbral: UIStepper!
    
    @IBOutlet weak var lblUmbral: UILabel!
    
    @IBOutlet weak var swPreservar: UISwitch!
    
    let preferencias = UserDefaults.standard

    let dflPresupuestoLookingFor = "nameOfBudgetLookingFor"
    
    var moc = DataController().managedObjectContext
    
    var presupuesto: Presupuesto?
    
    var presupuestos: [AnyObject] = []

    let smModelo = CStructureModel()
    
    let strAppTitle = "My Finance Controller"

    @IBOutlet weak var txtPresupuestoNombre: UITextField!
    
    @IBOutlet weak var txtFechaIni: UITextField!
    
    @IBOutlet weak var txtFechaFin: UITextField!
    
    @IBOutlet weak var txtPresupuesto: UITextField!
    
    let datePickerIni: UIDatePicker = UIDatePicker()
    let datePickerFin: UIDatePicker = UIDatePicker()
    
    let dateFormatter: DateFormatter = DateFormatter()
    let formatterMon : NumberFormatter = NumberFormatter()
    let formatterFlt : NumberFormatter = NumberFormatter()
    
    var boolGuardado: Bool = false

    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    // MARK: - Inicializador del UIStepper
    func initStepper() {
        self.stpUmbral.wraps = false
        self.stpUmbral.minimumValue = 0
        self.stpUmbral.maximumValue = 100
        
        self.stpUmbral.value = 0
        
        self.lblUmbral.text = "0.0 %"

        self.stpUmbral.isContinuous = false
        self.stpUmbral.stepValue = 5
    }
    
    // MARK: - Inicializador de todos los UITextFields
    func clearAllTextFields() {
        
        self.txtPresupuestoNombre.text = ""
        
        self.txtFechaIni.text = ""
        self.txtFechaFin.text = ""
        
        self.txtPresupuesto.text = ""
        
        self.txtvSections.text = ""
        
        self.initStepper()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let sublayer = CALayer.init()
        sublayer.backgroundColor = UIColor.customLightGrayColor().cgColor
        sublayer.shadowOffset = CGSize(width: 0, height: 3)
        sublayer.shadowRadius = 5.0
        //sublayer.shadowColor = [UIColor blackColor].CGColor;
        sublayer.shadowOpacity = 0.8;
        sublayer.frame = self.view.layer.frame //CGRectMake(30, 30, 128, 192)
        //[self.view.layer addSublayer:sublayer];
        self.view.layer.addSublayer(sublayer)
                
        self.initFormatters()
        
        self.initDatePickers()
        
        self.clearAllTextFields()
        
        self.loadPresupuesto()
        
        self.loadSections()

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        self.view.addGestureRecognizer(tap)
        
    }
    
    // MARK: - Inicializador de los formateadores de Fecha y número
    func initFormatters() {
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        formatterMon.numberStyle = .currency
        formatterMon.maximumFractionDigits = 2
        
        formatterFlt.numberStyle = .none
        formatterFlt.maximumFractionDigits = 2
    }
    
    // MARK: - Inicializador de los UIDatePickers
    func initDatePickers() {
        datePickerIni.date = Date()
        datePickerIni.datePickerMode = UIDatePickerMode.date
        //datePickerIni.addTarget(self, action: #selector(TVCPresupuesto.handleDatePickerIni(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.txtFechaIni.inputView = datePickerIni
        
        let tbFechaIni         = UIToolbar()
        tbFechaIni.barStyle    = UIBarStyle.default
        tbFechaIni.isTranslucent = true
        
        //toolBar.tintColor = UIColor.whiteColor()
        tbFechaIni.sizeToFit()
        
        let btnDoneFI = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.handleDatePickerIni(_:)))
        let btnSpaceFI = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let btnCancelFI = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.handleDatePickerIni(_:)))
        
        tbFechaIni.setItems([btnCancelFI, btnSpaceFI, btnDoneFI], animated: false)
        tbFechaIni.isUserInteractionEnabled = true
        
        self.txtFechaIni.inputAccessoryView = tbFechaIni
        
        
        datePickerFin.date = Date()
        datePickerFin.datePickerMode = UIDatePickerMode.date
        //datePickerFin.addTarget(self, action: #selector(TVCPresupuesto.handleDatePickerFin(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.txtFechaFin.inputView = datePickerFin
        
        let tbFechaFin         = UIToolbar()
        tbFechaFin.barStyle    = UIBarStyle.default
        tbFechaFin.isTranslucent = true
        
        //toolBar.tintColor = UIColor.whiteColor()
        //UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        tbFechaFin.sizeToFit()
        
        let btnDoneFF = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.handleDatePickerFin(_:)))
        let btnSpaceFF = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let btnCancelFF = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.handleDatePickerFin(_:)))
        
        tbFechaFin.setItems([btnCancelFF, btnSpaceFF, btnDoneFF], animated: false)
        tbFechaFin.isUserInteractionEnabled = true
        
        self.txtFechaFin.inputAccessoryView = tbFechaFin
    }
    
    // MARK: - Carga los datos del presupuesto en modo edición
    func loadPresupuesto() {
        if let strPresupuestoNombre = preferencias.value(forKey: dflPresupuestoLookingFor) as? String? {
            if strPresupuestoNombre != nil {
                if !strPresupuestoNombre!.isEmpty {
                    preferencias.set(nil, forKey: dflPresupuestoLookingFor)
                    
                    let predicado: NSPredicate =  NSPredicate(format: " descripcion = %@ ", argumentArray: [strPresupuestoNombre!])
                    
                    // Initialize Fetch Request
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: smModelo.smPresupuesto.entityName)
                    
                    // Create Entity Description
                    // Configure Fetch Request
                    fetchRequest.entity = NSEntityDescription.entity(forEntityName: smModelo.smPresupuesto.entityName, in: self.moc
                    )
                    
                    fetchRequest.predicate = predicado
                    
                    do {
                        self.presupuestos = try self.moc.fetch(fetchRequest)
                        //print(presupuestos)
                        
                        self.presupuesto = self.presupuestos.first! as? Presupuesto
                        
                        if self.presupuesto == nil {
                            presupuesto = NSEntityDescription.insertNewObject(forEntityName: smModelo.smPresupuesto.entityName, into: moc) as? Presupuesto
                        } else {
                            self.txtPresupuestoNombre.text = self.presupuesto?.descripcion
                            
                            self.txtFechaIni.text = dateFormatter.string(from: (self.presupuesto?.fechaInicio)! as Date)
                            self.txtFechaFin.text = dateFormatter.string(from: (self.presupuesto?.fechaFinal)! as Date)
                            
                            self.txtPresupuesto.text = formatterMon.string(from: self.presupuesto!.valor!)
                            
                            self.lblUmbral.text = formatterFlt.string(from: (self.presupuesto?.umbral!)!)! + " %"
                            
                            self.stpUmbral.value = (self.presupuesto?.umbral!.doubleValue)!
                        }
                        
                    } catch {
                        let fetchError = error as NSError
                        print(fetchError)
                    }
                }
            }
        }

        
    }
    
    // MARK: - Carga de secciones existentes.
    func loadSections() {
        
        self.txtvSections.setNeedsDisplay()
        
        if self.presupuesto != nil {
            let sections = self.presupuesto?.secciones?.allObjects as! [PresupuestoSeccion]
            
            self.txtvSections.text = ""
            
            var item: Int = 0
            
            repeat {
                if sections.count > 0 {
                    let strSeccion = sections[item].value(forKey: self.smModelo.smPresupuestoSeccion.colDescripcion) as! String
                    self.txtvSections.text.append("\(strSeccion)\n")
                }
                item += 1
            } while (item < sections.count)
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        preferencias.synchronize()

        loadSections()
    }
    
    @IBAction func swPreservarOnValueChanged(_ sender: UISwitch) {
        if self.presupuesto != nil {
            self.presupuesto?.setValue(sender.isOn, forKey: smModelo.smPresupuesto.colPreservar)
        }
}
    
    
    @IBAction func stpUmbralOnValueChanged(_ sender: UIStepper) {
        
        self.lblUmbral.text = sender.value.description + " %"

        if self.presupuesto != nil {
            self.presupuesto?.setValue(formatterFlt.number(from: sender.value.description), forKey: smModelo.smPresupuesto.colUmbral)
        }
    }
    
    // MARK: - Manipulación de DatePickers
    func handleDatePickerIni(_ sender: UITextField) {
        let picker: UIDatePicker = txtFechaIni.inputView as! UIDatePicker
        
        txtFechaIni.text = dateFormatter.string(from: picker.date)
        
        presupuesto?.setValue(picker.date, forKey: smModelo.smPresupuesto.colFechaIni)
        
        txtFechaIni.resignFirstResponder()
    }
    
    func handleDatePickerFin(_ sender: UITextField) {
        let picker: UIDatePicker = txtFechaFin.inputView as! UIDatePicker
        txtFechaFin.text = dateFormatter.string(from: picker.date)
        
        presupuesto?.setValue(picker.date, forKey: smModelo.smPresupuesto.colFechaFin)
        
        txtFechaFin.resignFirstResponder()
    }

    // MARK: - Validación de formato numérico
    func validarValorNumericoMon(_ txtValor: String?) -> Bool {
        
        var boolResultado: Bool = true
        var douValor: Double?
        
        if !(txtValor?.isEmpty)! {
            douValor = formatterFlt.number(from: txtValor!)?.doubleValue

            if formatterFlt.number(from: txtValor!)?.doubleValue == nil {
                douValor = formatterMon.number(from: txtValor!)?.doubleValue
            } else {
                douValor = formatterFlt.number(from: txtValor!)?.doubleValue
            }
            
            if douValor == nil {
                //print("The number is not a valid number!")
                boolResultado = false
            }
        } else {
            //print("The field is empty!")
            boolResultado = false
        }
        return boolResultado
    }
    
    // MARK: - Validación que indica si el nombre del presupuesto enviado como argumento ya existe.
    func existePresupuesto(nombrePresupuesto nombre: String) -> Bool {
        var boolExiste: Bool = false
        
        let predicado: NSPredicate =  NSPredicate(format: " descripcion = %@ ", argumentArray: [nombre])
        
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: smModelo.smPresupuesto.entityName)
        
        // Create Entity Description
        // Configure Fetch Request
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: smModelo.smPresupuesto.entityName, in: self.moc
        )
        
        fetchRequest.predicate = predicado
        
        do {
            let resultados = try self.moc.fetch(fetchRequest)
            
            boolExiste = (resultados.count > 0)
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        return boolExiste
    }

    // MARK: - Preparación de los datos del presupuesto para guardar el nuevo registro o los cambios realizados
    func prepararPresupuesto(isPresupuestoReady isComplete: inout Bool) {
        var mensaje: String?
        isComplete = true
        
        if self.presupuesto == nil {
            if !self.txtPresupuestoNombre.hasText {
                mensaje = "You must enter the name of the budget"
                isComplete = false
                showCustomWarningAlert(mensaje!, toFocus: self.txtPresupuestoNombre)
            } else {
                // validar si existe el presupuesto
                let existe = existePresupuesto(nombrePresupuesto: self.txtPresupuestoNombre.text!)
                
                if existe {
                    mensaje = "The name of the budget there is exists.  You must use another one."
                    isComplete = false
                    showCustomWarningAlert(mensaje!, toFocus: self.txtPresupuestoNombre)
                }
            }
            
            if !self.txtFechaIni.hasText {
                mensaje = "You must enter the start date of the budget."
                isComplete = false
                showCustomWarningAlert(mensaje!, toFocus: self.txtFechaIni)
            }
            
            if !self.txtFechaFin.hasText {
                mensaje = "You must enter the final date of the budget."
                isComplete = false
                showCustomWarningAlert(mensaje!, toFocus: self.txtFechaFin)
            }
            
            if !self.txtPresupuesto.hasText {
                mensaje = "You must enter the value of the budget."
                isComplete = false
                showCustomWarningAlert(mensaje!, toFocus: self.txtPresupuesto)
            }
            
           if isComplete {
                //self.presupuesto = nil
                self.presupuesto = NSEntityDescription.insertNewObject(forEntityName: self.smModelo.smPresupuesto.entityName, into: self.moc) as? Presupuesto
            
                self.presupuesto!.setValue(self.txtPresupuestoNombre.text, forKey: smModelo.smPresupuesto.colDescripcion)
                self.presupuesto!.setValue(dateFormatter.date(from: self.txtFechaIni.text!), forKey: smModelo.smPresupuesto.colFechaIni)
                self.presupuesto!.setValue(dateFormatter.date(from: self.txtFechaFin.text!), forKey: smModelo.smPresupuesto.colFechaFin)
                self.presupuesto!.setValue(formatterMon.number(from: self.txtPresupuesto.text!), forKey: smModelo.smPresupuesto.colValor)
                self.presupuesto!.setValue(self.stpUmbral.value, forKey: smModelo.smPresupuesto.colUmbral)
            
                self.presupuesto?.setValue(swPreservar.isOn, forKey: smModelo.smPresupuesto.colPreservar)

                self.presupuesto?.setValue(true, forKey: smModelo.smPresupuesto.colActivo)
            }
        }
    }
    
    // MARK: - Guarda los cambios realizados al presupuesto
    func guardarPresupuesto() -> Bool {
        var canISave: Bool = true
        do {
            prepararPresupuesto(isPresupuestoReady: &canISave)
            
            if canISave {
                try self.moc.save()
            }
            //print("guardarPresupuesto()... El presupuesto fue guardado con éxito!.")
        } catch let error as NSError {
            print("No se pudo guardar los datos del presupuesto.  Error: \(error)")
        }
        
        return canISave
    }
    
    @IBAction func btnSectionsOnTouchInDown(_ sender: UIBarButtonItem) {

        self.boolGuardado = self.guardarPresupuesto()
        
        if self.boolGuardado {
            preferencias.set(self.presupuesto?.descripcion, forKey: dflPresupuestoLookingFor)
            
            preferencias.synchronize()
            
            self.performSegue(withIdentifier: "segueSections", sender: self)
        }
    }
    
    @IBAction func txtPresupuestoNombreOnEditingDidEnd(_ sender: UITextField) {
        if sender.hasText {
            presupuesto?.setValue(sender.text, forKey: smModelo.smPresupuesto.colDescripcion)
        }
    }
    

    // MARK: - Alerta personalizada
    func showCustomWarningAlert(_ strMensaje: String, toFocus: UITextField) {
        
        let alertController = UIAlertController(title: strAppTitle, message: strMensaje, preferredStyle: UIAlertControllerStyle.alert)
            
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel,handler: {_ in toFocus.becomeFirstResponder()})
            
        alertController.addAction(action)
            
        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Validación de la entrada númerica del valor del presupuesto
    @IBAction func txtPresupuestoOnEditingDidEnd(_ sender: UITextField) {
        var esValido: Bool = true
        if sender.hasText {
            esValido = validarValorNumericoMon(sender.text)
            if esValido == false {
                showCustomWarningAlert("Please, check out the mount of money.  It is not valid!.", toFocus: sender)
            } else {
                //print("Log: \(sender.text!) es un número válido!")
                var monto: Double? // = formatterFlt.numberFromString(sender.text!)!.doubleValue
                if formatterFlt.number(from: sender.text!)?.doubleValue == nil {
                    monto = formatterMon.number(from: sender.text!)?.doubleValue
                } else {
                    monto = formatterFlt.number(from: sender.text!)?.doubleValue
                }
                sender.text = formatterMon.string(from: NSNumber.init(value: monto!))
                presupuesto?.setValue(monto, forKey: smModelo.smPresupuesto.colValor)
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if self.boolGuardado {
            if segue.identifier == "segueSections" {
                preferencias.set(self.presupuesto?.descripcion, forKey: dflPresupuestoLookingFor)
                let vcCategoria: TVCCategoria = segue.destination as! TVCCategoria
                vcCategoria.presupuesto = self.presupuesto
                vcCategoria.moc         = self.moc
            }
        }
    }
}
