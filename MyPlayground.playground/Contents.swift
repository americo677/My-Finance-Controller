//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"



let dtFormatter = DateFormatter()

dtFormatter.dateStyle = .short
dtFormatter.dateFormat = "EEE, MMM d, ''yy"


class Recibo {
    var descripcion:  String = ""
    var valor: Double = 0.0
    var fecha: Date = Date()
}

let recibo = Recibo()

recibo.descripcion = "compra 1"
recibo.valor = 1000
recibo.fecha = (dtFormatter.date(from: "01/01/2016") as? Date)!


