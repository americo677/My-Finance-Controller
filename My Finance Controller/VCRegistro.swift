//
//  VCRegistro.swift
//  My Finance Controller
//
//  Created by Américo Cantillo on 25/07/16.
//  Copyright © 2016 Américo Cantillo Gutiérrez. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class VCRegistro: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var tfSeccion: UITextField!
    
    @IBOutlet weak var tfTipoRegistro: UITextField!
    
    @IBOutlet weak var tfFechaRegistro: UITextField!
    
    @IBOutlet weak var tfReciboDescripcion: UITextField!
    
    @IBOutlet weak var tfReciboMonto: UITextField!
    
    @IBOutlet weak var bbtnSave: UIBarButtonItem!
    
    var moc = DataController().managedObjectContext
    
    var presupuesto: Presupuesto?
    
    let smModelo = CStructureModel()
    
    let strAppTitle = "My Finance Controller"

    var arrSeccion: [PresupuestoSeccion]?
    
    var seccion: PresupuestoSeccion?
    
    var recibo: Recibo?
    
    let arrTipoRegistro = ["Income", "Expenditure"]
    
    var pckrSeccion: UIPickerView!
    
    var pckrTipoRegistro: UIPickerView!
    
    let dtpFecha: UIDatePicker = UIDatePicker()
    
    let dtFormatter: NSDateFormatter = NSDateFormatter()

    let formatterMon : NSNumberFormatter = NSNumberFormatter()
    
    let formatterFlt : NSNumberFormatter = NSNumberFormatter()

    var intSeccionSeleccionada: Int?

    var intTipoRegistroSeleccionado: Int?
    
    let defaultRowIndex: Int = 0

    var boolGuardado: Bool = false
    
    var intTotalRecibos: Int = 0

    enum eTipoRegistro: Int {
        case income = 0
        case expenditure = 1
    }
    
    enum ePickerComponent: Int {
        case size    = 0
        case topping = 1
    }
    
    
    // MARK - Procedimiento para inicializar los text view del control view
    func clearAllTextFields() {
        
        self.tfSeccion.text = ""
        self.tfReciboDescripcion.text = ""
        self.tfTipoRegistro.text = ""
        self.tfReciboMonto.text = ""
        self.tfFechaRegistro.text = ""
    }
    
    // MARK - Procedimiento para inicializar las variables globales
    func initGlobalVars() {
        self.intSeccionSeleccionada = 0
        self.intTipoRegistroSeleccionado = eTipoRegistro.expenditure.rawValue
    }
    
    // MARK - Procedimiento para inicializar los text view y las variables locales
    func initControlView() {
        self.clearAllTextFields()
        self.initGlobalVars()
    }
    
    
    // MARK - Procedimiento que instancia el arreglo de secciones que corresponden al presupuesto
    func prepararSecciones() {
        
        if self.presupuesto != nil {
            self.arrSeccion = self.presupuesto?.secciones?.allObjects as? [PresupuestoSeccion]
        } else {
            self.arrSeccion = nil
        }
        
    }

    func donePickerSec() {
        self.tfSeccion.resignFirstResponder()
    }
    
    func cancelPickerSec() {
        self.pckrSeccion.selectRow(defaultRowIndex, inComponent: ePickerComponent.size.rawValue, animated: false)
        self.intSeccionSeleccionada = defaultRowIndex
        self.tfSeccion.text = self.arrSeccion![defaultRowIndex].descripcion
        self.seccion = self.arrSeccion![defaultRowIndex] as PresupuestoSeccion
        self.tfSeccion.resignFirstResponder()
    }
    
    func donePickerTR() {
        self.tfTipoRegistro.resignFirstResponder()
    }
    
    func handleDatePicker(sender: UITextField) {
        let picker: UIDatePicker = self.tfFechaRegistro.inputView as! UIDatePicker
        
        var isGreaterIni = false
        var isEqualToIni = false
        var isLessIni    = false
        var isGreaterFin = false
        var isEqualToFin = false
        var isLessFin    = false
        
        if self.presupuesto != nil {
            
            let calendario = NSCalendar.currentCalendar()
            
            let iniDate = self.presupuesto?.fechaInicio
            let finDate = self.presupuesto?.fechaFinal
            
            calendario.compareDate(picker.date, toDate: iniDate!, toUnitGranularity: .Day)
            
            if calendario.compareDate(picker.date, toDate: iniDate!, toUnitGranularity: .Day) == NSComparisonResult.OrderedDescending {
                isGreaterIni = true
            } else if calendario.compareDate(picker.date, toDate: iniDate!, toUnitGranularity: .Day) == NSComparisonResult.OrderedSame {
                isEqualToIni = true
            } else if calendario.compareDate(picker.date, toDate: iniDate!, toUnitGranularity: .Day) == NSComparisonResult.OrderedAscending {
                isLessIni = true
            }
                
            if calendario.compareDate(picker.date, toDate: finDate!, toUnitGranularity: .Day) == NSComparisonResult.OrderedDescending {
                isGreaterFin = true
            } else if calendario.compareDate(picker.date, toDate: finDate!, toUnitGranularity: .Day) == NSComparisonResult.OrderedSame {
                isEqualToFin = true
            } else if calendario.compareDate(picker.date, toDate: finDate!, toUnitGranularity: .Day) == NSComparisonResult.OrderedAscending {
                isLessFin = true
            }
            
            if isLessIni || isGreaterFin {
                showCustomWarningAlert("The date is out of range for the budget since \(dtFormatter.stringFromDate(iniDate!)) to \(dtFormatter.stringFromDate(finDate!)).", toFocus: tfFechaRegistro)
            } else if (isGreaterIni || isEqualToIni) && (isLessFin || isEqualToFin) {
                tfFechaRegistro.text = dtFormatter.stringFromDate(picker.date)
                
            } else {
                showCustomWarningAlert("The date is out of range for the budget since \(dtFormatter.stringFromDate(iniDate!)) to \(dtFormatter.stringFromDate(finDate!)).", toFocus: tfFechaRegistro)
            }
        }
        tfFechaRegistro.resignFirstResponder()
    }
    
    func initPickerViews() {
        // Preparación del Picker de Sección o Categoría
        var numberOfRows: Int = 0
        
        self.pckrSeccion = UIPickerView(frame: CGRectMake(0, 200, view.frame.width, 250))
        self.pckrSeccion.backgroundColor = UIColor.grayColor()
        self.pckrSeccion.tag = 0
        
        self.pckrSeccion.showsSelectionIndicator = true
        self.pckrSeccion.delegate  = self
        self.pckrSeccion.dataSource = self
        
        let tbSeccion         = UIToolbar()
        tbSeccion.barStyle    = UIBarStyle.Default
        tbSeccion.translucent = true
        
        //toolBar.tintColor = UIColor.whiteColor()
        //UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        tbSeccion.sizeToFit()
        
        let btnDoneSec = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.donePickerSec))
        let btnSpaceSec = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let btnCancelSec = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.cancelPickerSec))
        
        tbSeccion.setItems([btnCancelSec, btnSpaceSec, btnDoneSec], animated: false)
        tbSeccion.userInteractionEnabled = true
        
        self.tfSeccion.inputView = self.pckrSeccion
        self.tfSeccion.inputAccessoryView = tbSeccion
        
        // colocar el valor por default en el picker de un solo componente
        self.pckrSeccion.selectRow(defaultRowIndex, inComponent: ePickerComponent.size.rawValue, animated: false)
        // todo: para hacer pruebas
        //self.pickerView(self.pckrSeccion, didSelectRow: defaultRowIndex, inComponent: ePickerComponent.size.rawValue)
        
        //self.tfSeccion.text = self.arrSeccion![defaultRowIndex].descripcion
        self.intSeccionSeleccionada = defaultRowIndex
        if !self.tfSeccion.hasText() {
            self.tfSeccion.text = self.arrSeccion![defaultRowIndex].descripcion
            self.seccion = self.arrSeccion![defaultRowIndex] as PresupuestoSeccion
        }
        
        // Preparación del Picker de Tipo de Registro
        self.pckrTipoRegistro     = UIPickerView(frame: CGRectMake(0, 200, view.frame.width, 250))
        self.pckrTipoRegistro.backgroundColor = .grayColor()
        self.pckrTipoRegistro.tag = 1
        
        self.pckrTipoRegistro.showsSelectionIndicator = true
        self.pckrTipoRegistro.delegate = self
        self.pckrTipoRegistro.dataSource = self
        
        let tbTipoRegistro         = UIToolbar()
        tbTipoRegistro.barStyle    = UIBarStyle.Default
        tbTipoRegistro.translucent = true
        
        //toolBar.tintColor = UIColor.whiteColor()
        //UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        tbTipoRegistro.sizeToFit()
        
        let btnDoneTR = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(VCRegistro.donePickerTR))
        let btnSpaceTR = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let btnCancelTR = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(VCRegistro.donePickerTR))
        
        tbTipoRegistro.setItems([btnCancelTR, btnSpaceTR, btnDoneTR], animated: false)
        tbTipoRegistro.userInteractionEnabled = true
        
        self.tfTipoRegistro.inputView = self.pckrTipoRegistro
        self.tfTipoRegistro.inputAccessoryView = tbTipoRegistro

        // colocar el valor por default en el picker de un solo componente
        numberOfRows = self.pckrTipoRegistro.numberOfRowsInComponent(0)
        if numberOfRows > 0 {
            self.pckrTipoRegistro.selectRow(defaultRowIndex, inComponent: 0, animated: true)
        }
        
        self.intTipoRegistroSeleccionado = defaultRowIndex
        if !self.tfTipoRegistro.hasText() {
            self.tfTipoRegistro.text = self.arrTipoRegistro[defaultRowIndex]
        }
        
        // Almcena el tipo de registro
        //self.tfTipoRegistro.text = self.arrTipoRegistro[eTipoRegistro.expenditure.rawValue]
        self.intTipoRegistroSeleccionado = defaultRowIndex //eTipoRegistro.expenditure.rawValue // defaultRowIndex

    }
    
    func initDatePickers() {
        dtpFecha.date = NSDate()
        dtpFecha.datePickerMode = UIDatePickerMode.Date
        //dtpFecha.addTarget(self, action: #selector(self.handleDatePicker(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        self.tfFechaRegistro.inputView = dtpFecha
        
        let tbFecha         = UIToolbar()
        tbFecha.barStyle    = UIBarStyle.Default
        tbFecha.translucent = true
        
        //toolBar.tintColor = UIColor.whiteColor()
        //UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        tbFecha.sizeToFit()
        
        let btnDoneF = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.handleDatePicker(_:)))
        let btnSpaceF = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let btnCancelF = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.handleDatePicker(_:)))
        
        tbFecha.setItems([btnCancelF, btnSpaceF, btnDoneF], animated: false)
        tbFecha.userInteractionEnabled = true
        
        self.tfFechaRegistro.inputAccessoryView = tbFecha
    }
    
    func initFormatters() {
        self.dtFormatter.dateFormat = "dd/MM/yyyy"
        self.formatterMon.numberStyle = .CurrencyStyle
        self.formatterMon.maximumFractionDigits = 2
        
        self.formatterFlt.numberStyle = .NoStyle
        self.formatterFlt.maximumFractionDigits = 2
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    func initView() {
        self.initControlView()
        
        self.initPickerViews()
        
        self.initDatePickers()
        
        self.prepararSecciones()
    }
    
    func loadReciboParaEdicion() {
        if self.recibo != nil {
            self.tfSeccion.text = self.seccion?.descripcion
            self.tfSeccion.enabled = false
            self.tfSeccion.backgroundColor = UIColor.lightGrayColor()
            self.tfReciboDescripcion.text = self.recibo!.valueForKey(smModelo.smRecibo.colDescripcion) as! String!
            self.tfFechaRegistro.text     = dtFormatter.stringFromDate(self.recibo!.valueForKey(smModelo.smRecibo.colFecha) as! NSDate!)
            self.tfTipoRegistro.text      = self.arrTipoRegistro[self.recibo!.valueForKey(smModelo.smRecibo.colTipo) as! Int]
            self.tfTipoRegistro.enabled = false
            self.tfTipoRegistro.backgroundColor = UIColor.lightGrayColor()
            self.intTipoRegistroSeleccionado = self.recibo!.valueForKey(smModelo.smRecibo.colTipo) as? Int
            self.tfReciboMonto.text       = formatterMon.stringFromNumber(self.recibo!.valueForKey(smModelo.smRecibo.colValor) as! Double)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sublayer = CALayer.init()
        sublayer.backgroundColor = UIColor.customLightGrayColor().CGColor
        sublayer.shadowOffset = CGSizeMake(0, 3)
        sublayer.shadowRadius = 5.0
        sublayer.shadowOpacity = 0.8;
        sublayer.frame = CGRectMake(0, 0, 420, 4200)
        self.view.layer.addSublayer(sublayer)
        
        self.initFormatters()
        
        self.initView()
        
        self.loadReciboParaEdicion()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(animated: Bool) {
        #if LITE_VERSION
            self.intTotalRecibos = 0
            if self.presupuesto != nil {
                let secciones = self.presupuesto?.secciones?.allObjects as! [PresupuestoSeccion]
                
                for seccion in secciones {
                    self.intTotalRecibos += (seccion.recibos?.allObjects.count)!
                }
                
                if self.intTotalRecibos < CCGlobal().MAX_RECEIPTS_FOR_BUDGETS_LITE_VERSION {
                    bbtnSave.enabled = true
                } else {
                    bbtnSave.enabled = false
                }
                print("Total recibos en Recibos: \(self.intTotalRecibos)")
            }
        #endif
        
        #if FULL_VERSION
            self.bbtnSave.enabled = true
        #endif

    }
    
    // MARK: - Validación de formato numérico
    func validarValorNumericoMon(txtValor: String?) -> Bool {
        
        var boolResultado: Bool = true
        var douValor: Double?
        if !(txtValor?.isEmpty)! {
            douValor = formatterFlt.numberFromString(txtValor!)?.doubleValue
            
            if formatterFlt.numberFromString(txtValor!)?.doubleValue == nil {
                douValor = formatterMon.numberFromString(txtValor!)?.doubleValue
            } else {
                douValor = formatterFlt.numberFromString(txtValor!)?.doubleValue
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
    
    // MARK: - Alerta personalizada
    func showCustomWarningAlert(strMensaje: String, toFocus: UITextField?) {
        
        let alertController = UIAlertController(title: strAppTitle, message:
            strMensaje, preferredStyle: UIAlertControllerStyle.Alert)
        
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel,handler: {_ in
            if toFocus != nil {
                toFocus!.becomeFirstResponder()
            }
        })
        
        alertController.addAction(action)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }

    @IBAction func tfReciboMontoOnEditingDidEnd(sender: UITextField) {
        var esValido: Bool = true
        if sender.hasText() {
            esValido = validarValorNumericoMon(sender.text)
            if esValido == false {
                showCustomWarningAlert("Please, check out the mount of money.  It is not valid!.", toFocus: sender)
            } else {
                //print("Log: \(sender.text!) es un número válido!")
                var monto: Double?
                if formatterFlt.numberFromString(sender.text!)?.doubleValue == nil {
                    monto = formatterMon.numberFromString(sender.text!)?.doubleValue
                } else {
                    monto = formatterFlt.numberFromString(sender.text!)?.doubleValue
                }
                sender.text = formatterMon.stringFromNumber(monto!)
            }
        }
    }
    
    // MARK: - Procedimiento de preparación y validación de datos ingresados para guardado
    func prepararRecibo(inout isReciboReady isComplete: Bool) {
        isComplete = true
        if self.recibo == nil {
            let recibo = NSEntityDescription.insertNewObjectForEntityForName(self.smModelo.smRecibo.entityName, inManagedObjectContext: self.moc) as? Recibo
            
            if self.seccion != nil {
                recibo!.setValue(self.seccion, forKey: smModelo.smRecibo.colSeccion)
            }
            
            if self.tfReciboDescripcion.hasText() {
                //self.recibo?.descripcion = self.tfReciboDescripcion.text
                
                recibo!.setValue(self.tfReciboDescripcion.text, forKey: smModelo.smRecibo.colDescripcion)
            } else {
                isComplete = false
                showCustomWarningAlert("You must enter the description for the receipt.", toFocus: self.tfReciboDescripcion)
            }
            
            if self.tfFechaRegistro.hasText() {
                //self.recibo?.fecha =  dtFormatter.dateFromString(self.tfFechaRegistro.text!)
                
                recibo!.setValue(dtFormatter.dateFromString(self.tfFechaRegistro.text!), forKey: smModelo.smRecibo.colFecha)
            } else {
                isComplete = false
                showCustomWarningAlert("You must enter the date for the receipt.", toFocus: self.tfFechaRegistro)
            }
            
            if self.tfTipoRegistro.hasText() {
                if self.intTipoRegistroSeleccionado != nil {
                    //self.recibo?.tipo = self.intTipoRegistroSeleccionado
                    recibo!.setValue(self.intTipoRegistroSeleccionado, forKey: smModelo.smRecibo.colTipo)
                } else {
                    isComplete = false
                    showCustomWarningAlert("You must enter the kind for the receipt.", toFocus: self.tfTipoRegistro)
                }
            } else {
                isComplete = false
                showCustomWarningAlert("You must enter the kind for the receipt.", toFocus: self.tfTipoRegistro)
            }
            
            if self.tfReciboMonto.hasText() == false {
                isComplete = false
                showCustomWarningAlert("You must enter the mount of money for the receipt.", toFocus: self.tfReciboMonto)
            } else {
                let monto: Double = (formatterMon.numberFromString(self.tfReciboMonto.text!)?.doubleValue)!
                
                recibo!.setValue(monto, forKey: smModelo.smRecibo.colValor)
                
                if eTipoRegistro.expenditure.hashValue == self.intTipoRegistroSeleccionado {
                    print ("On Add Receipt: \(self.seccion!)")
                    var egreso  = (self.seccion?.valueForKey(smModelo.smPresupuestoSeccion.colTotalEgresos) as? Double)!
                    var egresos = (self.presupuesto?.valueForKey(smModelo.smPresupuesto.colEjecutado) as? Double)!
                    
                    egreso += monto
                    egresos += monto
                    
                    self.seccion?.setValue(egreso, forKey: smModelo.smPresupuestoSeccion.colTotalEgresos)
                    self.presupuesto?.setValue(egresos, forKey: smModelo.smPresupuesto.colEjecutado)
                } else if eTipoRegistro.income.hashValue == self.intTipoRegistroSeleccionado {
                    var ingreso = (self.seccion?.valueForKey(smModelo.smPresupuestoSeccion.colTotalIngresos) as? Double)!
                    var ingresos = (self.presupuesto?.valueForKey(smModelo.smPresupuesto.colIngresos) as? Double)!
                    
                    ingreso += monto
                    ingresos += monto
                    
                    self.seccion?.setValue(ingreso, forKey: smModelo.smPresupuestoSeccion.colTotalIngresos)
                    self.presupuesto?.setValue(ingresos, forKey: smModelo.smPresupuesto.colIngresos)
                }
            }
            
            let lpsRecibo = self.seccion?.mutableSetValueForKey(self.smModelo.smPresupuestoSeccion.colRecibos)
            
            lpsRecibo!.addObject(recibo!)
            
            self.seccion?.setValue(lpsRecibo!, forKey: smModelo.smPresupuestoSeccion.colRecibos)
            
            let lpsSeccion = self.presupuesto?.mutableSetValueForKey(self.smModelo.smPresupuesto.colSecciones)
            
            lpsSeccion?.addObject(self.seccion!)
            
            self.presupuesto?.setValue(lpsSeccion!, forKey: self.smModelo.smPresupuesto.colSecciones)
            
        } else {
            if self.tfReciboDescripcion.hasText() {
                self.recibo!.setValue(self.tfReciboDescripcion.text, forKey: smModelo.smRecibo.colDescripcion)
            } else {
                isComplete = false
                showCustomWarningAlert("You must enter the description for the receipt.", toFocus: self.tfReciboDescripcion)
            }
            
            if self.tfFechaRegistro.hasText() {
                self.recibo!.setValue(dtFormatter.dateFromString(self.tfFechaRegistro.text!), forKey: smModelo.smRecibo.colFecha)
            } else {
                isComplete = false
                showCustomWarningAlert("You must enter the date for the receipt.", toFocus: self.tfFechaRegistro)
            }
            
            if self.tfTipoRegistro.hasText() {
                if self.intTipoRegistroSeleccionado != nil {
                    //self.recibo?.tipo = self.intTipoRegistroSeleccionado
                    self.recibo!.setValue(self.intTipoRegistroSeleccionado, forKey: smModelo.smRecibo.colTipo)
                } else {
                    isComplete = false
                    showCustomWarningAlert("You must enter the kind for the receipt.", toFocus: self.tfTipoRegistro)
                }
            } else {
                isComplete = false
                showCustomWarningAlert("You must enter the kind for the receipt.", toFocus: self.tfTipoRegistro)
            }
            
            if self.tfReciboMonto.hasText() == false {
                isComplete = false
                showCustomWarningAlert("You must enter the mount of money for the receipt.", toFocus: self.tfReciboMonto)
            } else {
                let montoPrev: Double = (self.recibo?.valor as? Double)!
                
                let monto: Double = (formatterMon.numberFromString(self.tfReciboMonto.text!)?.doubleValue)!
                
                self.recibo!.setValue(monto, forKey: smModelo.smRecibo.colValor)
                
                if eTipoRegistro.expenditure.hashValue == self.intTipoRegistroSeleccionado {
                    var egreso  = (self.seccion?.valueForKey(smModelo.smPresupuestoSeccion.colTotalEgresos) as? Double)!
                    var egresos = (self.presupuesto?.valueForKey(smModelo.smPresupuesto.colEjecutado) as? Double)!
                    
                    egreso += monto
                    egresos += monto
                    
                    egreso -= montoPrev
                    egresos -= montoPrev
                    
                    self.seccion?.setValue(egreso, forKey: smModelo.smPresupuestoSeccion.colTotalEgresos)
                    self.presupuesto?.setValue(egresos, forKey: smModelo.smPresupuesto.colEjecutado)
                } else if eTipoRegistro.income.hashValue == self.intTipoRegistroSeleccionado {
                    var ingreso = (self.seccion?.valueForKey(smModelo.smPresupuestoSeccion.colTotalIngresos) as? Double)!
                    var ingresos = (self.presupuesto?.valueForKey(smModelo.smPresupuesto.colIngresos) as? Double)!
                    
                    ingreso += monto
                    ingresos += monto
                    
                    ingreso -= montoPrev
                    ingresos -= montoPrev
                    
                    self.seccion?.setValue(ingreso, forKey: smModelo.smPresupuestoSeccion.colTotalIngresos)
                    self.presupuesto?.setValue(ingresos, forKey: smModelo.smPresupuesto.colIngresos)
                }
            }
        }
    }
    
    // MARK: - Precedimiento de guardado
    func guardarPresupuesto() -> Bool {
        var canISave: Bool = true
        do {
            prepararRecibo(isReciboReady: &canISave)
            if canISave {
                try self.moc.save()
                self.intTotalRecibos += 1
                showCustomWarningAlert("The receipt has been saved successfully", toFocus: nil)
                self.initView()
            }
        } catch let error as NSError {
            print("No se pudo guardar los datos del presupuesto.  Error: \(error)")
        }
        return canISave
    }
    
    // MARK: - Botón para guardar nuevos registros y cambios
    @IBAction func btnSaveOnTouchInsideDown(sender: UIBarButtonItem) {
        // código para guardar
        
        if self.intTotalRecibos < CCGlobal().MAX_RECEIPTS_FOR_BUDGETS_LITE_VERSION {
            self.boolGuardado = self.guardarPresupuesto()
        } else {
            self.showCustomWarningAlert("This is the demo version.  To enjoy the full version of \(self.strAppTitle) we invite you to obtain the full version.  Thank you!.", toFocus: nil)
        }
        
    }
    
    // MARK: - Funciones de los UIPickerViews
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1 //pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        var intNumberOfRows: Int = 0
        
        if pickerView.tag == 0 {
            intNumberOfRows = (self.arrSeccion?.count)!
        } else if pickerView.tag == 1 {
            intNumberOfRows = self.arrTipoRegistro.count
        }
        
        return intNumberOfRows
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var strTitle: String = ""
        
        if pickerView.tag == 0 {
            strTitle = self.arrSeccion![row].descripcion!
            //print("Row<\(row)>: \(strTitle)")
        } else if pickerView.tag == 1 {
            strTitle = self.arrTipoRegistro[row]
        }
        
        return strTitle
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            // Almacena la sección
            self.tfSeccion.text = self.arrSeccion![row].descripcion
            self.intSeccionSeleccionada = row
            self.seccion = self.arrSeccion![self.intSeccionSeleccionada!] as PresupuestoSeccion
        } else if pickerView.tag == 1 {
            // Almcena el tipo de registro
            self.tfTipoRegistro.text = self.arrTipoRegistro[row]
            self.intTipoRegistroSeleccionado = row
        }
    }
    
    
    
    
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueBackToBudgetDetails" {
            let back: TVCPresupuestoDetalle = segue.destinationViewController as! TVCPresupuestoDetalle
            
            back.presupuesto = self.presupuesto
            back.moc         = self.moc
        }
    }
    */
}
