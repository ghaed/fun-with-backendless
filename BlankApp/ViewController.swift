 
 import UIKit
 import Backendless
 
 class ViewController: UIViewController {
    
    @IBOutlet var objectSavedLabel: UILabel!
    @IBOutlet var liveUpdateObjectPropertyLabel: UILabel!
    @IBOutlet var propertyLabel: UILabel!
    @IBOutlet var changePropertyValueTextField: UITextField!
    @IBOutlet var updateButton: UIButton!
    
    var dataStore: MapDrivenDataStore?
    var testObject: [String : Any]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changePropertyValueTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        saveMockApiValue()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if ((textField.text?.count)! > 0) {
            updateButton.isEnabled = true
        }
        else {
            updateButton.isEnabled = false
        }
    }
    
    func showErrorAlert(_ fault: Fault) {
        let alert = UIAlertController(title: String(format: "Error %@", fault.faultCode), message: fault.message, preferredStyle: .alert)
        let dismissButton = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(dismissButton)
        present(alert, animated: true, completion: nil)
    }
    

     func saveMockApiValue() {
         dataStore = Backendless.shared.data.ofTable("Person")
         var testObject  = Dictionary<String, Any>()
         testObject["name"] = "Kamal"
         testObject["age"] = 25
         
         dataStore?.save(entity: testObject, responseHandler: { savedTestObject in
             DispatchQueue.main.async {
                 self.objectSavedLabel.text = "Object has been saved in the real-time database"
                 self.liveUpdateObjectPropertyLabel.text = "Live update object property"
                 self.propertyLabel.text = savedTestObject["age"] as? String
             }
             self.testObject = savedTestObject
             let eventHandler = self.dataStore?.rt
             if let savedObjectId = savedTestObject["objectId"] as? String {
                 
                 let whereClause = String(format: "objectId = '%@'", savedObjectId)
                 let _ = eventHandler?.addUpdateListener(whereClause: whereClause, responseHandler: { updatedTestObject in
                     var stringValue = "\(updatedTestObject["age"]!)"
                     if updatedTestObject["age"] != nil {
                         self.propertyLabel.text = stringValue
                     }
                 }, errorHandler: { fault in
                     self.showErrorAlert(fault)
                 })
             }
         }, errorHandler: { fault in
             self.showErrorAlert(fault)
         })
     }
    
    @IBAction func pressedUpdate(_ sender: Any) {
        if let property = changePropertyValueTextField.text {
            testObject!["age"] = Int(property)
            dataStore?.save(entity: testObject, responseHandler: { updatedTestObject in
            }, errorHandler: { fault in
                self.showErrorAlert(fault)
            })
        }
        changePropertyValueTextField.text = ""
        updateButton.isEnabled = false
    }
 }
