//
//  Budget.swift
//  My Finance Controller
//
//  Created by Américo Cantillo on 16/11/16.
//  Copyright © 2016 Américo Cantillo Gutiérrez. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import CoreData

class BudgetServices {

    private static let modelo = CStructureModel()
    
    private enum eTipoRegistro: Int {
        case income = 0
        case expenditure = 1
    }

    private init() { }

    static let sharedInstance = BudgetServices()

    func syncBalancesOfSections(section: PresupuestoSeccion, moc: NSManagedObjectContext, ingresos: inout Double, egresos: inout Double) -> Void {
        let receipts = section.mutableSetValue(forKey: BudgetServices.modelo.smPresupuestoSeccion.colRecibos).allObjects as! [Recibo]
        
        for receipt in receipts {
            
            let monto = receipt.valor! as Double
            
            let tipo = receipt.tipo?.intValue
            
            
            if eTipoRegistro.expenditure.hashValue == tipo {
                
                egresos += monto
                
            } else if eTipoRegistro.income.hashValue == tipo {
                
                ingresos += monto
                
            }
            
            section.setValue(ingresos, forKey: BudgetServices.modelo.smPresupuestoSeccion.colTotalIngresos)
            section.setValue(egresos, forKey: BudgetServices.modelo.smPresupuestoSeccion.colTotalEgresos)
            
            do {
                try moc.save()
            } catch {
                let updateError = error as NSError
                print("Error inesperado al intentar sincronizar saldos de sección: \(updateError)")
            }
            
        }
    }
    
    func syncBalancesOfBudget(budget: Presupuesto, moc: NSManagedObjectContext) -> Void {
        
        let sections = budget.mutableSetValue(forKey: BudgetServices.modelo.smPresupuesto.colSecciones).allObjects as! [PresupuestoSeccion]
        
        var egresos: Double = 0.0
        var ingresos: Double = 0.0
        
        for section in sections {
            var ingresosSeccion: Double = 0.0
            var egresosSeccion: Double = 0.0
            syncBalancesOfSections(section: section, moc: moc, ingresos: &ingresosSeccion, egresos: &egresosSeccion)
            
            ingresos += ingresosSeccion
            egresos += egresosSeccion
        }
        
        budget.setValue(ingresos, forKey: BudgetServices.modelo.smPresupuesto.colIngresos)
        budget.setValue(egresos, forKey: BudgetServices.modelo.smPresupuesto.colEjecutado)
        
        do {
            try moc.save()
        } catch {
            let updateError = error as NSError
            print("Error inesperado al intentar sincronizar saldos de presupuesto: \(updateError)")
        }
    }
    
}

