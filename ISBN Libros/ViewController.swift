//
//  ViewController.swift
//  ISBN Libros
//
//  Created by Mateo Villagomez on 1/18/16.
//  Copyright © 2016 Mateo Villgomez. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    var wasSuccesfull = false
    
    @IBOutlet weak var textField: UITextField!

    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var authorTextView: UITextView!
    
    @IBOutlet weak var webImageView: UIWebView!
    
    @IBAction func doTextField(sender: AnyObject) {
        
        errorLabel.text = ""
        textView.text = ""
        authorTextView.text = ""
        webImageView.hidden = true
        
        let url = NSURL(string: "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + textField.text! + "")!
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url) { (data, response, error) -> Void in

            if error != nil {
                self.errorLabel.text = "Libro no Identificado"
            } else {
                
                if let data = data {
                    do{
                        let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
                        
                        if jsonResult!.count > 0 {
                            if let isbn = jsonResult!["ISBN:\(self.textField.text!)"] as? NSDictionary {
                                if let authors = isbn["authors"] as? [[String: AnyObject]] {
                                    for author in authors {
                                        // Fast Display (Updating UI)
                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                            // Title
                                            let Title = isbn["title"] as! NSString as String
                                            // Author
                                            let Author = author["name"] as! NSString as String
                        
                                            self.textView.text = "Titulo del libro: \(Title)"
                                            self.authorTextView.text = "Autor/es: \(Author)"
                                        })
                                        /* // Another option
                                        if let title = isbn["title"] as? NSString */
                                    }
                                }
                                
                                if let covers = isbn["cover"] as? NSDictionary {
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        let imageURL = covers["medium"] as! NSString as String
                                        let urlImage = NSURL(string: "\(imageURL)")
                                        self.webImageView.loadRequest(NSURLRequest(URL: urlImage!))
                                        self.webImageView.hidden = false
                                    })
                                } else { self.webImageView.hidden = true
                                }
                            }
                        }   // Error if the city does not exist or the procces failed
                            else if self.wasSuccesfull == false {
                                    // Giving color to the text
                                    self.errorLabel.textColor = UIColor(colorLiteralRed: 185, green: 158, blue: 115, alpha: 1)
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        self.errorLabel.text = "No se encontró la información - Inténtelo de nuevo"
                                    })
                            }
                    } catch {
                    }
                }
            }
        }
        task.resume()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.delegate = self
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}

