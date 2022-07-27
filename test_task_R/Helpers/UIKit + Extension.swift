//
//  UIKit + Extension.swift
//  test_task_R
//
//  Created by Дмитрий Балантаев on 27.07.2022.
//

import UIKit

extension UIViewController {

    // скрытие клавиатуры по нажатю на любое место и открытие/закрытие экранов
    func dismissKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action:
                                                                    #selector
                                                                 (UIViewController.dismissKeyboardTouchOutside))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboardTouchOutside() {
        view.endEditing(true)
    }

    // открытие/закрытие вью
    func pushView(viewController: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        self.view.window!.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func dismissView() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        self.view.window!.layer.add(transition, forKey: kCATransition)
        navigationController!.popViewController(animated: true)
    }

}
