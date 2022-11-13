//
//  ViewController.swift
//  CoreData-Names
//
//  Created by User on 13.11.2022.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {

    // MARK: - Properties

    var presenter: MainPresenterProtocol?

    // MARK: - Outlets

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.setLeftPaddingPoints(10)
        textField.placeholder = "Print your name here"
        textField.backgroundColor = .systemGray5
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        return textField
    }()

    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add name", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(
            self,
            action: #selector(addName),
            for: .touchUpInside
        )
        return button
    }()

    private lazy var table: UITableView = {
        let table = UITableView(
            frame: .zero,
            style: .insetGrouped
        )
        table.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "cell"
        )
        table.dataSource = self
        table.delegate = self
        return table
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupNavBar()
        setupHierarchy()
        setupLayout()
        presenter?.fetchUsers()
    }

    // MARK: - Setups

    private func setupNavBar() {
        title = "Users"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupHierarchy() {
        view.addSubview(textField)
        view.addSubview(button)
        view.addSubview(table)
    }

    private func setupLayout() {

        textField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(view.snp.leading).offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
            make.height.equalTo(48)
        }

        button.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(20)
            make.leading.equalTo(view.snp.leading).offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
            make.height.equalTo(48)
        }

        table.snp.makeConstraints { make in
            make.top.equalTo(button.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalTo(view)
        }
    }

    // MARK: - Button actions

    @objc private func addName() {
        if let name = textField.text, name != "" {
            presenter?.savePerson(withName: name)
            textField.text = ""
        }
    }

}

// MARK: - UITableView Extension

extension MainViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.numberOfRows() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = presenter?.getName(forIndex: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            presenter?.deleteTableCell(byIndex: indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter?.showDetailedPerson(for: indexPath)
    }
}

// MARK: - MainViewProtocol Extension

extension MainViewController: MainViewProtocol {
    func reloadTable() {
        table.reloadData()
    }
}
